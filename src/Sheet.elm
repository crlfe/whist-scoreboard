module Sheet exposing (init, update, view)

import Array exposing (Array)
import Array2 exposing (Array2)
import Browser.Dom
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy
import Json.Decode as JD
import Random
import Setup
import State exposing (..)
import Task
import Tuple


init : SheetModel
init =
    let
        values =
            randomValues 19 20 0
    in
    { inert = False
    , title = "Temporary title"
    , games = 19
    , tables = 20
    , values = values
    , totals = tableTotals values
    , ranks = Nothing
    , marks =
        { game = Nothing
        , table = Nothing
        , explain = []
        }
    }


view : Model -> H.Html Msg
view model =
    let
        sheet =
            model.sheet
    in
    H.div
        [ HA.id "sSheet"
        , HA.tabindex
            (if sheet.inert then
                -1

             else
                0
            )
        , onKeyDown model (SheetKeyDown >> GotSheetMsg)
        , onMouseDown (SheetMouseDown >> GotSheetMsg)
        , HE.onFocus (GotSheetMsg SheetFocused)
        , HE.onBlur (GotSheetMsg SheetBlurred)
        ]
        [ viewMainMarks sheet.games sheet.tables sheet.marks
        , viewMain sheet.games sheet.tables sheet.values
        , viewLeft sheet.tables sheet.marks
        , viewRight sheet.tables sheet.marks sheet.totals sheet.ranks
        , viewTop sheet.games sheet.marks
        , H.div [ HA.class "sTopLeft sDark" ]
            [ H.div
                [ HA.class "sBox"
                , gridArea 1 1 3 2
                ]
                [ H.text "Tables"
                ]
            , H.button
                [ HA.class "sButton"
                , gridArea 1 1 2 2
                , HA.disabled model.sheet.inert
                , HE.onClick (GotSheetMsg SetupClicked)
                ]
                [ H.text "Setup" ]
            ]
        , H.div
            [ HA.class "sTopRight sDark"
            , HA.style "width" (rightWidth sheet.ranks)
            ]
            [ H.div [ HA.class "sBox", gridArea 1 1 3 2 ] [ H.text "Tables" ]
            , H.div [ HA.class "sBox", gridArea 1 2 3 3 ] [ H.text "Totals" ]
            , H.div [ HA.class "sBox", gridArea 1 3 3 4 ] [ H.text "Ranks" ]
            , H.button
                [ HA.class "sButton"
                , case model.sheet.ranks of
                    Just _ ->
                        gridArea 1 3 2 4

                    Nothing ->
                        gridArea 1 2 2 3
                , HA.disabled model.sheet.inert
                , HE.onClick
                    (GotSheetMsg
                        (case model.sheet.ranks of
                            Just _ ->
                                HideRanksClicked

                            Nothing ->
                                ShowRanksClicked
                        )
                    )
                ]
                [ H.text
                    (case model.sheet.ranks of
                        Just _ ->
                            "Hide Ranks"

                        Nothing ->
                            "Show Ranks"
                    )
                ]
            ]
        ]


viewMainMarks : Int -> Int -> SheetModelMarks -> H.Html Msg
viewMainMarks games tables marks =
    let
        tableIndices =
            List.range 0 (tables - 1)
    in
    H.div
        [ HA.class "sMain"
        , mainTemplateRows tables
        , mainTemplateColumns games
        ]
        (List.concat
            [ List.map
                (\table -> H.div [ HA.class "sDark", gridArea (table + 1) 1 (table + 2) -1 ] [])
                (List.filter (\v -> modBy 2 v == 1) tableIndices)
            , List.map viewMarksExplainValue marks.explain
            , listFromMaybe (Maybe.map viewMarksGame marks.game)
            , listFromMaybe (Maybe.map2 viewMarksCurr marks.game marks.table)
            ]
        )


listFromMaybe : Maybe a -> List a
listFromMaybe maybe =
    case maybe of
        Just v ->
            List.singleton v

        Nothing ->
            []


