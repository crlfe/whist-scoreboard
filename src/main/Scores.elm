module Scores exposing (Scores, explain, fromLists, get, indexedMap, map, mapOne, ranks, set, totals, zero)

import Array exposing (Array)
import Common exposing (arrayMapOne)

type alias Scores =
    { title : String
    , tables : Int
    , games : Int
    , values : Array (Array Int)
    }

fromLists : String -> List (List Int) -> Scores
fromLists title xs =
    let
        tables =
            List.length xs

        games =
            List.map List.length xs |> List.minimum |> Maybe.withDefault 0
    in
    { title = title
    , tables = tables
    , games = games
    , values = Array.fromList xs |> Array.map Array.fromList
    }


zero : String -> Int -> Int -> Scores
zero title tables games =
    { title = title
    , tables = tables
    , games = games
    , values =
        Array.initialize tables
            (\_ -> Array.initialize games (\_ -> 0))
    }


get : Int -> Int -> Scores -> Int
get table game scores =
    Array.get table scores.values
        |> Maybe.andThen (Array.get game)
        |> Maybe.withDefault 0


map : (Int -> Int) -> Scores -> Scores
map func scores =
    let
        values =
            Array.map (Array.map func) scores.values
    in
    { scores | values = values }


indexedMap : (Int -> Int -> Int -> Int) -> Scores -> Scores
indexedMap func scores =
    let
        values =
            Array.indexedMap
                (\table ->
                    Array.indexedMap
                        (\game -> func table game)
                )
                scores.values
    in
    { scores | values = values }


mapOne : (Int -> Int) -> Int -> Int -> Scores -> Scores
mapOne func table game scores =
    let
        values =
            arrayMapOne (arrayMapOne func game) table scores.values
    in
    { scores | values = values }


set : Int -> Int -> Int -> Scores -> Scores
set table game value scores =
    let
        values =
            arrayMapOne (Array.set game value) table scores.values
    in
    { scores | values = values }


totals : Scores -> Array Int
totals scores =
    Array.map (Array.foldl (+) 0) scores.values

-- RANKING


type alias RankEntry =
    { index : Int
    , values : Array Int
    , total : Int
    , rank : Int
    , tied : Int
    }


ranks : Scores -> Array Int
ranks scores =
    totals scores
        |> Array.indexedMap
            (\index total ->
                { index = index
                , values =
                    Array.get index scores.values
                        |> Maybe.withDefault Array.empty
                , total = total
                , rank = 0
                , tied = 0
                }
            )
        |> Array.toList
        |> List.sortWith compareTables
        |> fillRanks
        |> List.sortBy .index
        |> List.map .rank
        |> Array.fromList


explain : Scores -> Int -> Array ( Int, Int )
explain scores table =
    let
        totals_ =
            totals scores

        wantTotal =
            Array.get table totals_
                |> Maybe.withDefault 0
    in
    totals_
        |> Array.indexedMap Tuple.pair
        |> Array.filter (\( _, t ) -> t == wantTotal)
        |> Array.map
            (\( i, t ) ->
                { index = i
                , values =
                    Array.get i scores.values
                        |> Maybe.withDefault Array.empty
                , total = t
                , rank = 0
                , tied = 0
                }
            )
        |> Array.toList
        |> fillTied
        |> List.sortBy .index
        |> List.map (\e -> ( e.index, e.tied ))
        |> Array.fromList


type alias RankState =
    { rank : Int
    , group : List RankEntry
    , result : List RankEntry
    }


fillRanks : List RankEntry -> List RankEntry
fillRanks xs =
    let
        step : RankEntry -> RankState -> RankState
        step x s =
            let
                currRank =
                    s.rank

                nextRank =
                    s.rank + List.length s.group
            in
            case s.group of
                [] ->
                    { s | group = [ { x | rank = currRank } ] }

                y :: _ ->
                    if compareTables x y == EQ then
                        { s | group = s.group ++ [ { x | rank = currRank } ] }

                    else
                        { rank = nextRank
                        , group = [ { x | rank = nextRank } ]
                        , result = s.result ++ fillTied s.group
                        }

        post : RankState -> List RankEntry
        post s =
            s.result ++ fillTied s.group
    in
    List.foldl step (RankState 1 [] []) xs |> post


fillTied : List RankEntry -> List RankEntry
fillTied xs =
    let
        step : RankEntry -> RankEntry -> Int -> Int
        step x y s =
            if x == y then
                s

            else
                min s (compareTableValues x.values y.values |> Tuple.second)
    in
    List.map
        (\x ->
            { x
                | tied = List.foldl (step x) (Array.length x.values) xs
            }
        )
        xs


compareTables : RankEntry -> RankEntry -> Order
compareTables x y =
    case compare x.total y.total of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            compareTableValues x.values y.values |> Tuple.first


compareTableValues : Array Int -> Array Int -> ( Order, Int )
compareTableValues xs ys =
    let
        length =
            min (Array.length xs) (Array.length ys)

        indices =
            List.range 0 (length - 1)
    in
    List.foldr
        (\i r ->
            if Tuple.first r /= EQ then
                r

            else
                ( compare
                    (Array.get i xs |> Maybe.withDefault 0)
                    (Array.get i ys |> Maybe.withDefault 0)
                , i
                )
        )
        ( EQ, length )
        indices
