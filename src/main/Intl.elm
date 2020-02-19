module Intl exposing (Locale(..), Localized, localeDisplayNames, localeFromLanguages, localeFromName, localeName, localize)

import Time


type Locale
    = English
    | French


type alias Localized =
    { name : String
    , buttons :
        { cancel : String
        , close : String
        , new : String
        , ok : String
        , open : String
        , ranksHide : String
        , ranksShow : String
        , save : String
        , setup : String
        }
    , labels :
        { about : String
        , error : String
        , games : String
        , language : String
        , message : String
        , rank : String
        , setup : String
        , table : String
        , tables : String
        , total : String
        , title : String
        }
    , status :
        { lengthInvalid : String
        , lengthTooSmall : String
        , lengthTooLarge : String
        , totalColon : Int -> String
        , valuesCleared : String
        , valuesCropped : String
        , valuesReplaced : String
        , valuesUnchanged : String
        , whistEvent : String
        , whistEventDated : Time.Zone -> Time.Posix -> String
        }
    }


localeFromLanguages : List String -> Maybe Locale
localeFromLanguages languages =
    List.filterMap
        (\v ->
            case String.split "-" v of
                "en" :: _ ->
                    Just English

                "fr" :: _ ->
                    Just French

                _ ->
                    Nothing
        )
        languages
        |> List.head


localeDisplayNames : List ( String, String )
localeDisplayNames =
    [ ( "en", "English" )
    , ( "fr", "Français" )
    ]


localeName : Locale -> String
localeName locale =
    case locale of
        English ->
            "en"

        French ->
            "fr"


localeFromName : String -> Maybe Locale
localeFromName name =
    case name of
        "en" ->
            Just English

        "fr" ->
            Just French

        _ ->
            Nothing


localize : Locale -> Localized
localize lang =
    case lang of
        English ->
            localeEnglish

        French ->
            localeFrench


localeEnglish : Localized
localeEnglish =
    { name = "en"
    , buttons =
        { cancel = "Cancel"
        , close = "Close"
        , new = "New"
        , ok = "Ok"
        , open = "Open"
        , ranksHide = "Hide Ranks"
        , ranksShow = "Show Ranks"
        , save = "Save"
        , setup = "Setup"
        }
    , labels =
        { about = "About"
        , error = "Error"
        , games = "Games"
        , language = "Language"
        , message = "Message"
        , rank = "Rank"
        , setup = "Setup"
        , table = "Table"
        , tables = "Tables"
        , title = "Title"
        , total = "Total"
        }
    , status =
        { lengthInvalid = "invalid"
        , lengthTooSmall = "too small"
        , lengthTooLarge = "too large"
        , totalColon = \v -> "Total: " ++ String.fromInt v
        , valuesCleared = "Ok will zero all previous scores"
        , valuesCropped = "Ok will discard scores outside the board"
        , valuesReplaced = "Ok will replace all previous scores"
        , valuesUnchanged = "No scores will be changed"
        , whistEvent = "Whist"
        , whistEventDated = \z p -> "Whist " ++ formatRfc3339Date z p
        }
    }


localeFrench : Localized
localeFrench =
    { name = "fr"
    , buttons =
        { cancel = "Annuler"
        , close = "Fermer"
        , new = "Nouveau"
        , ok = "Ok"
        , open = "Ouvrir"
        , ranksHide = "Masquer"
        , ranksShow = "Classement"
        , save = "Enregistrer"
        , setup = "Paramètres"
        }
    , labels =
        { about = "À propos"
        , error = "Erreur"
        , games = "Parties"
        , language = "Langue"
        , message = "Message"
        , rank = "Rang"
        , setup = "Paramètres"
        , table = "Table"
        , tables = "Tables"
        , title = "Titre"
        , total = "Total"
        }
    , status =
        { lengthInvalid = "non valide"
        , lengthTooSmall = "trop peu"
        , lengthTooLarge = "trop grande"
        , totalColon = \v -> "Total: " ++ String.fromInt v
        , valuesCleared = "Ok efface tous les résultats"
        , valuesCropped = "Ok efface les résultats en dehors du tableau"
        , valuesReplaced = "Ok remplace tous les résultats"
        , valuesUnchanged = "Ne change aucun résultat"
        , whistEvent = "Whist"
        , whistEventDated = \z p -> "Whist " ++ formatRfc3339Date z p
        }
    }


formatRfc3339Date : Time.Zone -> Time.Posix -> String
formatRfc3339Date zone time =
    let
        year =
            Time.toYear zone time |> String.fromInt

        month =
            Time.toMonth zone time |> monthToInt |> String.fromInt

        day =
            Time.toDay zone time |> String.fromInt
    in
    String.concat
        [ year
        , "-"
        , String.padLeft 2 '0' month
        , "-"
        , String.padLeft 2 '0' day
        ]


monthToInt : Time.Month -> Int
monthToInt month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12