viewMarksTable : Int -> H.Html Msg
viewMarksTable table =
    H.div [ HA.class "sMarksTable", gridArea (table + 1) 1 (table + 2) -1 ] []


viewMarksGame : Int -> H.Html Msg
viewMarksGame game =
    H.div [ HA.class "sMarksGame", gridArea 1 (game + 1) -1 (game + 2) ] []


viewMarksCurr : Int -> Int -> H.Html Msg
viewMarksCurr game table =
    H.div [ HA.class "sMarksCurr", gridArea (table + 1) (game + 1) (table + 2) (game + 2) ] []


viewMarksExplainValue : ( Int, Int ) -> H.Html Msg
viewMarksExplainValue ( game, table ) =
    H.div [ HA.class "sMarksValue", gridArea (table + 1) (game + 1) (table + 2) -1 ] []


viewMarksExplainTotal : ( Int, Int ) -> H.Html Msg
viewMarksExplainTotal ( _, table ) =
    H.div [ HA.class "sMarksValue", gridArea (table + 1) 1 (table + 2) 2 ] []


viewMain : Int -> Int -> Array2 Int -> H.Html Msg
viewMain games tables values =
    H.div
        [ HA.class "sMain"
        , mainTemplateRows tables
        , mainTemplateColumns games
        ]
        (Array.indexedMap (Html.Lazy.lazy2 viewMainGame) values
            |> Array.toList
        )


viewMainGame : Int -> Array Int -> H.Html Msg
viewMainGame game values =
    let
        tables =
            Array.length values
    in
    H.div
        [ HA.class "sMainGame"
        , gridArea 1 (game + 1) (tables + 1) (game + 2)
        , mainTemplateRows tables
        ]
        (Array.indexedMap (viewMainCell game) values |> Array.toList)


viewMainCell : Int -> Int -> Int -> H.Html Msg
viewMainCell game table value =
    H.div
        [ HA.class "sBox"
        , dataEvent
            [ "value"
            , String.fromInt game
            , String.fromInt table
            ]
        ]
        [ H.img
            [ HA.src (String.concat [ "tally-", String.fromInt value, ".svg" ])
            , HA.draggable "false"
            ]
            []
        ]


viewLeft : Int -> SheetModelMarks -> H.Html Msg
viewLeft tables marks =
    let
        tableIndices =
            List.range 0 (tables - 1)
    in
    H.div [ HA.class "sLeft" ]
        [ H.div [ HA.class "sLabelColumn", gridArea 1 1 -1 -1, mainTemplateRows tables ]
            (List.concat
                [ List.map
                    (\table -> H.div [ HA.class "sDark", gridArea (table + 1) 1 (table + 2) 2 ] [])
                    (List.filter (\v -> modBy 2 v == 1) tableIndices)
                , listFromMaybe (Maybe.map viewMarksTable marks.table)
                ]
            )
        , H.div [ HA.class "sLabelColumn", gridArea 1 1 2 2, mainTemplateRows tables ]
            (List.map
                (\table ->
                    H.div
                        [ HA.class "sBox"
                        , gridArea (table + 1) 1 (table + 2) 2
                        , dataEvent
                            [ "table"
                            , String.fromInt table
                            ]
                        ]
                        [ H.text (String.fromInt (table + 1)) ]
                )
                tableIndices
            )
        ]


