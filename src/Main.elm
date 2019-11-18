module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy


type alias Model =
    { numTables : Int
    , numGames : Int
    , scores : Dict ( Int, Int ) Int
    }


type Msg
    = TablesInput String
    | GamesInput String
    | ClearClick
    | CellClick Int Int


main =
    Browser.sandbox { init = init, view = view, update = update }


init : Model
init =
    { numTables = 30
    , numGames = 30
    , scores = Dict.empty
    }


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.table []
            [ viewHead model |> H.thead []
            , List.range 1 model.numTables
                |> List.map (viewRow model)
                |> H.tbody []
            ]
        ]


viewHead model =
    [ H.tr []
        [ H.td [ HA.class "menu" ]
            [ H.button [] [ H.text "Menu" ]
            , viewMenu model
            ]
        , H.th [ HA.colspan model.numGames ] [ H.text "Games" ]
        , H.td [] []
        ]
    , H.tr
        []
        (List.concat
            [ [ H.th [ HA.class "table", HA.scope "col" ] [ H.text "Table" ] ]
            , List.range 1 model.numGames
                |> List.map String.fromInt
                |> List.map (\name -> H.th [ HA.scope "col" ] [ H.text name ])
            , [ H.th [ HA.class "total", HA.scope "col" ] [ H.text "Total" ] ]
            ]
        )
    ]


viewMenu model =
    H.div [ HA.class "menu-body" ]
        [ H.label [ HA.for "numTables" ] [ H.text "Tables" ]
        , H.input
            [ HA.id "numTables"
            , HA.type_ "number"
            , HA.min "1"
            , HA.max "50"
            , HA.value (String.fromInt model.numTables)
            , HE.onInput TablesInput
            ]
            []
        , H.label [ HA.for "numGames" ] [ H.text "Games" ]
        , H.input
            [ HA.id "numGames"
            , HA.type_ "number"
            , HA.min "1"
            , HA.max "50"
            , HA.value (String.fromInt model.numGames)
            , HE.onInput GamesInput
            ]
            []
        , H.button [ HA.style "grid-column-end" "span 2", HE.onClick ClearClick ] [ H.text "Zero all scores" ]
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
            [ [ H.th [ HA.class "table", HA.scope "row" ] [ H.text (String.fromInt table) ] ]
            , List.range 1 model.numGames |> List.map (viewCellAt model table)
            , [ H.td [ HA.class "total" ] [ H.text (String.fromInt total) ] ]
            ]
        )


viewCellAt model table game =
    model.scores
        |> Dict.get ( table, game )
        |> Maybe.withDefault 0
        |> viewCell model table game


viewCell model table game value =
    let
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
        TablesInput input ->
            { model | numTables = String.toInt input |> Maybe.withDefault model.numTables |> clamp 1 50 }

        GamesInput input ->
            { model | numGames = String.toInt input |> Maybe.withDefault model.numGames |> clamp 1 50 }

        ClearClick ->
            { model | scores = Dict.empty }

        CellClick table game ->
            { model | scores = model.scores |> incrementScoreAt table game }


incrementScoreAt table game =
    Dict.update ( table, game ) (\value -> Maybe.withDefault 0 value + 1 |> modBy 5 |> Maybe.Just)
