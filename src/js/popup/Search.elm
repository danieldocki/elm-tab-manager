module Search exposing (queryToListTab)

import Data exposing (..)
import Regex exposing (..)
import List.Extra exposing (..)

{- heuristics search using splitted words from user queries-}

search : List Ftab -> List String -> List (Ftab, Int)
search tabs keywords =
  let
    re = "\\b(" ++ String.join "|" keywords ++ ")"
            |> regex 
            |> caseInsensitive  
    countMatches = List.length << Regex.find All re << .name
    indexes = List.map countMatches tabs
    tup = zip tabs indexes
  in
    List.filter (((/=) 0) << Tuple.second) tup

{- produce a querried list of tabs using model-}
queryToListTab : Model -> List Ftab
queryToListTab model = 
    let
        keywords =
          String.words << String.toLower << Regex.escape <| model.query

        querriedTabs =
            if model.query == "" then model.tabs
            else
               search model.tabs keywords
                  |> List.map (\(t, i) -> ({t | index = -i}, i))
                  |> List.map Tuple.first
        selectTab : Int -> Ftab -> Ftab
        selectTab index tab =  if (index == model.selected % List.length querriedTabs) && (index /= model.deselect) then
                                {tab | selected = True}
                             else
                                {tab | selected = False}
    in List.indexedMap selectTab <| List.sortBy .index querriedTabs