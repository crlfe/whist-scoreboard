module Setup exposing (Model, Msg, Options, handleKeyDown, init, update, view)

import Array exposing (Array)
import Common exposing (KeyboardEvent, sendMessage, xif)
import File
import File.Download
import File.Select
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed
import Intl
import Scores exposing (Scores)
import Scores.Csv
import Task
import Time
import Ui.Dialog


type alias Options m =
    { loc : Intl.Localized
    , disabled : Bool
    , route : Msg -> m
    , onClose : Scores -> m
    , onError : String -> m
    , onLocale : Intl.Locale -> m
    , onShowLicenses : m
    }


type alias Model =
    { oldScores : Scores
    , title : String
    , tables : String
    , games : String
    , values : Array (Array Int)
    }


type Msg
    = InitCreateTitle ( Time.Zone, Time.Posix )
    | LanguageChanged String
    | ClearClicked
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


cssDialog =
    Common.cssClasses.dialog


init : Scores -> ( Model, Cmd Msg )
init scores =
    ( { oldScores = scores
      , title = scores.title
      , tables = String.fromInt scores.tables
      , games = String.fromInt scores.games
      , values = scores.values
      }
    , if String.isEmpty scores.title then
        Task.perform
            InitCreateTitle
            (Task.map2 Tuple.pair Time.here Time.now)

      else
        Cmd.none
    )


view : Options m -> Model -> H.Html m
view options model =
    H.div [ cssDialog.dialogOuter ]
        [ H.div [ cssDialog.dialogInner ]
            [ H.div [ cssDialog.dialog ]
                (viewHeader options
                    ++ viewMain options model
                    ++ viewFooter options model
                )
            ]
        ]


viewHeader : Options m -> List (H.Html m)
viewHeader options =
    let
        titleDiv =
            H.div
                [ cssDialog.title
                , HA.style "opacity" (xif options.disabled "25%" "100%")
                ]
                [ H.text options.loc.labels.setup ]
    in
    [ H.header
        [ HA.style "background-color" "#AAF" ]
        [ titleDiv
        , viewHeaderClose options (options.route CancelClicked)
        ]
    ]


viewHeaderClose : Options m -> m -> H.Html m
viewHeaderClose options onClose =
    H.button [ HA.disabled options.disabled, HE.onClick onClose ]
        [ H.img
            [ HA.style "grid-area" "1 / -1"
            , HA.src "close.svg"
            , HA.alt options.loc.buttons.close
            , HA.style "opacity" (xif options.disabled "25%" "100%")
            ]
            []
        ]


viewFooter : Options m -> Model -> List (H.Html m)
viewFooter options model =
    let
        inputHasError =
            (lengthError options model.tables /= "")
                || (lengthError options model.games /= "")
    in
    [ H.footer []
        [ H.button
            [ HA.disabled options.disabled
            , HE.onClick (options.route CancelClicked)
            ]
            [ H.text options.loc.buttons.cancel ]
        , H.button
            [ HA.disabled (options.disabled || inputHasError)
            , HE.onClick (options.route OkClicked)
            ]
            [ H.text options.loc.buttons.ok ]
        ]
    ]


dialogOptions : Options m -> Model -> Ui.Dialog.Options m
dialogOptions options model =
    let
        localized =
            Ui.Dialog.defaults options.loc

        inputHasError =
            (lengthError options model.tables /= "")
                || (lengthError options model.games /= "")
    in
    { localized
        | disabled = options.disabled
        , title = options.loc.labels.setup
        , onClose = Just (options.route CancelClicked)
        , onEnter = Just (options.route OkClicked)
        , footer =
            [ H.button
                [ HA.disabled options.disabled
                , HE.onClick (options.route CancelClicked)
                ]
                [ H.text options.loc.buttons.cancel ]
            , H.button
                [ HA.disabled (options.disabled || inputHasError)
                , HE.onClick (options.route OkClicked)
                ]
                [ H.text options.loc.buttons.ok ]
            ]
    }


