port module Main exposing (Model, main)

import Array exposing (Array)
import Browser
import Browser.Dom
import Browser.Events
import Common exposing (KeyboardEvent, arrayGet2, decodeKeyboardEvent)
import Dialog
import Html as H
import Html.Attributes as HA
import Intl
import Json.Decode as JD
import Json.Encode as JE
import Maybe.Extra
import Scores exposing (Scores)
import Setup
import Sheet
import Task
import Time


port storage : JD.Value -> Cmd msg


type alias Flags =
    { languages : List String
    , width : Float
    , height : Float
    , storage : JD.Value
    }


type alias Model =
    { locale : Intl.Locale
    , loc : Intl.Localized
    , scores : Scores
    , sheet : Sheet.Model
    , setup : Maybe Setup.Model
    , error : Maybe String
    }


type Msg
    = Noop
    | StartingGotTime ( Time.Zone, Time.Posix )
    | SheetMsg Sheet.Msg
    | SetupMsg Setup.Msg
    | ErrorClosed
    | SheetIncremented Int Int
    | SheetSetup
    | SetupClosed Scores
    | ShowError String
    | LocaleChanged Intl.Locale
    | WindowResized Int Int


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
                |> (\s ->
                        { s
                            | title =
                                if s.title /= "" then
                                    s.title

                                else
                                    loc.status.whistEvent
                        }
                   )

        model =
            { locale = locale
            , loc = loc
            , scores = scores
            , sheet = Sheet.init
            , setup = Nothing
            , error = Nothing
            }
                |> updateSheetSize flags.width flags.height
    in
    ( model
    , if imported.scores == Nothing then
        Task.perform StartingGotTime (Task.map2 Tuple.pair Time.here Time.now)

      else
        Cmd.none
    )


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
        Maybe.Extra.values
            [ Just (Sheet.view (sheetOptions model) model.sheet)
            , maybeViewBarrier model
            , Maybe.map (Setup.view (setupOptions model)) model.setup
            , Maybe.map (viewError model) model.error
            ]
    }


maybeViewBarrier : Model -> Maybe (H.Html msg)
maybeViewBarrier model =
    if Maybe.Extra.isJust model.setup || Maybe.Extra.isJust model.error then
        Just (H.div [ HA.class "barrier" ] [])

    else
        Nothing


viewError : Model -> String -> H.Html Msg
viewError model error =
    Dialog.view (errorOptions model) [ H.text error ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        StartingGotTime ( here, now ) ->
            let
                oldScores =
                    model.scores

                newScores =
                    { oldScores
                        | title = model.loc.status.whistEventDated here now
                    }
            in
            ( { model | scores = newScores }, Cmd.none )

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
            ( { model | error = Nothing }, Cmd.none )

        SheetIncremented table game ->
            let
                scores =
                    Scores.mapOne (\v -> modBy 5 (v + 1)) table game model.scores
            in
            ( { model | scores = scores }
            , sendToStorage model.locale scores
            )

        SheetSetup ->
            ( { model | setup = Just (Setup.init model.scores) }
            , Task.attempt (\_ -> Noop) (Browser.Dom.focus "sTitle")
            )

        SetupClosed scores ->
            ( { model | scores = scores, setup = Nothing }
            , sendToStorage model.locale scores
            )

        ShowError error ->
            ( { model | error = Just error }, Cmd.none )

        LocaleChanged locale ->
            ( { model
                | locale = locale
                , loc = Intl.localize locale
              }
            , sendToStorage locale model.scores
            )

        WindowResized width height ->
            ( updateSheetSize (toFloat width) (toFloat height) model, Cmd.none )


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown (decodeKeyDown model)
        , Browser.Events.onResize WindowResized
        ]


decodeKeyDown : Model -> JD.Decoder Msg
decodeKeyDown model =
    decodeKeyboardEvent
        |> JD.andThen
            (\event ->
                Maybe.Extra.unwrap
                    (JD.fail "ignored input")
                    JD.succeed
                    (handleKeyDown model event)
            )


handleKeyDown : Model -> KeyboardEvent -> Maybe Msg
handleKeyDown model event =
    case model.error of
        Just _ ->
            Dialog.handleKeyDown event (errorOptions model)

        Nothing ->
            case model.setup of
                Just setup ->
                    Setup.handleKeyDown event (setupOptions model) setup

                Nothing ->
                    Sheet.handleKeyDown event (sheetOptions model) model.sheet


sheetOptions : Model -> Sheet.Options Msg
sheetOptions model =
    { loc = model.loc
    , disabled = Maybe.Extra.isJust model.error || Maybe.Extra.isJust model.setup
    , scores = model.scores
    , route = SheetMsg
    , onIncrement = SheetIncremented
    , onSetup = SheetSetup
    }


setupOptions : Model -> Setup.Options Msg
setupOptions model =
    { loc = model.loc
    , disabled = Maybe.Extra.isJust model.error
    , route = SetupMsg
    , onClose = SetupClosed
    , onError = ShowError
    , onLocale = LocaleChanged
    }


errorOptions : Model -> Dialog.Options Msg
errorOptions model =
    Dialog.error
        { loc = model.loc
        , onClose = ErrorClosed
        }
