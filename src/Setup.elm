module Setup exposing (Model, Msg, Options, handleKeyDown, init, update, view)

import Array exposing (Array)
import Common exposing (KeyboardEvent, sendMessage)
import Dialog
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Scores exposing (Scores)


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
    | LoadClicked
    | SaveClicked
    | TitleChanged String
    | TablesChanged String
    | GamesChanged String
    | DialogAction Int


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
        (dialogModel model)
        (viewMain options model)


dialogOptions : Options m -> Model -> Dialog.Options m
dialogOptions options model =
    { disabled = options.disabled
    , route = DialogAction >> options.route
    }


dialogModel : Model -> Dialog.Model
dialogModel model =
    let
        defaults =
            Dialog.defaults
    in
    { defaults
        | title = "Setup"
        , close = Just -1
        , enter = Just 1
        , actions =
            [ Dialog.action "Cancel"
            , Dialog.action "OK" |> disableWhenError model
            ]
    }


viewMain : Options m -> Model -> List (H.Html m)
viewMain options model =
    [ H.div [ cssClasses.menu ]
        [ H.button [ HE.onClick (options.route ClearClicked) ] [ H.text "Clear" ]
        , H.button [ HE.onClick (options.route LoadClicked) ] [ H.text "Load" ]
        , H.button [ HE.onClick (options.route SaveClicked) ] [ H.text "Save" ]
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
            ( { model | values = Array.empty }, Cmd.none )

        LoadClicked ->
            ( model
            , sendMessage (options.onError "Load has not been implemented yet")
            )

        SaveClicked ->
            ( model
            , sendMessage (options.onError "Save has not been implemented yet")
            )

        TitleChanged title ->
            ( { model | title = title }, Cmd.none )

        TablesChanged tables ->
            ( { model | tables = tables }, Cmd.none )

        GamesChanged games ->
            ( { model | games = games }, Cmd.none )

        DialogAction index ->
            ( model
            , sendMessage
                (options.onClose
                    (if index < 1 then
                        model.oldScores

                     else
                        toScores model
                    )
                )
            )


disableWhenError : Model -> { a | disabled : Bool } -> { a | disabled : Bool }
disableWhenError model a =
    if lengthError model.tables /= "" || lengthError model.games /= "" then
        { a | disabled = True }

    else
        a


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
    Dialog.handleKeyDown event (dialogOptions options model) (dialogModel model)
