module Sheet exposing (Model, Msg, Options, handleKeyDown, init, update, view)

import Array exposing (Array)
import Browser.Dom
import Common exposing (KeyboardEvent, listJust, sendMessage, xif)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Intl
import Json.Decode as JD
import Scores exposing (Scores)
import Suit
import Task


type alias Options m =
    { loc : Intl.Localized
    , disabled : Bool
    , scores : Scores
    , route : Msg -> m
    , onIncrement : Int -> Int -> m
    , onSetup : m
    }


type alias Model =
    { maxWidth : Float
    , maxHeight : Float
    , currTable : Maybe Int
    , currGame : Maybe Int
    , markTables : List Int
    , markTies : List ( Int, Int )
    , showPanel : Bool
    , panelGame : Int
    , showRanks : Bool
    , zoom : Float
    }


type Msg
    = Noop
    | SetupClicked
    | ShowHideRanksClicked
    | TablePressed Int
    | GamePressed Int
    | RankPressed Int
    | ValuePressed Int Int
    | Focused
    | Blurred
    | Escaped
    | ZoomIn
    | ZoomOut


cssClasses =
    Common.cssClasses.sheet


init : Model
init =
    { maxWidth = 0
    , maxHeight = 0
    , currTable = Nothing
    , currGame = Nothing
    , markTables = []
    , markTies = []
    , showPanel = False
    , panelGame = 0
    , showRanks = False
    , zoom = 0
    }


view : Options m -> Model -> H.Html m
view options model =
    let
        labelColumns =
            xif model.showRanks 4.0 3.0

        minWidthInEm =
            labelColumns * 4.0 + 4.5 * 2.0

        heightInEm =
            (2.0 + toFloat options.scores.tables + 1.5) * 1.5

        scale =
            (min
                (model.maxWidth / minWidthInEm)
                (model.maxHeight / heightInEm)
                |> max 12
            )
                * (2 ^ (model.zoom / 4))

        ranks =
            if model.showRanks then
                Just (Scores.ranks options.scores)

            else
                Nothing
    in
    H.div
        [ HA.style "display" "grid"
        , HA.style "grid" "1fr / auto 1fr"
        , HA.style "overflow" "hidden"
        ]
        (listJust
            [ if model.showPanel then
                viewPanel options model |> Just

              else
                Nothing
            , H.div
                [ HA.id "sheet"
                , cssClasses.sheet
                , HA.style "grid-area" "1 / 2"
                , HA.style "font-size" (String.fromFloat scale ++ "px")
                , HE.onFocus (options.route Focused)
                , HE.onBlur (options.route Blurred)
                , dataEventMouseDown options.route
                ]
                [ -- Fix scrolling in Firefox (see experiments/sticky-scroll-bug).
                  H.div [ HA.style "grid-area" "1 / 1 / -1 / -1" ] []
                , viewMainMarks options.scores.tables options.scores.games model
                , viewMain options.scores
                , viewLeftMarks options.scores.tables model
                , viewRightMarks options.scores.tables model
                , viewLeft options.scores.tables
                , viewRight (Scores.totals options.scores) ranks
                , viewTopMarks options.scores.games model
                , viewTop options.scores.games options model
                , viewTopRight options model
                , viewTopOverlay options model
                , viewTopLeft options model
                ]
                |> Just
            ]
        )


viewPanel : Options m -> Model -> H.Html m
viewPanel options model =
    H.div
        [ HA.style "display" "grid"
        , HA.style "padding" "1rem"
        , HA.style "grid" "auto 8rem 8rem 8rem / 8rem"
        , HA.style "grid-gap" "1rem"
        , HA.style "place-content" "center"
        , HA.style "font-size" "2rem"
        ]
        [ H.div
            [ HA.style "font-size" "1.6rem"
            , HA.style "text-align" "center"
            ]
            [ H.text (options.loc.labels.game ++ " " ++ String.fromInt (model.panelGame + 1)) ]
        , H.div []
            [ Suit.view (suitFor model.panelGame) [] ]
        , H.div
            [ HA.style "border" "2px solid #000"
            , HA.style "background-color" (awayOneFor model.panelGame)
            , HA.style "display" "grid"
            , HA.style "place-items" "center"
            ]
            []
        , H.div
            [ HA.style "border" "2px solid #000"
            , HA.style "background-color" (awayTwoFor model.panelGame)
            , HA.style "display" "grid"
            , HA.style "place-items" "center"
            ]
            []
        ]


