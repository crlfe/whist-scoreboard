module Dialog exposing (Model, ModelAction, Msg, Options, action, defaults, error, handleKeyDown, view)

import Common exposing (KeyboardEvent, xif)
import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias Options m =
    { disabled : Bool
    , route : Int -> m
    }


type alias Model =
    { title : String
    , titleColor : String
    , headerColor : String
    , close : Maybe Int
    , enter : Maybe Int
    , actions : List ModelAction
    }


type alias ModelAction =
    { text : String
    , id : Maybe String
    , disabled : Bool
    }


type alias Msg =
    Int


cssClasses =
    Common.cssClasses.dialog


action : String -> ModelAction
action text =
    { text = text, id = Nothing, disabled = False }


defaults : Model
defaults =
    { title = "Message"
    , titleColor = "#000"
    , headerColor = "#AAF"
    , close = Just -1
    , enter = Nothing
    , actions = []
    }


error : Model
error =
    { defaults
        | title = "Error"
        , headerColor = "#F88"
        , enter = Just 0
        , actions =
            [ action "OK" ]
    }


view : Options m -> Model -> List (H.Html m) -> H.Html m
view options model body =
    H.div [ cssClasses.dialog ] <|
        viewHeader options model
            ++ body
            ++ viewFooter options model


viewHeader : Options m -> Model -> List (H.Html m)
viewHeader options model =
    [ H.header
        [ HA.style "background-color" model.headerColor
        ]
        (H.div
            [ cssClasses.title
            , HA.style "color" model.titleColor
            , HA.style "opacity" (xif options.disabled "25%" "100%")
            ]
            [ H.text model.title ]
            :: (case model.close of
                    Just _ ->
                        [ viewHeaderClose options model ]

                    Nothing ->
                        []
               )
        )
    ]


viewHeaderClose : Options m -> Model -> H.Html m
viewHeaderClose options model =
    H.button [ HA.disabled options.disabled, HE.onClick (options.route -1) ]
        [ H.img
            [ HA.src "close.svg"
            , HA.alt "Close"
            , HA.style "opacity" (xif options.disabled "25%" "100%")
            ]
            []
        ]


viewFooter : Options m -> Model -> List (H.Html m)
viewFooter options model =
    if List.isEmpty model.actions then
        []

    else
        [ H.footer []
            (List.indexedMap (viewFooterAction options model) model.actions)
        ]


viewFooterAction : Options m -> Model -> Msg -> ModelAction -> H.Html m
viewFooterAction options model index am =
    let
        attrs =
            [ cssClasses.action
            , HA.disabled (options.disabled || am.disabled)
            , HE.onClick (options.route index)
            ]
                |> (\rest ->
                        case am.id of
                            Just id ->
                                HA.id id :: rest

                            Nothing ->
                                rest
                   )
    in
    H.button attrs [ H.text am.text ]


handleKeyDown : KeyboardEvent -> Options m -> Model -> Maybe m
handleKeyDown event options model =
    case event.key of
        "Escape" ->
            Maybe.map options.route model.close

        _ ->
            Nothing
