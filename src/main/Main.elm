port module Main exposing (Model, main)

import Array
import Browser
import Browser.Events
import Common exposing (KeyboardEvent, arrayGet2, decodeKeyboardEvent, isJust, listJust, xif)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Intl
import Json.Decode as JD
import Json.Encode as JE
import Scores exposing (Scores)
import Setup
import Sheet
import Ui.Dialog


port onDocumentKeyDown : (String -> msg) -> Sub msg


port capturedKeys : JD.Value -> Cmd msg


port storage : JD.Value -> Cmd msg


type alias Flags =
    { languages : List String
    , version : String
    , licenses : String
    , width : Float
    , height : Float
    , storage : JD.Value
    }


type alias Model =
    { locale : Intl.Locale
    , loc : Intl.Localized
    , version : String
    , licenses : String
    , scores : Scores
    , sheet : Sheet.Model
    , setup : Maybe Setup.Model
    , showLicenses : Bool
    , error : Maybe String
    }


type Msg
    = Noop
    | SheetMsg Sheet.Msg
    | SetupMsg Setup.Msg
    | ErrorClosed
    | SheetIncremented Int Int
    | SheetSet Int Int Int
    | SheetClearGame Int
    | SheetSetup
    | SetupClosed Scores
    | ShowLicenses
    | HideLicenses
    | ShowError String
    | LocaleChanged Intl.Locale
    | WindowResized Int Int
    | SetShowPanel Bool


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        imported =
            importStorage flags.storage

        locale =
            Maybe.map Intl.localeFromName imported.language
                |> Maybe.withDefault (Intl.localeFromLanguages flags.languages)
                |> Maybe.withDefault Intl.English

        loc =
            Intl.localize locale

        scores =
            imported.scores
                |> Maybe.withDefault (Scores.zero "" 22 18)

        model =
            { locale = locale
            , loc = loc
            , version = flags.version
            , licenses = flags.licenses
            , scores = scores
            , sheet = Sheet.init
            , setup = Nothing
            , showLicenses = False
            , error = Nothing
            }
                |> updateSheetSize flags.width flags.height
    in
    if String.isEmpty scores.title then
        let
            ( setup, cmd ) =
                Setup.init scores
        in
        ( { model | setup = Just setup }
        , Cmd.batch [ Cmd.map SetupMsg cmd, sendCapturedKeysNone ]
        )

    else
        ( model, sendCapturedKeysForSheet )


type alias Imported =
    { language : Maybe String
    , scores : Maybe Scores
    }


importStorage : JD.Value -> Imported
importStorage value =
    let
        version =
            JD.decodeValue (JD.field "version" JD.int) value
    in
    case version of
        Ok 1 ->
            Imported Nothing (importStorage1 value)

        Ok 2 ->
            importStorage2 value

        _ ->
            Imported Nothing Nothing


importStorage1 : JD.Value -> Maybe Scores
importStorage1 value =
    let
        tables =
            JD.decodeValue (JD.field "numTables" JD.int) value

        games =
            JD.decodeValue (JD.field "numGames" JD.int) value

        values =
            JD.decodeValue
                (JD.field "scoreRows"
                    (JD.array
                        (JD.oneOf
                            [ JD.array (JD.oneOf [ JD.int, JD.succeed 0 ])
                            , JD.succeed Array.empty
                            ]
                        )
                    )
                )
                value
    in
    Result.map2 (Scores.zero "") tables games
        |> Result.map2
            (\vs s ->
                Scores.indexedMap
                    (\t g _ -> arrayGet2 t g vs |> Maybe.withDefault 0)
                    s
            )
            values
        |> Result.toMaybe


importStorage2 : JD.Value -> { language : Maybe String, scores : Maybe Scores }
importStorage2 value =
    let
        language =
            JD.decodeValue (JD.field "language" JD.string) value

        title =
            JD.decodeValue (JD.field "title" JD.string) value

        tables =
            JD.decodeValue (JD.field "tables" JD.int) value

        games =
            JD.decodeValue (JD.field "games" JD.int) value

        values =
            JD.decodeValue (JD.field "values" (JD.array (JD.array JD.int))) value
    in
    { language = language |> Result.toMaybe
    , scores =
        Result.map4 Scores title tables games values
            |> Result.toMaybe
    }


view : Model -> Browser.Document Msg
view model =
    { title = model.scores.title
    , body =
        listJust
            [ Just (Sheet.view (sheetOptions model) model.sheet)
            , maybeViewBarrier model
            , Maybe.map (Setup.view (setupOptions model)) model.setup
            , xif model.showLicenses (Just (viewLicenses model)) Nothing
            , Maybe.map (viewError model) model.error
            ]
    }


maybeViewBarrier : Model -> Maybe (H.Html msg)
maybeViewBarrier model =
    if isJust model.setup || model.showLicenses || isJust model.error then
        Just (H.div [ HA.class "barrier" ] [])

    else
        Nothing


