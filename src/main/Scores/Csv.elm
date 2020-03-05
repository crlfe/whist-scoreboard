module Scores.Csv exposing (decode, encode)

import Array exposing (Array)
import Common exposing (arrayMapAndThen, listJust)
import Scores exposing (Scores)


decode : String -> String -> Result String Scores
decode title string =
    let
        raw : Array (Array String)
        raw =
            splitLines string
                |> Array.filter (\line -> String.trim line /= "")
                |> Array.map (String.split "," >> Array.fromList)

        header =
            findHeader raw

        tableRows =
            if header == Nothing then
                raw

            else
                Array.slice 1 (Array.length raw) raw

        gameColumns =
            findGameColumns header tableRows

        values : Maybe (Array (Array Int))
        values =
            arrayMapAndThen
                (\row ->
                    arrayMapAndThen
                        (\col ->
                            Array.get col row
                                |> Maybe.map String.trim
                                |> Maybe.andThen String.toInt
                        )
                        gameColumns
                )
                tableRows
    in
    case values of
        Just vs ->
            Ok
                { title = title
                , tables = Array.length tableRows
                , games = Array.length gameColumns
                , values = vs
                }

        Nothing ->
            Err "failed"


findHeader : Array (Array String) -> Maybe (Array String)
findHeader records =
    Array.get 0 records
        |> Maybe.andThen
            (\h ->
                Array.get 0 h
                    |> Maybe.andThen
                        (\x ->
                            if String.toInt (String.trim x) == Nothing then
                                Just h

                            else
                                Nothing
                        )
            )


findGameColumns : Maybe (Array String) -> Array (Array String) -> Array Int
findGameColumns header tableRows =
    let
        columns : Int
        columns =
            case header of
                Just xs ->
                    Array.length xs

                Nothing ->
                    Array.map Array.length tableRows
                        |> Array.toList
                        |> List.minimum
                        |> Maybe.withDefault 0

        skipLeft =
            header
                |> Maybe.andThen
                    (Array.foldl countUntilGameHeader ( 0, Nothing ) >> Tuple.second)
                |> Maybe.withDefault 1

        skipRight =
            header
                |> Maybe.andThen
                    (Array.foldr countUntilGameHeader ( 0, Nothing ) >> Tuple.second)
                |> Maybe.withDefault 1
    in
    List.range skipLeft (columns - 1 - skipRight) |> Array.fromList


countUntilGameHeader : String -> ( Int, Maybe Int ) -> ( Int, Maybe Int )
countUntilGameHeader h ( i, r ) =
    if r == Nothing then
        if String.startsWith "game " h then
            ( i, Just i )

        else
            ( i + 1, Nothing )

    else
        ( i, r )


splitLines : String -> Array String
splitLines string =
    let
        step : Char -> ( Bool, Array Char, Array String ) -> ( Bool, Array Char, Array String )
        step c ( afterCr, line, result ) =
            case c of
                '\u{000D}' ->
                    ( True, Array.empty, Array.push (arrayToString line) result )

                '\n' ->
                    if afterCr then
                        ( False, line, result )

                    else
                        ( False, Array.empty, Array.push (arrayToString line) result )

                x ->
                    ( False, Array.push x line, result )
    in
    String.foldl step ( False, Array.empty, Array.empty ) string
        |> (\( _, line, result ) ->
                if Array.isEmpty line then
                    result

                else
                    Array.push (arrayToString line) result
           )


arrayToString : Array Char -> String
arrayToString xs =
    xs |> Array.toList |> String.fromList


encode : Scores -> String
encode scores =
    let
        totals =
            Scores.totals scores

        ranks =
            Scores.ranks scores

        header =
            List.concat
                [ [ "table" ]
                , List.map formatGameLabel (List.range 0 (scores.games - 1))
                , [ "total", "rank" ]
                ]

        tables =
            listJust
                (List.map
                    (\i ->
                        Maybe.map3 (encodeTable i)
                            (Array.get i scores.values)
                            (Array.get i totals)
                            (Array.get i ranks)
                    )
                    (List.range 0 (scores.tables - 1))
                )
    in
    (header :: tables)
        |> List.map (\v -> String.join "," v ++ "\n")
        |> String.concat


formatGameLabel : Int -> String
formatGameLabel index =
    "game " ++ String.fromInt (index + 1)


encodeTable : Int -> Array Int -> Int -> Int -> List String
encodeTable index values total rank =
    List.concat
        [ [ String.fromInt (index + 1) ]
        , Array.map String.fromInt values |> Array.toList
        , [ String.fromInt total, String.fromInt rank ]
        ]
