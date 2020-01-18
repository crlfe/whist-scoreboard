module Alert exposing (update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import State exposing (..)


view : AlertModel -> H.Html Msg
view model =
    H.div [ HA.class "aDialog" ]
        [ H.div [ HA.class "aTitle" ]
            [ H.text model.title
            , H.button [ HA.class "aX", HE.onClick (GotAlertMsg CloseClicked) ]
                [ H.text "X"
                ]
            ]
        , H.div [ HA.class "aMessage" ] model.body
        , H.div [ HA.class "aActions" ]
            [ H.button [ HE.onClick (GotAlertMsg CloseClicked) ]
                [ H.text "Close"
                ]
            ]
        ]


update : AlertMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CloseClicked ->
            ( { model
                | setup = Maybe.map (\s -> { s | inert = False }) model.setup
                , alert = Nothing
              }
            , Cmd.none
            )