viewLicenses : Model -> H.Html Msg
viewLicenses model =
    let
        defaults =
            Ui.Dialog.defaults model.loc

        options =
            { defaults
                | title = "Licenses and Warranty Disclaimers"
                , onClose = Just HideLicenses
                , onEnter = Just HideLicenses
                , footer =
                    [ H.button [ HE.onClick HideLicenses ] [ H.text model.loc.buttons.ok ]
                    ]
            }
    in
    Ui.Dialog.view options
        [ H.div
            [ HA.style "width" "45rem"
            , HA.style "white-space" "pre-line"
            ]
            [ H.text model.licenses ]
        ]


viewError : Model -> String -> H.Html Msg
viewError model error =
    Ui.Dialog.view (errorOptions model) [ H.text error ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        SheetMsg m ->
            Sheet.update m (sheetOptions model) model.sheet
                |> Tuple.mapFirst (\s -> { model | sheet = s })

        SetupMsg m ->
            case model.setup of
                Just setup ->
                    Setup.update m (setupOptions model) setup
                        |> Tuple.mapFirst (\s -> { model | setup = Just s })

                Nothing ->
                    ( model, Cmd.none )

        ErrorClosed ->
            ( { model | error = Nothing }, sendCapturedKeysForSheet )

        SheetIncremented table game ->
            let
                scores =
                    Scores.mapOne (\v -> modBy 5 (v + 1)) table game model.scores
            in
            ( { model | scores = scores }
            , sendToStorage model.locale scores
            )

        SheetSet table game value ->
            let
                scores =
                    Scores.set table game value model.scores
            in
            ( { model | scores = scores }, sendToStorage model.locale scores )

        SheetClearGame game ->
            let
                scores =
                    Scores.indexedMap (\_ g v -> xif (g == game) 0 v) model.scores
            in
            ( { model | scores = scores }, Cmd.none )

        SheetSetup ->
            let
                ( setup, cmd ) =
                    Setup.init model.scores
            in
            ( { model | setup = Just setup }
            , Cmd.batch [ Cmd.map SetupMsg cmd, sendCapturedKeysNone ]
            )

        SetupClosed scores ->
            ( { model | scores = scores, setup = Nothing }
            , Cmd.batch [ sendToStorage model.locale scores, sendCapturedKeysForSheet ]
            )

        ShowLicenses ->
            ( { model | showLicenses = True }, sendCapturedKeysNone )

        HideLicenses ->
            ( { model | showLicenses = False }, sendCapturedKeysForSheet )

        ShowError error ->
            ( { model | error = Just error }, sendCapturedKeysNone )

        LocaleChanged locale ->
            ( { model
                | locale = locale
                , loc = Intl.localize locale
              }
            , sendToStorage locale model.scores
            )

        WindowResized width height ->
            ( updateSheetSize (toFloat width) (toFloat height) model, Cmd.none )

        SetShowPanel value ->
            let
                sheet =
                    model.sheet
            in
            ( { model | sheet = { sheet | showPanel = value } }, Cmd.none )


updateSheetSize : Float -> Float -> Model -> Model
updateSheetSize width height model =
    let
        sheet =
            model.sheet
    in
    { model | sheet = { sheet | maxWidth = width, maxHeight = height } }


sendToStorage : Intl.Locale -> Scores -> Cmd Msg
sendToStorage locale scores =
    storage
        (JE.object
            [ ( "version", JE.int 2 )
            , ( "language", JE.string (Intl.localeName locale) )
            , ( "title", JE.string scores.title )
            , ( "tables", JE.int scores.tables )
            , ( "games", JE.int scores.games )
            , ( "values", JE.array (JE.array JE.int) scores.values )
            ]
        )


sendCapturedKeysForSheet : Cmd Msg
sendCapturedKeysForSheet =
    capturedKeys (JE.list JE.string [ "ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight" ])


sendCapturedKeysNone : Cmd Msg
sendCapturedKeysNone =
    capturedKeys (JE.list JE.string [])


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize WindowResized
        , onDocumentKeyDown (\k -> Maybe.withDefault Noop (handleKeyDown model k))
        ]


handleKeyDown : Model -> String -> Maybe Msg
handleKeyDown model key =
    case model.error of
        Just _ ->
            Ui.Dialog.handleKeyDown key (errorOptions model)

        Nothing ->
            case model.setup of
                Just setup ->
                    Setup.handleKeyDown key (setupOptions model) setup

                Nothing ->
                    Sheet.handleKeyDown key (sheetOptions model) model.sheet


sheetOptions : Model -> Sheet.Options Msg
sheetOptions model =
    { loc = model.loc
    , disabled =
        isJust model.setup
            || model.showLicenses
            || isJust model.error
    , scores = model.scores
    , route = SheetMsg
    , onIncrement = SheetIncremented
    , onSet = SheetSet
    , onClearGame = SheetClearGame
    , onSetup = SheetSetup
    }


setupOptions : Model -> Setup.Options Msg
setupOptions model =
    { loc = model.loc
    , version = model.version
    , disabled =
        model.showLicenses
            || isJust model.error
    , route = SetupMsg
    , onClose = SetupClosed
    , onError = ShowError
    , onLocale = LocaleChanged
    , onShowLicenses = ShowLicenses
    , showPanel = model.sheet.showPanel
    , setShowPanel = SetShowPanel
    }


errorOptions : Model -> Ui.Dialog.Options Msg
errorOptions model =
    Ui.Dialog.error
        { loc = model.loc
        , onClose = ErrorClosed
        }