suitFor : Int -> Suit.Suit
suitFor game =
    case remainderBy 5 game of
        0 ->
            Suit.Spade

        1 ->
            Suit.Heart

        2 ->
            Suit.NoTrump

        3 ->
            Suit.Diamond

        _ ->
            Suit.Club


awayOneFor : Int -> String
awayOneFor game =
    case remainderBy 3 game of
        0 ->
            "#00F"

        1 ->
            "#FFF"

        2 ->
            "#F00"

        _ ->
            "#000"


awayTwoFor : Int -> String
awayTwoFor game =
    case remainderBy 3 game of
        0 ->
            "#FFF"

        1 ->
            "#F00"

        2 ->
            "#00F"

        _ ->
            "#000"


viewMainMarks : Int -> Int -> Model -> H.Html m
viewMainMarks tables games model =
    H.div
        [ cssClasses.main
        , gridFixedRows tables
        , gridFixedColumns games
        ]
        (List.concat
            [ List.map
                (\table ->
                    H.div
                        [ gridArea (table + 1) 1 (table + 2) -1
                        , xif (modBy 2 table == 0) cssClasses.light cssClasses.dark
                        ]
                        []
                )
                (List.range 0 (tables - 1))
            , List.map
                (\( table, game ) ->
                    H.div
                        [ cssClasses.mark
                        , gridArea (table + 1) (game + 1) (table + 2) -1
                        ]
                        []
                )
                model.markTies
            , case model.currGame of
                Just game ->
                    [ H.div
                        [ cssClasses.currGame
                        , gridArea 1 (game + 1) -1 (game + 2)
                        ]
                        []
                    ]

                _ ->
                    []
            , case [ model.currTable, model.currGame ] of
                [ Just table, Just game ] ->
                    [ H.div
                        [ cssClasses.curr
                        , gridArea (table + 1) (game + 1) (table + 2) (game + 2)
                        ]
                        []
                    ]

                _ ->
                    []
            ]
        )


viewLeftMarks : Int -> Model -> H.Html m
viewLeftMarks tables model =
    H.div [ cssClasses.left, gridFixedRows tables ]
        (List.concat
            [ List.map
                (\table ->
                    H.div
                        [ gridArea (table + 1) 1 (table + 2) -1
                        , xif (modBy 2 table == 0) cssClasses.light cssClasses.dark
                        ]
                        []
                )
                (List.range 0 (tables - 1))
            , case model.currTable of
                Just table ->
                    [ H.div
                        [ cssClasses.currTable
                        , gridArea (table + 1) 1 (table + 2) -1
                        ]
                        []
                    ]

                _ ->
                    []
            ]
        )


viewRightMarks : Int -> Model -> H.Html m
viewRightMarks tables model =
    H.div
        [ cssClasses.right
        , gridFixedRows tables
        , gridFixedColumns (xif model.showRanks 3 2)
        ]
        (List.concat
            [ List.map
                (\table ->
                    H.div
                        [ gridArea (table + 1) 1 (table + 2) -1
                        , xif (modBy 2 table == 0) cssClasses.light cssClasses.dark
                        ]
                        []
                )
                (List.range 0 (tables - 1))
            , List.map
                (\table ->
                    H.div
                        [ cssClasses.mark
                        , gridArea (table + 1) 1 (table + 2) -1
                        ]
                        []
                )
                model.markTables
            , case model.currTable of
                Just table ->
                    [ H.div
                        [ cssClasses.currTable
                        , gridArea (table + 1) 1 (table + 2) 2
                        ]
                        []
                    ]

                _ ->
                    []
            ]
        )