viewMain : Options m -> Model -> List (H.Html m)
viewMain options model =
    [ H.div
        [ cssClasses.fields
        , HA.style "margin-top" "-0.5rem"
        , HA.style "grid-template-columns" "auto 1fr"
        ]
        [ H.label [ HA.for "sLanguage" ]
            [ H.text options.loc.labels.language ]
        , Html.Keyed.node "select"
            [ HA.id "sLanguage"
            , HA.disabled options.disabled
            , HE.onInput (LanguageChanged >> options.route)
            ]
            (Intl.localeDisplayNames
                |> List.sortWith
                    (\( x, _ ) ( y, _ ) ->
                        if x == options.loc.name then
                            if y == options.loc.name then
                                EQ

                            else
                                LT

                        else if y == options.loc.name then
                            GT

                        else
                            compare x y
                    )
                |> List.map
                    (\( code, name ) ->
                        ( code
                        , H.option
                            [ HA.selected (code == options.loc.name)
                            , HA.value code
                            ]
                            [ H.text name ]
                        )
                    )
            )
        ]
    , H.div [ cssClasses.menu ]
        [ H.button
            [ HA.disabled options.disabled
            , HE.onClick (options.route ClearClicked)
            ]
            [ H.text options.loc.buttons.new ]
        , H.button
            [ HA.disabled options.disabled
            , HE.onClick (options.route LoadClicked)
            ]
            [ H.text options.loc.buttons.open ]
        , H.button
            [ HA.disabled options.disabled
            , HE.onClick (options.route SaveClicked)
            ]
            [ H.text options.loc.buttons.save ]
        ]
    , H.div [ cssClasses.fields ]
        [ H.label [ HA.for "sTitle" ]
            [ H.text options.loc.labels.title ]
        , H.input
            [ HA.id "sTitle"
            , HA.value model.title
            , HA.disabled options.disabled
            , HE.onInput (options.route << TitleChanged)
            ]
            []
        , H.label [ HA.for "sTables" ]
            [ H.text options.loc.labels.tables ]
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
        , H.label [ cssClasses.error ] [ H.text (lengthError options model.tables) ]
        , H.label [ HA.for "sGames" ]
            [ H.text options.loc.labels.games ]
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
        , H.label [ cssClasses.error ] [ H.text (lengthError options model.games) ]
        ]
    , valuesStatus options model
    ]


update : Msg -> Options m -> Model -> ( Model, Cmd m )
update msg options model =
    case msg of
        InitCreateTitle ( here, now ) ->
            ( { model
                | title = options.loc.status.whistEventDated here now
              }
            , Cmd.none
            )

        LanguageChanged name ->
            case Intl.localeFromName name of
                Just locale ->
                    ( model, sendMessage (options.onLocale locale) )

                Nothing ->
                    ( model, Cmd.none )

        ClearClicked ->
            ( model
            , Task.perform
                (ClearingGotTime >> options.route)
                (Task.map2 Tuple.pair Time.here Time.now)
            )

        ClearingGotTime ( here, now ) ->
            ( { model
                | title = options.loc.status.whistEventDated here now
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


valuesStatus : Options m -> Model -> H.Html msg
valuesStatus options model =
    let
        tables =
            String.toInt model.tables |> Maybe.withDefault model.oldScores.tables

        games =
            String.toInt model.games |> Maybe.withDefault model.oldScores.games
    in
    if model.oldScores.values == model.values then
        if model.oldScores.tables <= tables && model.oldScores.games <= games then
            H.div [ cssClasses.status ]
                [ H.text options.loc.status.valuesUnchanged ]

        else
            H.div [ cssClasses.status, cssClasses.error ]
                [ H.text options.loc.status.valuesCropped ]

    else if Array.isEmpty model.values then
        H.div [ cssClasses.status, cssClasses.error ]
            [ H.text options.loc.status.valuesCleared ]

    else
        H.div [ cssClasses.status, cssClasses.error ]
            [ H.text options.loc.status.valuesReplaced ]


lengthError : Options m -> String -> String
lengthError options value =
    case String.toInt value of
        Just n ->
            if n < 1 then
                options.loc.status.lengthTooSmall

            else if n > 100 then
                options.loc.status.lengthTooLarge

            else
                ""

        Nothing ->
            options.loc.status.lengthInvalid


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
    case event.key of
        "Escape" ->
            Just (options.route CancelClicked)

        _ ->
            Nothing
