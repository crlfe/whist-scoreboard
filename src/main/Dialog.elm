module Dialog exposing (Options, defaults, error, handleKeyDown, view)

import Common exposing (KeyboardEvent, xif)
import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias Options m =
    { disabled : Bool
    , title : String
    , titleColor : String
    , headerColor : String
    , footer : List (H.Html m)
    , onClose : Maybe m
    , onEnter : Maybe m
    }


cssClasses =
    Common.cssClasses.dialog


defaults : Options m
defaults =
    { disabled = False
    , title = "Message"
    , titleColor = "#000"
    , headerColor = "#AAF"
    , onClose = Nothing
    , onEnter = Nothing
    , footer = []
    }


error : m -> Options m
error onClose =
    { defaults
        | title = "Error"
        , headerColor = "#F88"
        , onClose = Just onClose
        , onEnter = Just onClose
        , footer =
            [ H.button [ HE.onClick onClose ] [ H.text "OK" ]
            ]
    }


view : Options m -> List (H.Html m) -> H.Html m
view options body =
    H.div [ cssClasses.dialogOuter ]
        [ H.div [ cssClasses.dialogInner ]
            [ H.div [ cssClasses.dialog ]
                (viewHeader options
                    ++ body
                    ++ viewFooter options
                )
            ]
        ]


viewHeader : Options m -> List (H.Html m)
viewHeader options =
    [ H.header
        [ HA.style "background-color" options.headerColor
        ]
        (H.div
            [ cssClasses.title
            , HA.style "color" options.titleColor
            , HA.style "opacity" (xif options.disabled "25%" "100%")
            ]
            [ H.text options.title ]
            :: (case options.onClose of
                    Just onClose ->
                        [ viewHeaderClose options onClose ]

                    Nothing ->
                        []
               )
        )
    ]


viewHeaderClose : Options m -> m -> H.Html m
viewHeaderClose options onClose =
    H.button [ HA.disabled options.disabled, HE.onClick onClose ]
        [ H.img
            [ HA.src "close.svg"
            , HA.alt "Close"
            , HA.style "opacity" (xif options.disabled "25%" "100%")
            ]
            []
        ]


viewFooter : Options m -> List (H.Html m)
viewFooter options =
    [ H.footer [] options.footer ]


handleKeyDown : KeyboardEvent -> Options m -> Maybe m
handleKeyDown event options =
    case event.key of
        "Escape" ->
            options.onClose

        _ ->
            Nothing