viewMain : Scores -> H.Html m
viewMain scores =
    H.div [ cssClasses.main ]
        (Array.indexedMap viewMainRow scores.values |> Array.toList)


viewMainRow : Int -> Array Int -> H.Html m
viewMainRow table values =
    H.div [ cssClasses.row ]
        (Array.indexedMap (viewMainCell table) values |> Array.toList)


viewMainCell : Int -> Int -> Int -> H.Html m
viewMainCell table game value =
    H.div
        [ cssClasses.box
        , dataEvent [ "value", String.fromInt table, String.fromInt game ]
        ]
        [ H.img
            [ HA.src (String.concat [ "tally-", String.fromInt value, ".svg" ])
            , HA.draggable "false"
            ]
            []
        ]


viewLeft : Int -> H.Html m
viewLeft tables =
    H.div [ cssClasses.left ]
        [ H.div [ cssClasses.tables ]
            (List.map (\i -> viewWide "table" i (i + 1)) (List.range 0 (tables - 1)))
        ]


viewRight : Array Int -> Maybe (Array Int) -> H.Html m
viewRight totals ranks =
    H.div [ cssClasses.right ]
        (List.concat
            [ [ H.div
                    [ cssClasses.tables ]
                    (Array.indexedMap (\i _ -> viewWide "table" i (i + 1)) totals |> Array.toList)
              , H.div
                    [ cssClasses.totals ]
                    (Array.indexedMap (viewWide "total") totals |> Array.toList)
              ]
            , case ranks of
                Just rs ->
                    [ H.div [ cssClasses.ranks ]
                        (Array.indexedMap (viewRank "rank") rs |> Array.toList)
                    ]

                _ ->
                    []
            ]
        )


viewTopMarks : Int -> Model -> H.Html m
viewTopMarks games model =
    H.div [ cssClasses.top, cssClasses.dark, gridFixedRows 2, gridFixedColumns games ]
        (case model.currGame of
            Just game ->
                [ H.div
                    [ cssClasses.currGame
                    , gridArea 2 (game + 1) -1 (game + 2)
                    ]
                    []
                ]

            _ ->
                []
        )


viewTop : Int -> Options m -> Model -> H.Html m
viewTop games options model =
    H.div [ cssClasses.top ]
        [ H.div [ cssClasses.box, cssClasses.label ]
            [ H.span
                [ HA.style "position" "sticky"
                , HA.style "left" "4.5em"
                , HA.style "right" (xif model.showRanks "12.5em" "8.5em")
                ]
                [ H.text options.loc.labels.games ]
            ]
        , H.div [ cssClasses.games ]
            (List.map (\i -> viewWide "game" i (i + 1)) (List.range 0 (games - 1)))
        ]


viewTopLeft : Options m -> Model -> H.Html m
viewTopLeft options model =
    H.div [ cssClasses.topLeft, cssClasses.dark ]
        [ H.div [ cssClasses.box, gridArea 1 1 3 2 ] []
        , H.div [ cssClasses.label, gridArea 2 1 3 2 ]
            [ H.text options.loc.labels.table ]
        , H.button
            [ cssClasses.button
            , HA.disabled options.disabled
            , HE.onClick (options.route SetupClicked)
            , gridArea 1 1 2 2
            ]
            [ H.text options.loc.buttons.setup ]
        ]


viewTopRight : Options m -> Model -> H.Html m
viewTopRight options model =
    H.div [ cssClasses.topRight, cssClasses.dark ]
        (List.concat
            [ [ H.div [ cssClasses.box, gridArea 1 1 3 2 ] []
              , H.div [ cssClasses.label, gridArea 2 1 3 2 ]
                    [ H.text options.loc.labels.table ]
              , H.div [ cssClasses.box, gridArea 1 2 3 3 ] []
              , H.div [ cssClasses.label, gridArea 2 2 3 3 ]
                    [ H.text options.loc.labels.total ]
              ]
            , if model.showRanks then
                [ H.div [ cssClasses.box, gridArea 1 3 3 4 ] []
                , H.div [ cssClasses.label, gridArea 2 3 3 4 ]
                    [ H.text options.loc.labels.rank ]
                ]

              else
                []
            , [ H.button
                    [ cssClasses.button
                    , HA.disabled options.disabled
                    , HE.onClick (options.route ShowHideRanksClicked)
                    , if model.showRanks then
                        gridArea 1 3 2 4

                      else
                        gridArea 1 2 2 3
                    ]
                    [ H.text
                        (if model.showRanks then
                            options.loc.buttons.ranksHide

                         else
                            options.loc.buttons.ranksShow
                        )
                    ]
              ]
            ]
        )


