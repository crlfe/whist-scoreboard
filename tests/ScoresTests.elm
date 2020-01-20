module ScoresTests exposing (scoresRanksTests)

import Array
import Expect
import Scores
import Test exposing (..)


scoresRanksTests =
    describe "Scores.ranks"
        [ test "no ties"
            (\_ ->
                -- Every table ends with a different total.
                let
                    scores =
                        Scores.fromLists "Test"
                            [ [ 0, 0, 0, 0 ]
                            , [ 1, 1, 1, 0 ]
                            , [ 2, 1, 1, 0 ]
                            , [ 0, 1, 1, 0 ]
                            , [ 0, 0, 0, 1 ]
                            ]
                in
                Scores.ranks scores |> Expect.equal (Array.fromList [ 5, 2, 1, 3, 4 ])
            )
        , test "breaking ties"
            (\_ ->
                -- Two pairs have the same totals to test the tie-breaking rules.
                -- To break ties, prefer the table that was last leading.
                let
                    scores =
                        Scores.fromLists "Test"
                            [ [ 0, 1, 0, 0 ]
                            , [ 0, 1, 1, 0 ]
                            , [ 2, 1, 1, 0 ]
                            , [ 1, 1, 0, 0 ]
                            , [ 0, 0, 0, 1 ]
                            ]
                in
                Scores.ranks scores |> Expect.equal (Array.fromList [ 4, 3, 1, 2, 5 ])
            )
        , test "some tied"
            (\_ ->
                -- Two pairs have identical scores in every game, so are really tied.
                let
                    scores =
                        Scores.fromLists "Test"
                            [ [ 0, 0, 0, 1 ]
                            , [ 0, 1, 1, 0 ]
                            , [ 2, 1, 1, 0 ]
                            , [ 0, 1, 1, 0 ]
                            , [ 0, 0, 0, 1 ]
                            ]
                in
                Scores.ranks scores |> Expect.equal (Array.fromList [ 4, 2, 1, 2, 4 ])
            )
        , test "all zero"
            (\_ ->
                -- With zero scores everywhere all tables will be tied for first.
                let
                    scores =
                        Scores.zero "Test" 5 4
                in
                Scores.ranks scores |> Expect.equal (Array.fromList [ 1, 1, 1, 1, 1 ])
            )
        ]