viewRight : Int -> SheetModelMarks -> Array Int -> Maybe (Array Int) -> H.Html Msg
viewRight tables marks totals ranks =
    let
        tableIndices =
            List.range 0 (tables - 1)
    in
    H.div
        [ HA.class "sRight"
        , HA.style "width" (rightWidth ranks)
        ]
        [ H.div [ HA.style "display" "grid", gridArea 1 1 -1 -1, mainTemplateRows tables, HA.style "grid-template-columns" "1fr" ]
            (List.concat
                [ List.map
                    (\table -> H.div [ HA.class "sDark", gridArea (table + 1) 1 (table + 2) 2 ] [])
                    (List.filter (\v -> modBy 2 v == 1) tableIndices)
                , List.map viewMarksExplainTotal marks.explain
                , listFromMaybe (Maybe.map viewMarksTable marks.table)
                ]
            )
        , H.div [ HA.class "sLabelColumn", gridArea 1 1 2 2, mainTemplateRows tables ]
            (List.map
                (\table ->
                    H.div
                        [ HA.class "sBox"
                        , gridArea (table + 1) 1 (table + 2) 2
                        , dataEvent
                            [ "table"
                            , String.fromInt table
                            ]
                        ]
                        [ H.text (String.fromInt (table + 1)) ]
                )
                tableIndices
            )
        , H.div [ HA.class "sLabelColumn", gridArea 1 2 2 3, mainTemplateRows tables ]
            (List.map
                (\table ->
                    H.div
                        [ HA.class "sBox"
                        , gridArea (table + 1) 1 (table + 2) 2
                        , dataEvent
                            [ "table"
                            , String.fromInt table
                            ]
                        ]
                        [ H.text
                            (String.fromInt
                                (Array.get table totals
                                    |> Maybe.withDefault 0
                                )
                            )
                        ]
                )
                tableIndices
            )
        , H.div [ HA.class "sLabelColumn", gridArea 1 3 2 4, mainTemplateRows tables ]
            (List.indexedMap
                (\table rank ->
                    H.div
                        ([ HA.class "sBox"
                         , gridArea (table + 1) 1 (table + 2) 2
                         , dataEvent
                            [ "rank"
                            , String.fromInt table
                            ]
                         ]
                            |> (\tail ->
                                    if rank <= 2 then
                                        HA.class "sWin" :: tail

                                    else
                                        tail
                               )
                        )
                        [ H.text (String.fromInt rank) ]
                )
                (Maybe.withDefault [] (Maybe.map Array.toList ranks))
            )
        ]


rightWidth : Maybe a -> String
rightWidth ranks =
    case ranks of
        Just _ ->
            "12rem"

        Nothing ->
            "8rem"


viewTop : Int -> SheetModelMarks -> H.Html Msg
viewTop games marks =
    H.div [ HA.class "sTop sDark" ]
        [ H.div [ HA.class "sTopGames sBox" ]
            [ H.span [ HA.class "sTopGamesLabel" ] [ H.text "Games" ]
            ]
        , H.div [ HA.class "sTopLabels", mainTemplateColumns games ]
            (listFromMaybe (Maybe.map viewMarksGame marks.game))
        , H.div [ HA.class "sTopLabels", gridArea 2 1 3 2, mainTemplateColumns games ]
            (List.map
                (\game ->
                    H.div
                        [ HA.class "sBox"
                        , gridArea 1 (game + 1) 2 (game + 2)
                        , dataEvent
                            [ "game"
                            , String.fromInt game
                            ]
                        ]
                        [ H.text (String.fromInt (game + 1)) ]
                )
                (List.range 0 (games - 1))
            )
        ]


update : SheetMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetupClicked ->
            ( Setup.open model, Cmd.none )

        ShowRanksClicked ->
            ( showRanks model, Cmd.none )

        HideRanksClicked ->
            ( hideRanks model, Cmd.none )

        SheetKeyDown key ->
            updateKeyDown key model

        SheetMouseDown event ->
            updateMouseDown (String.split ":" event) model

        SheetFocused ->
            ( model, Cmd.none )

        SheetBlurred ->
            ( setMarks { game = Nothing, table = Nothing, explain = [] } model, Cmd.none )


showRanks : Model -> Model
showRanks model =
    let
        sheet =
            model.sheet

        ranks =
            Just (computeRanks sheet.values sheet.totals)
    in
    { model | sheet = { sheet | ranks = ranks } }


hideRanks : Model -> Model
hideRanks model =
    let
        sheet =
            model.sheet
    in
    { model | sheet = { sheet | ranks = Nothing } }


