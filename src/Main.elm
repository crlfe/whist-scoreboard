module Main exposing (main)

import Alert
import Browser
import Html as H
import Html.Attributes as HA
import Setup
import Sheet
import State exposing (..)


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    let
        sheet =
            Sheet.init
    in
    ( { sheet = sheet
      , setup =
            if True then
                Nothing

            else
                Just
                    { inert = False
                    , title = sheet.title
                    , games = String.fromInt sheet.games
                    , tables = String.fromInt sheet.tables
                    , oldValues = sheet.values
                    , newValues = sheet.values
                    }
      , alert =
            if True then
                Nothing

            else
                Just
                    { title = "Error"
                    , body = [ H.text "This is a text message." ]
                    }
      }
    , Cmd.none
    )


view : Model -> Browser.Document Msg
view model =
    let
        popups =
            List.filterMap
                identity
                [ Maybe.map Setup.view model.setup
                , Maybe.map Alert.view model.alert
                ]
    in
    { title = model.sheet.title
    , body =
        Sheet.view model
            :: (if List.isEmpty popups then
                    []

                else
                    H.div [ HA.class "barrier" ] []
                        :: popups
               )
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSheetMsg m ->
            Sheet.update m model

        GotSetupMsg m ->
            Setup.update m model

        GotAlertMsg m ->
            Alert.update m model

        Ignored ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
