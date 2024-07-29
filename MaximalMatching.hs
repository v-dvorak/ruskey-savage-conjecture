module MaximalMatching (
    maximalMatchings
) where

import Hypercube

-- Find all maximal matchings in the hypercube
maximalMatchings :: Hypercube -> [[Edge]]
maximalMatchings (Hypercube _ _ edges) = maximalMatchingsRec edges edges [] []

-- Recursive function to find all maximal matchings
maximalMatchingsRec :: [Edge] -> [Edge] -> [Edge] -> [[Edge]] -> [[Edge]]
maximalMatchingsRec edges [] current allMatchings
  | isMaximal current edges = current : allMatchings
  | otherwise = allMatchings
maximalMatchingsRec edges (e@(Edge v1 v2):es) current allMatchings
  -- v1 and v2 are still not used, they can be added to the matching (and also try to leave this edge out )
  | not (v1 `elem` usedVertices || v2 `elem` usedVertices) =
      maximalMatchingsRec edges es (e : current) allMatchings ++ maximalMatchingsRec edges es current allMatchings
  -- recursively try to add other edges
  | otherwise = maximalMatchingsRec edges es current allMatchings
  where
    usedVertices = concatMap (\(Edge a b) -> [a, b]) current

-- Checks if a matching is maximal
isMaximal :: [Edge] -> [Edge] -> Bool
-- for every edge try to add it to the matching, if there exists any edge that can be added, then the matching is not maximal
isMaximal matching allEdges = not (any canAddEdge remainingEdges)
  where
    usedVertices = concatMap (\(Edge v1 v2) -> [v1, v2]) matching
    remainingEdges = filter (`notElem` matching) allEdges
    canAddEdge (Edge v1 v2) = areAdjacent v1 v2
      && notElem v1 usedVertices
      && notElem v2 usedVertices