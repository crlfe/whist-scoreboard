module Main exposing (Model, main)

import Browser
import Browser.Dom
import Browser.Events
import Common exposing (KeyboardEvent, decodeKeyboardEvent)
import Dialog
import Html as H
import Html.Attributes as HA
import Json.Decode as JD
import Maybe.Extra
import Scores exposing (Scores)
import Setup
import Sheet
import Task


type alias Flags =
    ()


type alias Model =
    { scores : Scores
    , sheet : Sheet.Model
    , setup : Maybe Setup.Model
    , error : Maybe String
    }


type Msg
    = SheetMsg Sheet.Msg
    | SetupMsg Setup.Msg
    | ErrorMsg Int
    | SheetIncremented Int Int
    | SheetSetup
    | SetupClosed Scores
    | SetupError String
    | InitialViewport Browser.Dom.Viewport
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
init _ =
    let
        scores =
            Scores.fromLists "Arbitrary title"
                [ [ 1, 4, 1, 1, 0, 1, 1, 2, 0 ]
                , [ 0, 0, 1, 1, 0, 1, 1, 2, 1 ]
                , [ 1, 3, 1, 1, 0, 1, 1, 2, 0 ]
                , [ 2, 0, 1, 1, 0, 1, 1, 2, 2 ]
                , [ 0, 0, 1, 1, 0, 1, 1, 2, 1 ]
                , [ 1, 0, 1, 1, 0, 1, 1, 2, 0 ]
                ]
    in
    ( { scores = scores
      , sheet = Sheet.init
      , setup = Nothing
      , error = Nothing
      }
    , Task.perform InitialViewport Browser.Dom.getViewport
    )


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
            ( { model | scores = scores }, Cmd.none )

        SheetSetup ->
            ( { model | setup = Just (Setup.init model.scores) }, Cmd.none )

        SetupClosed scores ->
            ( { model | scores = scores, setup = Nothing }, Cmd.none )

        SetupError error ->
            ( { model | error = Just error }, Cmd.none )

        InitialViewport info ->
            ( updateSheetSize info.viewport.width info.viewport.height model, Cmd.none )

        WindowResized width height ->
            ( updateSheetSize (toFloat width) (toFloat height) model, Cmd.none )


updateSheetSize : Float -> Float -> Model -> Model
updateSheetSize width height model =
    let
        sheet =
            model.sheet
    in
    { model | sheet = { sheet | maxWidth = width, maxHeight = height } }


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
    , onError = SetupError
    }


errorOptions : Dialog.Options Msg
errorOptions =
    { disabled = False
    , route = ErrorMsg
    }
