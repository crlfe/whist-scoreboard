port module Main exposing (Model, main)

import Array exposing (Array)
import Browser
import Browser.Dom
import Browser.Events
import Common exposing (KeyboardEvent, arrayGet2, decodeKeyboardEvent)
import Dialog
import Html as H
import Html.Attributes as HA
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
    { width : Float
    , height : Float
    , storage : JD.Value
    }


type alias Model =
    { scores : Scores
    , sheet : Sheet.Model
    , setup : Maybe Setup.Model
    , error : Maybe String
    }


type Msg
    = Noop
    | StartingGotTime ( Time.Zone, Time.Posix )
    | SheetMsg Sheet.Msg
    | SetupMsg Setup.Msg
    | ErrorMsg Int
    | SheetIncremented Int Int
    | SheetSetup
    | SetupClosed Scores
    | ShowError String
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
        scores =
            importStorage flags.storage

        model =
            { scores =
                scores
                    |> Maybe.withDefault (Scores.zero "Whist Event" 22 18)
            , sheet = Sheet.init
            , setup = Nothing
            , error = Nothing
            }
                |> updateSheetSize flags.width flags.height
    in
    ( model
    , if scores == Nothing then
        Task.perform StartingGotTime (Task.map2 Tuple.pair Time.here Time.now)

      else
        Cmd.none
    )


importStorage : JD.Value -> Maybe Scores
importStorage value =
    let
        version =
            JD.decodeValue (JD.field "version" JD.int) value
    in
    case version of
        Ok 1 ->
            importStorage1 value

        Ok 2 ->
            importStorage2 value

        _ ->
            Nothing


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
    Result.map2 (Scores.zero "Whist Event") tables games
        |> Result.map2
            (\vs s ->
                Scores.indexedMap
                    (\t g _ -> arrayGet2 t g vs |> Maybe.withDefault 0)
                    s
            )
            values
        |> Result.toMaybe


importStorage2 : JD.Value -> Maybe Scores
importStorage2 value =
    let
        title =
            JD.decodeValue (JD.field "title" JD.string) value

        tables =
            JD.decodeValue (JD.field "tables" JD.int) value

        games =
            JD.decodeValue (JD.field "games" JD.int) value

        values =
            JD.decodeValue (JD.field "values" (JD.array (JD.array JD.int))) value
    in
    Result.map4 Scores title tables games values
        |> Result.toMaybe


view : Model -> Browser.Document Msg
view model =
    { title = model.scores.title
    , body =
        Maybe.Extra.values
            [ Just (Sheet.view (sheetOptions model) model.sheet)
            , maybeViewBarrier model
            , Maybe.map (Setup.view (setupOptions model)) model.setup
            , Maybe.map viewError model.error
            ]
    }


maybeViewBarrier : Model -> Maybe (H.Html msg)
maybeViewBarrier model =
    if Maybe.Extra.isJust model.setup || Maybe.Extra.isJust model.error then
        Just (H.div [ HA.class "barrier" ] [])

    else
        Nothing


viewError : String -> H.Html Msg
viewError text =
    Dialog.view errorOptions Dialog.error [ H.text text ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        StartingGotTime ( here, now ) ->
            let
                scores =
                    model.scores
            in
            ( { model | scores = { scores | title = Scores.datedTitle here now } }
            , Cmd.none
            )

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

        ErrorMsg _ ->
            ( { model | error = Nothing }, Cmd.none )

        SheetIncremented table game ->
            let
                scores =
                    Scores.mapOne (\v -> modBy 5 (v + 1)) table game model.scores
            in
            ( { model | scores = scores }
            , sendScoresToStorage scores
            )

        SheetSetup ->
            ( { model | setup = Just (Setup.init model.scores) }
            , Task.attempt (\_ -> Noop) (Browser.Dom.focus "sTitle")
            )

        SetupClosed scores ->
            ( { model | scores = scores, setup = Nothing }
            , sendScoresToStorage scores
            )

        ShowError error ->
            ( { model | error = Just error }, Cmd.none )

        WindowResized width height ->
            ( updateSheetSize (toFloat width) (toFloat height) model, Cmd.none )


updateSheetSize : Float -> Float -> Model -> Model
updateSheetSize width height model =
    let
        sheet =
            model.sheet
    in
    { model | sheet = { sheet | maxWidth = width, maxHeight = height } }


sendScoresToStorage : Scores -> Cmd Msg
sendScoresToStorage scores =
    storage
        (JE.object
            [ ( "version", JE.int 2 )
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
            Dialog.handleKeyDown event errorOptions Dialog.error

        Nothing ->
            case model.setup of
                Just setup ->
                    Setup.handleKeyDown event (setupOptions model) setup

                Nothing ->
                    Sheet.handleKeyDown event (sheetOptions model) model.sheet


sheetOptions : Model -> Sheet.Options Msg
sheetOptions model =
    { disabled = Maybe.Extra.isJust model.error || Maybe.Extra.isJust model.setup
    , scores = model.scores
    , route = SheetMsg
    , onIncrement = SheetIncremented
    , onSetup = SheetSetup
    }


setupOptions : Model -> Setup.Options Msg
setupOptions model =
    { disabled = Maybe.Extra.isJust model.error
    , route = SetupMsg
    , onClose = SetupClosed
    , onError = ShowError
    }


errorOptions : Dialog.Options Msg
errorOptions =
    { disabled = False
    , route = ErrorMsg
    }