computeRanks : Array2 Int -> Array Int -> Array Int
computeRanks values totals =
    let
        tables =
            Array2.minorLength values
    in
    List.sortWith (compareTables values totals) (List.range 0 (tables - 1))
        |> listGroupWhile (\x y -> EQ == compareTables values totals x y)
        |> List.foldl
            (\ts ( dst, rank ) ->
                ( List.map (\t -> ( rank, t )) ts :: dst
                , rank + List.length ts
                )
            )
            ( [], 1 )
        |> Tuple.first
        |> List.concat
        |> List.sortBy Tuple.second
        |> List.map Tuple.first
        |> Array.fromList


listGroupWhile : (a -> a -> Bool) -> List a -> List (List a)
listGroupWhile func list =
    case list of
        [] ->
            []

        x :: xs ->
            listGroupWhileRecurse func x xs
                |> (\( _, cur, dst ) -> cur :: dst)


listGroupWhileRecurse : (a -> a -> Bool) -> a -> List a -> ( a, List a, List (List a) )
listGroupWhileRecurse func x xs =
    case xs of
        [] ->
            ( x, [ x ], [] )

        y :: ys ->
            listGroupWhileRecurse func y ys
                |> (\( lst, cur, dst ) ->
                        if func x lst then
                            ( x, x :: cur, dst )

                        else
                            ( x, [ x ], cur :: dst )
                   )


compareTables : Array2 Int -> Array Int -> Int -> Int -> Order
compareTables values totals x y =
    let
        xTotal =
            Array.get x totals |> Maybe.withDefault 0

        yTotal =
            Array.get y totals |> Maybe.withDefault 0

        xyValues =
            Array.map
                (\arr ->
                    ( Array.get x arr |> Maybe.withDefault 0
                    , Array.get y arr |> Maybe.withDefault 0
                    )
                )
                values
    in
    Array.foldr
        (\( xValue, yValue ) cmp ->
            if cmp == EQ then
                compare xValue yValue

            else
                cmp
        )
        (compareReverse xTotal yTotal)
        xyValues


findTieBreaker : Model -> Int -> Int -> Int
findTieBreaker model x y =
    let
        ixyValues =
            Array.indexedMap
                (\index arr ->
                    ( index
                    , Array.get x arr |> Maybe.withDefault 0
                    , Array.get y arr |> Maybe.withDefault 0
                    )
                )
                model.sheet.values
    in
    if x == y then
        model.sheet.games

    else
        Array.foldr
            (\( index, xValue, yValue ) maybe ->
                case maybe of
                    Just i ->
                        Just i

                    Nothing ->
                        if compare xValue yValue /= EQ then
                            Just index

                        else
                            Nothing
            )
            Nothing
            ixyValues
            |> Maybe.withDefault 0


compareReverse : Int -> Int -> Order
compareReverse x y =
    case compare x y of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT


updateKeyDown : String -> Model -> ( Model, Cmd Msg )
updateKeyDown key model =
    if model.sheet.inert then
        ( model, Cmd.none )

    else
        tryUpdateKeyDown key model
            |> Maybe.withDefault ( model, Cmd.none )


