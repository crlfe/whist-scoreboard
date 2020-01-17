module Setup exposing (open, update, view)

import Array exposing (Array)
import Array2 exposing (Array2)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import State exposing (..)


open : Model -> Model
open model =
    let
        sheet =
            model.sheet
    in
    { model
        | sheet = { sheet | inert = True }
        , setup =
            Just
                { inert = False
                , title = sheet.title
                , games = String.fromInt sheet.games
                , tables = String.fromInt sheet.tables
                , oldValues = sheet.values
                , newValues = sheet.values
                }
    }


view : SetupModel -> H.Html Msg
view model =
    H.div [ HA.class "tDialog" ]
        [ H.div [ HA.class "tTitle" ]
            [ H.text "Setup"
            , H.button
                [ HA.disabled model.inert
                , HE.onClick (GotSetupMsg CancelClicked)
                ]
                [ H.text "X"
                ]
            ]
        , H.div [ HA.class "tActions" ]
            [ H.button
                [ HA.disabled model.inert
                , HE.onClick (GotSetupMsg ClearClicked)
                ]
                [ H.text "Clear"
                ]
            , H.button
                [ HA.disabled model.inert
                , HE.onClick (GotSetupMsg LoadClicked)
                ]
                [ H.text "Load"
                ]
            , H.button
                [ HA.disabled model.inert
                , HE.onClick (GotSetupMsg SaveClicked)
                ]
                [ H.text "Save"
                ]
            ]
        , H.div [ HA.class "tFields" ]
            [ H.label [ HA.for "tTitle" ] [ H.text "Title" ]
            , H.input
                [ HA.id "tTitle"
                , HA.value model.title
                , HA.disabled model.inert
                , HE.onInput (TitleChanged >> GotSetupMsg)
                ]
                []
            , H.label [ HA.for "tGames" ] [ H.text "Games" ]
            , H.input
                [ HA.id "tGames"
                , HA.type_ "numeric"
                , HA.value model.games
                , HA.disabled model.inert
                , HE.onInput (GamesChanged >> GotSetupMsg)
                ]
                []
            , H.div [ HA.class "tError" ]
                [ H.text (errorFromLength model.games)
                ]
            , H.label [ HA.for "tTables" ] [ H.text "Tables" ]
            , H.input
                [ HA.id "tTables"
                , HA.type_ "numeric"
                , HA.value model.tables
                , HA.disabled model.inert
                , HE.onInput (TablesChanged >> GotSetupMsg)
                ]
                []
            , H.div [ HA.class "tError" ]
                [ H.text (errorFromLength model.tables)
                ]
            ]
        , statusFromModel model
        , H.div [ HA.class "tActions" ]
            [ H.button
                [ HA.disabled model.inert
                , HE.onClick (GotSetupMsg CancelClicked)
                ]
                [ H.text "Cancel"
                ]
            , H.button
                [ HA.disabled
                    (model.inert
                        || ("" /= errorFromLength model.games)
                        || ("" /= errorFromLength model.tables)
                    )
                , HE.onClick (GotSetupMsg OkClicked)
                ]
                [ H.text "OK" ]
            ]
        ]


update : SetupMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.setup of
        Just setup ->
            if not setup.inert then
                updateInternal msg model setup

            else
                ( model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


updateInternal : SetupMsg -> Model -> SetupModel -> ( Model, Cmd Msg )
updateInternal msg model setup =
    let
        sheet =
            model.sheet
    in
    case msg of
        ClearClicked ->
            ( { model | setup = Just { setup | newValues = Array.empty } }, Cmd.none )

        LoadClicked ->
            ( model, Cmd.none )

        SaveClicked ->
            ( model, Cmd.none )

        TitleChanged title ->
            ( { model | setup = Just { setup | title = title } }, Cmd.none )

        GamesChanged games ->
            ( { model | setup = Just { setup | games = games } }, Cmd.none )

        TablesChanged tables ->
            ( { model | setup = Just { setup | tables = tables } }, Cmd.none )

        CancelClicked ->
            ( { model | sheet = { sheet | inert = False }, setup = Nothing }, Cmd.none )

        OkClicked ->
            ( { model | sheet = updateSheet setup model.sheet, setup = Nothing }, Cmd.none )


errorFromLength : String -> String
errorFromLength value =
    case String.toInt value of
        Just n ->
            if n < 1 then
                "too small"

            else if n > 100 then
                "too large"

            else
                ""

        Nothing ->
            "invalid"


statusFromModel : SetupModel -> H.Html msg
statusFromModel setup =
    if setup.oldValues == setup.newValues then
        H.div [ HA.class "tMessage" ]
            [ H.text "No scores will be changed"
            ]

    else if Array.isEmpty setup.newValues then
        H.div [ HA.class "tMessage", HA.class "tError" ]
            [ H.text "OK will zero all previous scores"
            ]

    else
        H.div [ HA.class "tMessage", HA.class "tError" ]
            [ H.text "OK will replace all previous scores"
            ]


updateSheet : SetupModel -> SheetModel -> SheetModel
updateSheet setup sheet =
    let
        games =
            Maybe.withDefault sheet.games (String.toInt setup.games)

        tables =
            Maybe.withDefault sheet.tables (String.toInt setup.tables)

        values =
            Array2.initialize
                games
                tables
                (\i j -> Array2.get i j setup.newValues |> Maybe.withDefault 0)
    in
    { inert = False
    , title = setup.title
    , games = games
    , tables = tables
    , totals = Array.empty
    , values = values
    , marks = { game = Nothing, table = Nothing, explain = [] }
    , ranks = Nothing
    }
