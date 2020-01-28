module Dialog exposing (Options, defaults, error, handleKeyDown, view)

import Common exposing (KeyboardEvent, xif)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Intl


type alias Options m =
    { loc : Intl.Localized
    , disabled : Bool
    , title : String
    , titleColor : String
    , headerColor : String
    , footer : List (H.Html m)
    , onClose : Maybe m
    , onEnter : Maybe m
    }


cssClasses =
    Common.cssClasses.dialog


defaults : Intl.Localized -> Options m
defaults loc =
    { loc = loc
    , disabled = False
    , title = loc.labels.message
    , titleColor = "#000"
    , headerColor = "#AAF"
    , onClose = Nothing
    , onEnter = Nothing
    , footer = []
    }


error :
    { loc : Intl.Localized
    , onClose : m
    }
    -> Options m
error options =
    let
        localized =
            defaults options.loc
    in
    { localized
        | title = "Error"
        , headerColor = "#F88"
        , onClose = Just options.onClose
        , onEnter = Just options.onClose
        , footer =
            [ H.button [ HE.onClick options.onClose ]
                [ H.text options.loc.buttons.ok ]
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
    let
        titleDiv =
            H.div
                [ cssClasses.title
                , HA.style "color" options.titleColor
                , HA.style "opacity" (xif options.disabled "25%" "100%")
                ]
                [ H.text options.title ]
    in
    [ H.header
        [ HA.style "background-color" options.headerColor ]
        (titleDiv
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
            [ HA.style "grid-area" "1 / -1"
            , HA.src "close.svg"
            , HA.alt options.loc.buttons.close
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