tryUpdateKeyDown : String -> Model -> Maybe ( Model, Cmd Msg )
tryUpdateKeyDown key model =
    let
        sheet =
            model.sheet

        marks =
            sheet.marks
    in
    case key of
        "ArrowUp" ->
            case marks.table of
                Just table ->
                    if table > 0 then
                        Just ( setMarks { marks | table = Just (table - 1) } model, Cmd.none )

                    else
                        Nothing

                Nothing ->
                    if hasCurrentGame sheet then
                        Just ( setMarks { marks | table = Just (sheet.tables - 1) } model, Cmd.none )

                    else
                        Nothing

        "ArrowDown" ->
            case marks.table of
                Just table ->
                    if table + 1 < sheet.tables then
                        Just ( setMarks { marks | table = Just (table + 1) } model, Cmd.none )

                    else
                        Nothing

                Nothing ->
                    if hasCurrentGame sheet then
                        Just ( setMarks { marks | table = Just 0 } model, Cmd.none )

                    else
                        Nothing

        "ArrowLeft" ->
            case marks.game of
                Just game ->
                    if game > 0 then
                        Just ( setMarks { marks | game = Just (game - 1) } model, Cmd.none )

                    else
                        Nothing

                Nothing ->
                    if hasCurrentTable sheet then
                        Just ( setMarks { marks | game = Just (sheet.games - 1) } model, Cmd.none )

                    else
                        Nothing

        "ArrowRight" ->
            case marks.game of
                Just game ->
                    if game + 1 < sheet.games then
                        Just ( setMarks { marks | game = Just (game + 1) } model, Cmd.none )

                    else
                        Nothing

                Nothing ->
                    if hasCurrentTable sheet then
                        Just ( setMarks { marks | game = Just 0 } model, Cmd.none )

                    else
                        Nothing

        "Escape" ->
            Just
                ( setMarks { game = Nothing, table = Nothing, explain = [] } model
                , Task.attempt (\_ -> Ignored) (Browser.Dom.blur "sSheet")
                )

        " " ->
            Nothing

        "0" ->
            Nothing

        "1" ->
            Nothing

        "2" ->
            Nothing

        "3" ->
            Nothing

        "4" ->
            Nothing

        _ ->
            Nothing


updateMouseDown : List String -> Model -> ( Model, Cmd Msg )
updateMouseDown parts model =
    if model.sheet.inert then
        ( model, Cmd.none )

    else
        (case parts of
            [ "game", gameStr ] ->
                Maybe.map (updateMouseDownGame model) (String.toInt gameStr)

            [ "table", tableStr ] ->
                Maybe.map (updateMouseDownTable model) (String.toInt tableStr)

            [ "rank", tableStr ] ->
                Maybe.map (updateMouseDownRank model) (String.toInt tableStr)

            [ "value", gameStr, tableStr ] ->
                Maybe.map2 (updateMouseDownValue model) (String.toInt gameStr) (String.toInt tableStr)

            _ ->
                Nothing
        )
            |> Maybe.withDefault ( model, Cmd.none )


updateMouseDownGame : Model -> Int -> ( Model, Cmd Msg )
updateMouseDownGame model game =
    ( setMarks { game = Just game, table = Nothing, explain = [] } model, Cmd.none )


updateMouseDownTable : Model -> Int -> ( Model, Cmd Msg )
updateMouseDownTable model table =
    case model.sheet.marks.game of
        Just game ->
            ( model
                |> incrementValue game table
                |> setMarks { game = Just game, table = Just table, explain = [] }
            , Cmd.none
            )

        Nothing ->
            ( setMarks { game = Nothing, table = Just table, explain = [] } model, Cmd.none )


updateMouseDownRank : Model -> Int -> ( Model, Cmd Msg )
updateMouseDownRank model table =
    let
        total =
            Array.get table model.sheet.totals |> Maybe.withDefault 0

        tablesWithTotal =
            List.filterMap
                (\( i, t ) ->
                    if t == total then
                        Just i

                    else
                        Nothing
                )
                (Array.toIndexedList model.sheet.totals)

        explain =
            List.map
                (\t ->
                    ( List.map (findTieBreaker model t) tablesWithTotal
                        |> List.minimum
                        |> Maybe.withDefault 0
                    , t
                    )
                )
                tablesWithTotal
    in
    ( setMarks
        { game = Nothing
        , table = Nothing
        , explain = explain
        }
        model
    , Cmd.none
    )


updateMouseDownValue : Model -> Int -> Int -> ( Model, Cmd Msg )
updateMouseDownValue model game table =
    ( model
        |> incrementValue game table
        |> setMarks { game = Just game, table = Just table, explain = [] }
    , Cmd.none
    )


setMarks : SheetModelMarks -> Model -> Model
setMarks marks model =
    let
        sheet =
            model.sheet
    in
    { model | sheet = { sheet | marks = marks } }


incrementValue : Int -> Int -> Model -> Model
incrementValue game table model =
    { model | sheet = mapValueOfSheet (\v -> modBy 5 (v + 1)) game table model.sheet }


