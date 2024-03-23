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


type alias Options m =
    { loc : Intl.Localized
    , version : String
    , disabled : Bool
    , route : Msg -> m
    , onClose : Scores -> m
    , onError : String -> m
    , onLocale : Intl.Locale -> m
    , onShowLicenses : m
    , showPanel : Bool
    , setShowPanel : Bool -> m
    }


type alias Model =
    { oldScores : Scores
    , tab : CurrentTab
    , title : String
    , tables : String
    , games : String
    , values : Array (Array Int)
    }


type CurrentTab
    = SetupTab
    | AboutTab


type Msg
    = InitCreateTitle ( Time.Zone, Time.Posix )
    | SetupTabClicked
    | AboutTabClicked
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
      , tab = SetupTab
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
    H.div
        [ cssDialog.dialogOuter
        ]
        [ H.div
            [ cssDialog.dialogInner
            , HA.style "width" "22rem"
            ]
            [ H.div
                [ cssDialog.dialog ]
                [ viewHeader options model
                , viewSetup options model
                , viewAbout options model
                ]
            ]
        ]


viewHeader : Options m -> Model -> H.Html m
viewHeader options model =
    H.header [ HA.style "background-color" "#ddf" ]
        [ H.div
            [ cssDialog.title
            , HA.style "padding" "0"
            , HA.style "opacity" (xif options.disabled "25%" "100%")
            , HA.style "display" "grid"
            , HA.style "grid-template-columns" "repeat(2, 7.5rem)"
            , HA.style "grid-template-rows" "2rem"
            , HA.style "place-content" "start"
            , HA.style "place-items" "stretch"
            ]
            [ H.div
                [ HA.class "tTabActive"
                , HA.style "grid-area" "1 / 1"
                , HA.style "transform"
                    (String.concat
                        [ "translate("
                        , case model.tab of
                            SetupTab ->
                                "0rem"

                            AboutTab ->
                                "7.5rem"
                        , ")"
                        ]
                    )
                ]
                []
            , H.button
                [ HA.class "tTab"
                , HA.disabled options.disabled
                , HA.style "grid-area" "1 / 1"
                , HE.onClick
                    (options.route SetupTabClicked)
                ]
                [ H.text options.loc.labels.setup ]
            , H.button
                [ HA.class "tTab"
                , HA.disabled options.disabled
                , HA.style "grid-area" "1 / 2"
                , HE.onClick
                    (options.route AboutTabClicked)
                ]
                [ H.text options.loc.labels.about ]
            ]
        , viewHeaderClose options (options.route CancelClicked)
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


viewSetup : Options m -> Model -> H.Html m
viewSetup options model =
    let
        disabled =
            options.disabled || model.tab /= SetupTab
    in
    H.div
        [ HA.class
            (if model.tab == SetupTab then
                "tTabContent active"

             else
                "tTabContent"
            )
        , HA.style "grid-area" "2 / 1"
        ]
        [ H.div
            [ cssClasses.fields
            , HA.style "margin-top" "-0.5rem"
            , HA.style "grid-template-columns" "auto 1fr"
            ]
            [ H.label [ HA.for "sLanguage" ]
                [ H.text options.loc.labels.language ]
            , Html.Keyed.node "select"
                [ HA.id "sLanguage"
                , HA.disabled disabled
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
                [ HA.disabled disabled
                , HE.onClick (options.route ClearClicked)
                ]
                [ H.text options.loc.buttons.new ]
            , H.button
                [ HA.disabled disabled
                , HE.onClick (options.route LoadClicked)
                ]
                [ H.text options.loc.buttons.open ]
            , H.button
                [ HA.disabled disabled
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
                , HA.disabled disabled
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
                , HA.disabled disabled
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
                , HA.disabled disabled
                , HE.onInput (options.route << GamesChanged)
                ]
                []
            , H.label [ cssClasses.error ] [ H.text (lengthError options model.games) ]
            ]
        , valuesStatus options model
        , let
            inputHasError =
                (lengthError options model.tables /= "")
                    || (lengthError options model.games /= "")
          in
          H.footer [ HA.class "tMenu" ]
            [ H.button
                [ HA.disabled disabled
                , HE.onClick (options.route CancelClicked)
                ]
                [ H.text options.loc.buttons.cancel ]
            , H.button
                [ HA.disabled (disabled || inputHasError)
                , HE.onClick (options.route OkClicked)
                ]
                [ H.text options.loc.buttons.ok ]
            ]
        ]


viewAbout : Options m -> Model -> H.Html m
viewAbout options model =
    let
        disabled =
            options.disabled || model.tab /= AboutTab
    in
    H.div
        [ HA.class
            (if model.tab == AboutTab then
                "tTabContent active"

             else
                "tTabContent"
            )
        , HA.style "grid-area" "2 / 1"
        , HA.style "grid-template-rows" "1fr 2.5rem 2.5rem"
        ]
        [ H.div
            [ HA.style "line-height" "1.5"
            , HA.style "white-space" "pre-line"
            ]
            [ H.text ("Whist Scoreboard " ++ options.version ++ "\nby Chris Wolfe (")
            , webLink [ HA.disabled disabled, HA.href "https://crlfe.ca/" ] [ H.text "https://crlfe.ca/" ]
            , H.text ")\n\n"
            , H.text "This software is freely available under a BSD license, and the source is "
            , webLink [ HA.disabled disabled, HA.href "https://github.com/crlfe/whist-scoreboard/" ] [ H.text "shared on GitHub" ]
            , H.text ". If you enjoy this software, please consider following me on "
            , webLink [ HA.disabled disabled, HA.href "https://twitter.com/crlfe/" ] [ H.text "Twitter" ]
            , H.text " and supporting my work through "
            , webLink [ HA.disabled disabled, HA.href "https://patreon.com/crlfe/" ] [ H.text "Patreon" ]
            , H.text "."
            ]
        , H.div [ HA.class "tMenu" ]
            [ H.label []
                [ H.input
                    [ HA.type_ "checkbox"
                    , HA.style "margin-right" "0.5em"
                    , HA.checked options.showPanel
                    , HE.onCheck options.setShowPanel
                    ]
                    []
                , H.text "Show side panel"
                ]
            ]
        , H.div [ HA.class "tMenu" ]
            [ H.button
                [ HA.disabled disabled
                , HE.onClick options.onShowLicenses
                ]
                [ H.text "Licenses and Warranty Disclaimers" ]
            ]
        , H.footer [ HA.class "tMenu" ]
            [ H.button
                [ HA.disabled disabled
                , HE.onClick (options.route CancelClicked)
                ]
                [ H.text options.loc.buttons.close ]
            ]
        ]


webLink : List (H.Attribute m) -> List (H.Html m) -> H.Html m
webLink attrs body =
    let
        disabled =
            List.any (\x -> x == HA.disabled True) attrs

        childAttrs =
            List.filter (\x -> x /= HA.disabled True) attrs
                ++ [ HA.rel "noopener", HA.target "_blank" ]
    in
    if disabled then
        H.span childAttrs body

    else
        H.a childAttrs body


update : Msg -> Options m -> Model -> ( Model, Cmd m )
update msg options model =
    case msg of
        InitCreateTitle ( here, now ) ->
            ( { model
                | title = options.loc.status.whistEventDated here now
              }
            , Cmd.none
            )

        SetupTabClicked ->
            ( { model | tab = SetupTab }, Cmd.none )

        AboutTabClicked ->
            ( { model | tab = AboutTab }, Cmd.none )

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
            H.div [ cssClasses.status ] []

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


handleKeyDown : String -> Options m -> Model -> Maybe m
handleKeyDown key options _ =
    case key of
        "Escape" ->
            Just (options.route CancelClicked)

        _ ->
            Nothing
