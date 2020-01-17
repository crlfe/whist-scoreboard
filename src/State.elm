module State exposing (..)

import Array exposing (Array)
import Array2 exposing (Array2)
import Html as H

type alias Model =
    { sheet : SheetModel
    , setup : Maybe SetupModel
    , alert : Maybe AlertModel
    }


type alias SheetModel =
    { inert : Bool
    , title : String
    , games : Int
    , tables : Int
    , values : Array2 Int
    , totals : Array Int
    , ranks : Maybe (Array Int)
    , marks : SheetModelMarks
    }


type alias SheetModelMarks =
    { game : Maybe Int
    , table : Maybe Int
    , explain : List ( Int, Int )
    }


type alias SetupModel =
    { inert : Bool
    , title : String
    , games : String
    , tables : String
    , oldValues : Array2 Int
    , newValues : Array2 Int
    }


type alias AlertModel =
    { title : String
    , body : List (H.Html Msg)
    }


type Msg
    = GotSheetMsg SheetMsg
    | GotSetupMsg SetupMsg
    | GotAlertMsg AlertMsg
    | Ignored


type SheetMsg
    = SetupClicked
    | ShowRanksClicked
    | HideRanksClicked
    | SheetKeyDown String
    | SheetMouseDown String
    | SheetFocused
    | SheetBlurred

type SetupMsg
    = ClearClicked
    | LoadClicked
    | SaveClicked
    | TitleChanged String
    | GamesChanged String
    | TablesChanged String
    | CancelClicked
    | OkClicked


type AlertMsg
    = CloseClicked
