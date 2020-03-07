module Suit exposing (Suit(..), view)

import Html as H
import Html.Attributes as HA
import Svg as S
import Svg.Attributes as SA


type Suit
    = Spade
    | Heart
    | Diamond
    | Club
    | NoTrump


view : Suit -> List (H.Attribute m) -> H.Html m
view suit attrs =
    S.svg (SA.viewBox "0 0 32 32" :: attrs)
        [ svgDefs
        , S.use
            [ SA.xlinkHref
                (case suit of
                    Spade ->
                        "#spade"

                    Heart ->
                        "#heart"

                    Diamond ->
                        "#diamond"

                    Club ->
                        "#club"

                    NoTrump ->
                        "#notrump"
                )
            ]
            []
        ]


svgDefs =
    S.defs []
        [ spadePath
        , heartPath
        , diamondPath
        , clubPath
        , S.g [ HA.id "notrump" ]
            [ S.use [ SA.transform "translate(2,2)scale(0.25)", SA.xlinkHref "#spade" ] []
            , S.use [ SA.transform "translate(22,2)scale(0.25)", SA.xlinkHref "#heart" ] []
            , S.use [ SA.transform "translate(2,22)scale(0.25)", SA.xlinkHref "#diamond" ] []
            , S.use [ SA.transform "translate(22,22)scale(0.25)", SA.xlinkHref "#club" ] []
            , S.text_
                [ SA.transform "translate(16,17)"
                , HA.style "color" "#000"
                , HA.style "font-family" "serif"
                , HA.style "font-size" "12px"
                , HA.style "font-weight" "bold"
                , HA.style "text-anchor" "middle"
                , HA.style "dominant-baseline" "middle"
                ]
                [ S.text "NT" ]
            ]
        ]


spadePath =
    S.path
        [ HA.id "spade"
        , HA.style "fill" "#000"
        , SA.d
            (String.join " "
                [ "M 16,30 14,30"
                , "C 15.5,28 15.5,22 15.5,20"
                , "A 6,6 0 0 1 3.5,20"
                , "C 3.5,12 15,8 16,2 17,8 28.5,12 28.5,20"
                , "A 6,6 0 0 1 16.5,20"
                , "C 16.5,22 16.5,28 18,30"
                , "Z"
                ]
            )
        ]
        []


heartPath =
    S.path
        [ HA.id "heart"
        , HA.style "fill" "#F00"
        , SA.d
            (String.join " "
                [ "M 15.6,9"
                , "A 6,6 0 0 0 3.6,9"
                , "C 3.6,16 15,24 16,30 17,24 28.3,16 28.3,10"
                , "A 6,6 0 0 0 16.3,9"
                , "C 16.2,9.5 15.7,9.5 15.6,9"
                , "Z"
                ]
            )
        ]
        []


diamondPath =
    S.path
        [ HA.id "diamond"
        , HA.style "fill" "#F00"
        , SA.d
            (String.join " "
                [ "M 16,30"
                , "Q 11,22 4,16"
                , "Q 11,10 16,2"
                , "Q 21,10 28,16"
                , "Q 21,22 16,30"
                , "Z"
                ]
            )
        ]
        []


clubPath =
    S.path
        [ HA.id "club"
        , HA.style "fill" "#000"
        , SA.d
            (String.join " "
                [ "M 16,30 14,30"
                , "C 15.5,28 15.5,22 15.5,19"
                , "A 6,6 0 1 1 10,13.5"
                , "Q 12.5,14.25 11,12"
                , "A 6,6 0 1 1 21,12"
                , "Q 19.5,14.25 22,13.5"
                , "A 6,6 0 1 1 16.5,19"
                , "C 16.5,22 16.5,28 18,30"
                , "Z"
                ]
            )
        ]
        []