mapValueOfSheet : (Int -> Int) -> Int -> Int -> SheetModel -> SheetModel
mapValueOfSheet callback game table model =
    let
        oldArray =
            Array.get game model.values
                |> Maybe.withDefault Array.empty

        oldValue =
            Array.get table oldArray
                |> Maybe.withDefault 0

        newValue =
            callback oldValue

        newArray =
            Array.set table newValue oldArray

        newValues =
            Array.set game newArray model.values

        newTotals =
            tableTotals newValues

        newRanks =
            Maybe.map (\_ -> computeRanks newValues newTotals) model.ranks
    in
    { model | values = newValues, totals = newTotals, ranks = newRanks }


onKeyDown : Model -> (String -> msg) -> H.Attribute msg
onKeyDown model tagger =
    JD.map5 (wantKeyDown model)
        (JD.field "key" JD.string)
        (JD.field "altKey" JD.bool)
        (JD.field "ctrlKey" JD.bool)
        (JD.field "metaKey" JD.bool)
        (JD.field "shiftKey" JD.bool)
        |> JD.andThen
            (\maybe ->
                case maybe of
                    Just key ->
                        JD.succeed
                            { message = tagger key
                            , preventDefault = True
                            , stopPropagation = True
                            }

                    Nothing ->
                        JD.fail "ignored input"
            )
        |> HE.custom "keydown"


wantKeyDown : Model -> String -> Bool -> Bool -> Bool -> Bool -> Maybe String
wantKeyDown model key altKey ctrlKey metaKey shiftKey =
    if model.sheet.inert || altKey || ctrlKey || metaKey || shiftKey then
        Nothing

    else
        tryUpdateKeyDown key model |> Maybe.andThen (\_ -> Just key)


hasCurrentGame : SheetModel -> Bool
hasCurrentGame model =
    case model.marks.game of
        Just _ ->
            True

        Nothing ->
            False


hasCurrentTable : SheetModel -> Bool
hasCurrentTable model =
    case model.marks.table of
        Just _ ->
            True

        Nothing ->
            False


onMouseDown : (String -> msg) -> H.Attribute msg
onMouseDown tagger =
    JD.field "target" decodeDataEvent
        |> JD.map tagger
        |> HE.on "mousedown"


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


mainTemplateRows : Int -> H.Attribute msg
mainTemplateRows tables =
    HA.style "grid-template-rows"
        (String.concat [ "repeat(", String.fromInt tables, ", 1.5rem)" ])


mainTemplateColumns : Int -> H.Attribute msg
mainTemplateColumns games =
    HA.style "grid-template-columns"
        (String.concat [ "repeat(", String.fromInt games, ", 2rem)" ])


gridArea : Int -> Int -> Int -> Int -> H.Attribute msg
gridArea top left bottom right =
    HA.style "grid-area" (formatGridArea top left bottom right)


dataEvent : List String -> H.Attribute msg
dataEvent parts =
    HA.attribute "data-event" (String.join ":" parts)


formatGridArea : Int -> Int -> Int -> Int -> String
formatGridArea top left bottom right =
    [ top, left, bottom, right ]
        |> List.map String.fromInt
        |> String.join "/"


gameTotals : Array2 Int -> Array Int
gameTotals values =
    Array.map (\gameValues -> Array.foldl (+) 0 gameValues) values


tableTotals : Array2 Int -> Array Int
tableTotals values =
    let
        tables =
            Array.length (Array.get 0 values |> Maybe.withDefault Array.empty)
    in
    Array.foldl
        (\totals gameValues ->
            Array.indexedMap
                (\i total -> total + (Array.get i gameValues |> Maybe.withDefault 0))
                totals
        )
        (Array.initialize tables (\_ -> 0))
        values


randomValues : Int -> Int -> Int -> Array2 Int
randomValues majors minors seed =
    let
        gen =
            Random.map (\n -> round (3.5 * (n ^ 10) + 0.3)) (Random.float 0 1)
    in
    Array2.fromGenerator majors minors (Random.step gen) (Random.initialSeed seed)
        |> Tuple.first
