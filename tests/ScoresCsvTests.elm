module ScoresCsvTests exposing (decodeTests, encodeTests)

import Expect
import Scores
import Scores.Csv
import Test exposing (..)


testTitle =
    "Testing Title"


smallScores =
    Scores.fromLists testTitle
        [ [ 0, 0, 0, 0 ]
        , [ 1, 1, 1, 0 ]
        , [ 2, 1, 1, 0 ]
        , [ 0, 1, 1, 0 ]
        , [ 0, 0, 0, 1 ]
        ]


smallString =
    String.concat
        [ "table,game 1,game 2,game 3,game 4,total,rank\n"
        , "1,0,0,0,0,0,5\n"
        , "2,1,1,1,0,3,2\n"
        , "3,2,1,1,0,4,1\n"
        , "4,0,1,1,0,2,3\n"
        , "5,0,0,0,1,1,4\n"
        ]


smallLegacyString =
    String.concat
        [ "table,game 1,game 2,game 3,game 4,total\n"
        , "1,0,0,0,0,0\n"
        , "2,1,1,1,0,3\n"
        , "3,2,1,1,0,4\n"
        , "4,0,1,1,0,2\n"
        , "5,0,0,0,1,1\n"
        ]


encodeTests =
    describe "Scores.Csv.encode"
        [ test "small"
            (\_ ->
                Scores.Csv.encode smallScores
                    |> Expect.equal smallString
            )
        ]


decodeTests =
    describe "Scores.Csv.decode"
        [ test "small"
            (\_ ->
                Scores.Csv.decode testTitle smallString
                    |> Expect.equal (Ok smallScores)
            )
        , test "small legacy"
            (\_ ->
                Scores.Csv.decode testTitle smallLegacyString
                    |> Expect.equal (Ok smallScores)
            )
        ]
