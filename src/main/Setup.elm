module Setup exposing (Model, Msg, Options, handleKeyDown, init, update, view)

import Array exposing (Array)
import Common exposing (KeyboardEvent, sendMessage)
import Dialog
import File
import File.Download
import File.Select
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Scores exposing (Scores)
import Scores.Csv
import Task
import Time


type alias Options m =
    { disabled : Bool
    , route : Msg -> m
    , onClose : Scores -> m
    , onError : String -> m
    }


type alias Model =
    { oldScores : Scores
    , title : String
    , tables : String
    , games : String
    , values : Array (Array Int)
    }


type Msg
    = ClearClicked
    | ClearingGotTime ( Time.Zone, Time.Posix )
    | LoadClicked
    | LoadingGotFile File.File
    | LoadingGotData File.File String
    | SaveClicked
    | TitleChanged String
    | TablesChanged String
    | GamesChanged String
    | CancelClicked
    | OkClicked


cssClasses =
    Common.cssClasses.setup


init : Scores -> Model
init scores =
    { oldScores = scores
    , title = scores.title
    , tables = String.fromInt scores.tables
    , games = String.fromInt scores.games
    , values = scores.values
    }


view : Options m -> Model -> H.Html m
view options model =
    Dialog.view
        (dialogOptions options model)
        (viewMain options model)


dialogOptions : Options m -> Model -> Dialog.Options m
dialogOptions options model =
    let
        defaults =
            Dialog.defaults

        inputHasError =
            lengthError model.tables /= "" || lengthError model.games /= ""
    in
    { defaults
        | disabled = options.disabled
        , title = "Setup"
        , onClose = Just (options.route CancelClicked)
        , onEnter = Just (options.route OkClicked)
        , footer =
            [ H.button
                [ HA.disabled options.disabled
                , HE.onClick (options.route CancelClicked)
                ]
                [ H.text "Cancel" ]
            , H.button
                [ HA.disabled (options.disabled || inputHasError)
                , HE.onClick (options.route OkClicked)
                ]
                [ H.text "Ok" ]
            ]
    }


viewMain : Options m -> Model -> List (H.Html m)
viewMain options model =
    [ H.div [ cssClasses.menu ]
        [ H.button
            [ HA.disabled options.disabled
            , HE.onClick (options.route ClearClicked)
            ]
            [ H.text "Clear" ]
        , H.button
            [ HA.disabled options.disabled
            , HE.onClick (options.route LoadClicked)
            ]
            [ H.text "Load" ]
        , H.button
            [ HA.disabled options.disabled
            , HE.onClick (options.route SaveClicked)
            ]
            [ H.text "Save" ]
        ]
    , H.div [ cssClasses.fields ]
        [ H.label [ HA.for "sTitle" ] [ H.text "Title" ]
        , H.input
            [ HA.id "sTitle"
            , HA.value model.title
            , HA.disabled options.disabled
            , HE.onInput (options.route << TitleChanged)
            ]
            []
        , H.label [ HA.for "sTables" ] [ H.text "Tables" ]
        , H.input
            [ HA.id "sTables"
            , HA.type_ "number"
            , HA.min "1"
            , HA.max "100"
            , HA.value model.tables
            , HA.disabled options.disabled
            , HE.onInput (options.route << TablesChanged)
            ]
            []
        , H.label [ cssClasses.error ] [ H.text (lengthError model.tables) ]
        , H.label [ HA.for "sGames" ] [ H.text "Games" ]
        , H.input
            [ HA.id "sGames"
            , HA.type_ "number"
            , HA.min "1"
            , HA.max "100"
            , HA.value model.games
            , HA.disabled options.disabled
            , HE.onInput (options.route << GamesChanged)
            ]
            []
        , H.label [ cssClasses.error ] [ H.text (lengthError model.games) ]
        ]
    , valuesStatus model
    ]


update : Msg -> Options m -> Model -> ( Model, Cmd m )
update msg options model =
    case msg of
        ClearClicked ->
            ( model
            , Task.perform
                (ClearingGotTime >> options.route)
                (Task.map2 Tuple.pair Time.here Time.now)
            )

        ClearingGotTime ( here, now ) ->
            ( { model
                | title = Scores.datedTitle here now
                , values = Array.empty
              }
            , Cmd.none
            )

        LoadClicked ->
            ( model
            , File.Select.file [ ".csv", "text/csv" ] (LoadingGotFile >> options.route)
            )

        LoadingGotFile file ->
            ( model
            , Task.perform (LoadingGotData file >> options.route) (File.toString file)
            )

        LoadingGotData file data ->
            let
                title =
                    if String.endsWith ".csv" (File.name file) then
                        String.dropRight 4 (File.name file)

                    else
                        File.name file
            in
            case Scores.Csv.decode title data of
                Ok scores ->
                    ( { model
                        | title = scores.title
                        , tables = String.fromInt scores.tables
                        , games = String.fromInt scores.games
                        , values = scores.values
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( model, sendMessage (options.onError error) )

        SaveClicked ->
            ( model
            , File.Download.string
                (model.title ++ ".csv")
                "text/csv"
                (Scores.Csv.encode (toScores model))
            )

        TitleChanged title ->
            ( { model | title = title }, Cmd.none )

        TablesChanged tables ->
            ( { model | tables = tables }, Cmd.none )

        GamesChanged games ->
            ( { model | games = games }, Cmd.none )

        CancelClicked ->
            ( model, sendMessage (options.onClose model.oldScores) )

        OkClicked ->
            ( model, sendMessage (options.onClose (toScores model)) )


valuesStatus : Model -> H.Html msg
valuesStatus model =
    let
        tables =
            String.toInt model.tables |> Maybe.withDefault model.oldScores.tables

        games =
            String.toInt model.games |> Maybe.withDefault model.oldScores.games
    in
    if model.oldScores.values == model.values then
        if model.oldScores.tables <= tables && model.oldScores.games <= games then
            H.div [ cssClasses.status ]
                [ H.text "No scores will be changed"
                ]

        else
            H.div [ cssClasses.status, cssClasses.error ]
                [ H.text (String.concat [ "Will discard scores outside the board" ])
                ]

    else if Array.isEmpty model.values then
        H.div [ cssClasses.status, cssClasses.error ]
            [ H.text "Will zero all previous scores"
            ]

    else
        H.div [ cssClasses.status, cssClasses.error ]
            [ H.text "Will replace all previous scores"
            ]


lengthError : String -> String
lengthError value =
    case String.toInt value of
        Just n ->
            if n < 1 then
                "too small"

            else if n > 100 then
                "too large"

            else
                ""

        Nothing ->
            "invalid"


toScores : Model -> Scores
toScores model =
    let
        tables : Int
        tables =
            String.toInt model.tables |> Maybe.withDefault model.oldScores.tables

        games : Int
        games =
            String.toInt model.games |> Maybe.withDefault model.oldScores.games
    in
    { title = model.title
    , tables = tables
    , games = games
    , values =
        Array.initialize tables
            (\i ->
                let
                    tableValues =
                        Array.get i model.values |> Maybe.withDefault Array.empty
                in
                Array.initialize games
                    (\j -> Array.get j tableValues |> Maybe.withDefault 0)
            )
    }


handleKeyDown : KeyboardEvent -> Options m -> Model -> Maybe m
handleKeyDown event options model =
    Dialog.handleKeyDown event (dialogOptions options model)