viewWide : String -> Int -> Int -> H.Html m
viewWide name index value =
    H.div
        [ cssClasses.box
        , dataEvent [ name, String.fromInt index ]
        ]
        [ H.text (String.fromInt value) ]


viewRank : String -> Int -> Int -> H.Html m
viewRank name index value =
    let
        attrs =
            List.concat
                [ [ cssClasses.box
                  , dataEvent [ name, String.fromInt index ]
                  ]
                , xif (value < 3) [ cssClasses.winner ] []
                ]
    in
    H.div attrs [ H.text (String.fromInt value) ]


viewTopOverlay : Options m -> Model -> H.Html m
viewTopOverlay options model =
    H.div
        [ cssClasses.top
        , HA.style "pointer-events" "none"
        , gridFixedRows 2
        , gridFixedColumns options.scores.games
        ]
        (case model.currGame of
            Just game ->
                let
                    total =
                        Array.map (Array.get game >> Maybe.withDefault 0) options.scores.values
                            |> Array.foldl (+) 0
                in
                [ H.div
                    [ cssClasses.currGame
                    , cssClasses.box
                    , HA.style "position" "absolute"
                    , HA.style "width" "4.9375em"
                    , HA.style "height" "1.4375em"
                    , HA.style "display" "grid"
                    , HA.style "place-items" "center"
                    , gridArea 1 (game + 1) 2 (game + 2)
                    ]
                    [ H.text (options.loc.status.totalColon total) ]
                ]

            _ ->
                []
        )


update : Msg -> Options m -> Model -> ( Model, Cmd m )
update msg options model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        SetupClicked ->
            ( clearSelection model, sendMessage options.onSetup )

        ShowHideRanksClicked ->
            updateShowHideRanksClicked model
                |> Tuple.mapSecond (Cmd.map options.route)

        TablePressed table ->
            updateTablePressed table options model

        GamePressed game ->
            ( updateGamePressed game model, Cmd.none )

        RankPressed table ->
            ( updateRankPressed table options model, Cmd.none )

        ValuePressed table game ->
            updateValuePressed table game options model

        Focused ->
            ( model, Cmd.none )

        Blurred ->
            ( model, Cmd.none )

        Escaped ->
            ( clearSelection model
            , Task.attempt (\_ -> options.route Blurred) (Browser.Dom.blur "sheet")
            )

        ZoomIn ->
            ( { model | zoom = model.zoom + 1 }, Cmd.none )

        ZoomOut ->
            ( { model | zoom = model.zoom - 1 }, Cmd.none )


updateShowHideRanksClicked : Model -> ( Model, Cmd Msg )
updateShowHideRanksClicked model =
    let
        cleared =
            clearSelection model
    in
    ( { cleared | showRanks = not model.showRanks }
    , if model.showRanks then
        Cmd.none

      else
        scrollToRight "sheet"
    )


scrollToRight : String -> Cmd Msg
scrollToRight id =
    Browser.Dom.getViewportOf id
        |> Task.andThen
            (\info ->
                Browser.Dom.setViewportOf id info.scene.width info.viewport.y
            )
        |> Task.attempt (\_ -> Noop)


updateTablePressed : Int -> Options m -> Model -> ( Model, Cmd m )
updateTablePressed table options model =
    let
        cleared =
            clearSelection model
    in
    case model.currGame of
        Just game ->
            ( { cleared | currGame = Just game, currTable = Just table, panelGame = game }
            , sendMessage (options.onIncrement table game)
            )

        Nothing ->
            ( { cleared | currTable = Just table }, Cmd.none )


