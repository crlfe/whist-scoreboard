module Array2 exposing (Array2, empty, fromGenerator, fromLists, get, getMajor, getMinor, indexedMap, initialize, majorLength, map, mapAt, minorLength, set, slice)

import Array exposing (Array)


type alias Array2 a =
    Array (Array a)


empty : Array2 a
empty =
    Array.empty


initialize : Int -> Int -> (Int -> Int -> a) -> Array2 a
initialize majors minors func =
    Array.initialize majors (\i -> Array.initialize minors (\j -> func i j))


fromGenerator : Int -> Int -> (b -> ( a, b )) -> b -> ( Array2 a, b )
fromGenerator majors minors gen seed =
    consFromGenerator [] majors (consFromGenerator [] minors gen) seed
        |> Tuple.mapFirst fromLists


fromLists : List (List a) -> Array2 a
fromLists lists =
    let
        minors =
            List.map List.length lists |> List.minimum |> Maybe.withDefault 0
    in
    List.map (Array.fromList >> Array.slice 0 minors) lists |> Array.fromList


majorLength : Array2 a -> Int
majorLength array =
    Array.length array


minorLength : Array2 a -> Int
minorLength array =
    Maybe.map Array.length (Array.get 0 array)
        |> Maybe.withDefault 0


get : Int -> Int -> Array2 a -> Maybe a
get majorIndex minorIndex array =
    Maybe.andThen (Array.get minorIndex) (Array.get majorIndex array)


getMajor : Int -> Array2 a -> Maybe (Array a)
getMajor index array =
    Array.get index array


getMinor : Int -> Array2 a -> Maybe (Array a)
getMinor index array =
    Array.map (Array.get index) array
        |> Array.foldl (Maybe.map2 Array.push) (Just Array.empty)


set : Int -> Int -> a -> Array2 a -> Array2 a
set majorIndex minorIndex value array =
    arrayMapAt majorIndex (Array.set minorIndex value) array


mapAt : Int -> Int -> (a -> a) -> Array2 a -> Array2 a
mapAt majorIndex minorIndex func array =
    arrayMapAt majorIndex (arrayMapAt minorIndex func) array


slice : { top : Int, left : Int, bottom : Int, right : Int } -> Array2 a -> Array2 a
slice { top, left, bottom, right } array =
    Array.map (Array.slice left right) (Array.slice top bottom array)


transpose : Array2 a -> Array2 a
transpose array =
    Array.initialize
        (minorLength array)
        (\i -> getMinor i array |> Maybe.withDefault Array.empty)


map : (a -> b) -> Array2 a -> Array2 b
map func array =
    Array.map (Array.map func) array


indexedMap : (Int -> Int -> a -> b) -> Array2 a -> Array2 b
indexedMap func array =
    Array.indexedMap (\i -> Array.indexedMap (\j -> func i j)) array


majorMap : (Array a -> b) -> Array2 a -> Array b
majorMap func array =
    Array.map func array


minorMap : (Array a -> b) -> Array2 a -> Array b
minorMap func array =
    Array.map func (transpose array)



-- UTILITY FUNCTIONS


arrayMapAt : Int -> (a -> a) -> Array a -> Array a
arrayMapAt index func array =
    Array.get index array
        |> Maybe.map (\value -> Array.set index (func value) array)
        |> Maybe.withDefault array


consFromGenerator : List a -> Int -> (b -> ( a, b )) -> b -> ( List a, b )
consFromGenerator xs n gen seed =
    if n < 1 then
        ( xs, seed )

    else
        let
            ( x, newSeed ) =
                gen seed
        in
        consFromGenerator (x :: xs) (n - 1) gen newSeed
