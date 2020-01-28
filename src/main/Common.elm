module Common exposing
    ( KeyboardEvent
    , arrayGet2
    , arrayMapOne
    , cssClasses
    , decodeKeyboardEvent
    , sendMessage
    , xif
    )

import Array exposing (Array)
import Html.Attributes as HA
import Json.Decode as JD
import Maybe.Extra
import Task


type alias KeyboardEvent =
    { id : String
    , key : String
    , altKey : Bool
    , ctrlKey : Bool
    , metaKey : Bool
    , shiftKey : Bool
    }


arrayMapOne : (a -> a) -> Int -> Array a -> Array a
arrayMapOne func index array =
    Array.get index array
        |> Maybe.map func
        |> Maybe.Extra.unwrap array
            (\value -> Array.set index value array)


cssClasses =
    { dialog =
        { action = HA.class "action"
        , close = HA.class "close"
        , dialog = HA.class "dialog"
        , dialogOuter = HA.class "dialogOuter"
        , dialogInner = HA.class "dialogInner"
        , title = HA.class "title"
        }
    , setup =
        { error = HA.class "tError"
        , menu = HA.class "tMenu"
        , fields = HA.class "tFields"
        , status = HA.class "tStatus"
        }
    , sheet =
        { sheet = HA.class "sheet"
        , main = HA.class "sMain"
        , left = HA.class "sLeft"
        , right = HA.class "sRight"
        , topLeft = HA.class "sTopLeft"
        , topRight = HA.class "sTopRight"
        , row = HA.class "sRow"
        , box = HA.class "sBox"
        , label = HA.class "sLabel"
        , tables = HA.class "sTables"
        , totals = HA.class "sTotals"
        , ranks = HA.class "sRanks"
        , top = HA.class "sTop"
        , games = HA.class "sGames"
        , curr = HA.class "sCurr"
        , currGame = HA.class "sCurrGame"
        , currGameTotal = HA.class "sCurrGameTotal"
        , currTable = HA.class "sCurrTable"
        , mark = HA.class "sMark"
        , dark = HA.class "sDark"
        , light = HA.class "sLight"
        , winner = HA.class "sWinner"
        , button = HA.class "sButton"
        }
    }


arrayGet2 : Int -> Int -> Array (Array a) -> Maybe a
arrayGet2 i j xs =
    Array.get i xs
        |> Maybe.andThen (Array.get j)


decodeKeyboardEvent : JD.Decoder KeyboardEvent
decodeKeyboardEvent =
    JD.map6 KeyboardEvent
        (JD.at [ "target", "id" ] JD.string)
        (JD.field "key" JD.string)
        (JD.field "altKey" JD.bool)
        (JD.field "ctrlKey" JD.bool)
        (JD.field "metaKey" JD.bool)
        (JD.field "shiftKey" JD.bool)


sendMessage : m -> Cmd m
sendMessage msg =
    Task.succeed msg |> Task.perform identity


xif : Bool -> a -> a -> a
xif test x y =
    if test then
        x

    else
        y
