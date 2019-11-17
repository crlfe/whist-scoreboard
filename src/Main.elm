module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias Model =
    { numTables : Int
    , numGames : Int
    , scores : Dict ( Int, Int ) Int
    }


type Msg
    = ClearClick
    | TablesInput String
    | GamesInput String
    | CellClick Int Int


main =
    Browser.sandbox { init = init, view = view, update = update }


init : Model
init =
    { numTables = 10, numGames = 10, scores = Dict.empty }


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.div []
            [ H.label []
                [ H.text "Tables"
                , H.input
                    [ HA.type_ "number"
                    , HA.min "1"
                    , HA.max "100"
                    , HA.value (String.fromInt model.numTables)
                    , HE.onInput TablesInput
                    ]
                    []
                ]
            , H.label []
                [ H.text "Games"
                , H.input
                    [ HA.type_ "number"
                    , HA.min "1"
                    , HA.max "100"
                    , HA.value (String.fromInt model.numGames)
                    , HE.onInput GamesInput
                    ]
                    []
                ]
            , H.button [ HE.onClick ClearClick ] [ H.text "Clear" ]
            ]
        , H.table []
            [ viewHead model |> H.thead []
            , List.range 1 model.numTables
                |> List.map (viewRow model)
                |> H.tbody []
            ]
        ]


viewHead model =
    [ H.tr []
        [ H.th [ HA.scope "col" ] [ H.text "Table" ]
        , H.th [ HA.colspan model.numGames, HA.scope "colgroup" ] [ H.text "Games" ]
        , H.th [ HA.scope "col" ] [ H.text "Total" ]
        ]
    , H.tr []
        (List.concat
            [ [ H.td [] [] ]
            , List.range 1 model.numGames
                |> List.map String.fromInt
                |> List.map (\name -> H.th [ HA.scope "col" ] [ H.text name ])
            , [ H.td [] [] ]
            ]
        )
    ]


viewRow model table =
    let
        total =
            List.range 1 model.numGames
                |> List.map (\game -> model.scores |> Dict.get ( table, game ) |> Maybe.withDefault 0)
                |> List.sum
    in
    H.tr []
        (List.concat
            [ [ H.th [ HA.scope "row" ] [ H.text (String.fromInt table) ] ]
            , List.range 1 model.numGames |> List.map (viewCell model table)
            , [ H.td [] [ H.text (String.fromInt total) ] ]
            ]
        )


viewCell model table game =
    let
        value =
            model.scores |> Dict.get ( table, game ) |> Maybe.withDefault 0

        imgAlt =
            String.fromInt value

        imgSrc =
            String.concat [ "tally-", String.fromInt value, ".svg" ]
    in
    H.td [ HA.class "tally" ]
        [ H.button [ HE.onClick (CellClick table game) ]
            [ H.img [ HA.alt imgAlt, HA.src imgSrc ] [] ]
        ]


viewImage value =
    let
        string =
            String.fromInt value
    in
    H.img [ HA.alt string, HA.src (String.concat [ "tally-", string, ".svg" ]) ] []


update : Msg -> Model -> Model
update msg model =
    case msg of
        ClearClick ->
            model

        TablesInput input ->
            { model | numTables = String.toInt input |> Maybe.withDefault model.numTables |> clamp 1 100 }

        GamesInput input ->
            { model | numGames = String.toInt input |> Maybe.withDefault model.numGames |> clamp 1 100 }

        CellClick table game ->
            { model | scores = model.scores |> incrementScoreAt table game }


incrementScoreAt table game =
    Dict.update ( table, game ) (\value -> Maybe.withDefault 0 value + 1 |> modBy 5 |> Maybe.Just)