updateGamePressed : Int -> Model -> Model
updateGamePressed game model =
    let
        cleared =
            clearSelection model
    in
    { cleared | currGame = Just game, panelGame = game }


updateRankPressed : Int -> Options m -> Model -> Model
updateRankPressed table options model =
    let
        cleared =
            clearSelection model

        explain =
            Scores.explain options.scores table

        markTables =
            Array.map Tuple.first explain |> Array.toList

        markTies =
            explain |> Array.toList
    in
    { cleared | markTables = markTables, markTies = markTies }


updateValuePressed : Int -> Int -> Options m -> Model -> ( Model, Cmd m )
updateValuePressed table game options model =
    let
        cleared =
            clearSelection model
    in
    ( { cleared | currTable = Just table, currGame = Just game, panelGame = game }
    , sendMessage (options.onIncrement table game)
    )


handleKeyDown : KeyboardEvent -> Options m -> Model -> Maybe m
handleKeyDown event options model =
    case event.key of
        "-" ->
            Just (options.route ZoomOut)

        "=" ->
            Just (options.route ZoomIn)

        "+" ->
            Just (options.route ZoomIn)

        "Escape" ->
            Just (options.route Escaped)

        _ ->
            Nothing


clearSelection : Model -> Model
clearSelection model =
    { model
        | currTable = Nothing
        , currGame = Nothing
        , markTables = []
        , markTies = []
    }


dataEvent : List String -> H.Attribute m
dataEvent parts =
    HA.attribute "data-event" (String.join ":" parts)


dataEventMouseDown : (Msg -> m) -> H.Attribute m
dataEventMouseDown route =
    JD.field "target" (JD.oneOf [ decodeDataEvent, JD.succeed "" ])
        |> JD.andThen (processDataEvent >> unwrapToDecoder)
        |> JD.map route
        |> JD.map (\msg -> { message = msg, preventDefault = True, stopPropagation = True })
        |> HE.custom "mousedown"


decodeDataEvent : JD.Decoder String
decodeDataEvent =
    JD.maybe (JD.at [ "dataset", "event" ] JD.string)
        |> JD.andThen
            (\maybe ->
                case maybe of
                    Just event ->
                        JD.succeed event

                    Nothing ->
                        JD.field "parentElement" decodeDataEvent
            )


processDataEvent : String -> Maybe Msg
processDataEvent event =
    case String.split ":" event of
        [ "table", tableStr ] ->
            Maybe.map TablePressed
                (String.toInt tableStr)

        [ "game", gameStr ] ->
            Maybe.map GamePressed
                (String.toInt gameStr)

        [ "rank", tableStr ] ->
            Maybe.map RankPressed
                (String.toInt tableStr)

        [ "value", tableStr, gameStr ] ->
            Maybe.map2 ValuePressed
                (String.toInt tableStr)
                (String.toInt gameStr)

        _ ->
            Just Blurred


unwrapToDecoder : Maybe Msg -> JD.Decoder Msg
unwrapToDecoder maybe =
    case maybe of
        Just msg ->
            JD.succeed msg

        Nothing ->
            JD.fail "ignored input"


gridArea : Int -> Int -> Int -> Int -> H.Attribute msg
gridArea top left bottom right =
    HA.style "grid-area" (formatGridArea top left bottom right)


formatGridArea : Int -> Int -> Int -> Int -> String
formatGridArea top left bottom right =
    [ top, left, bottom, right ]
        |> List.map String.fromInt
        |> String.join "/"


gridFixedRows : Int -> H.Attribute m
gridFixedRows tables =
    HA.style "grid-template-rows"
        (String.concat [ "repeat(", String.fromInt tables, ", 1fr)" ])


gridFixedColumns : Int -> H.Attribute m
gridFixedColumns games =
    HA.style "grid-template-columns"
        (String.concat [ "repeat(", String.fromInt games, ", 1fr)" ])
