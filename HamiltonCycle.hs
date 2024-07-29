module HamiltonCycle (
    hasHamiltonCycle
) where

import Hypercube
import Data.List(delete)
import Debug.Trace

import qualified Data.Map as Map
import Data.Map (Map)
import Data.Maybe (fromJust)

import qualified Data.Set as Set
import Data.Set (Set)

-- Turns on debug mode
debugMode :: Bool
debugMode = False
-- Helper function to conditionally print trace messages
traceIf :: String -> a -> a
traceIf msg x = if debugMode then trace msg x else x

-- Creates a bidirectional map from a list of edges
createBidirectionalMap :: [Edge] -> Map Vertex Vertex
createBidirectionalMap edges = Map.fromList $ concatMap edgeToTuples edges
  where
    edgeToTuples (Edge v1 v2) = [(v1, v2), (v2, v1)]

-- Lookup in the bidirectional map
lookupVertex :: Vertex -> Map Vertex Vertex -> Maybe Vertex
lookupVertex = Map.lookup

-- Lookup function, True/False
lookupIsSuccessful :: Maybe a -> Bool
lookupIsSuccessful (Just _) = True
lookupIsSuccessful Nothing = False

-- Given an (Edge v1 v2), removes both (Edge v1 v2) and (Edge v2 v1) from given list of edges
removeUndirectedEdge :: [Edge] -> Edge -> [Edge]
removeUndirectedEdge edges (Edge v1 v2) = secondDel
    where
        firstDel = delete (Edge v1 v2) edges
        secondDel = delete (Edge v2 v1) firstDel

-- Check if a Hamiltonian cycle exists
hasHamiltonCycle :: [Vertex] -> [Edge] -> Bool
hasHamiltonCycle vertices mandatoryEdges =
    _hasHamiltonCycle vertices (createBidirectionalMap mandatoryEdges) mandatoryEdges generateHypercubeNeighbors

-- Check if a Hamiltonian cycle exists, main algorithm
_hasHamiltonCycle :: [Vertex]               -- List of vertices
                 -> Map Vertex Vertex       -- Mandatory edge lookup
                 -> [Edge]                  -- Mandatory edges
                 -> (Vertex -> [Vertex])    -- Function to get neighbors
                 -> Bool                    -- Result: True if Hamilton cycle exists, False otherwise
_hasHamiltonCycle vertices mandatoryNeighbors mandatoryEdges neighbors =
    traceIf (show mandatoryNeighbors) $ dfs startVertex (Set.insert startVertex Set.empty) mandatoryEdges
  where
    startVertex = head vertices
    -- Depth-first search function to find Hamiltonian cycle
    dfs :: Vertex -> Set Vertex -> [Edge] -> Bool
    dfs currentVertex visitedVertices remainingMandatoryEdges
        -- Debug print
        |traceIf ("Current Vertex: " ++ show currentVertex ++ ", Path: " ++ show visitedVertices ++ ", Remaining Mandatory Edges: " ++ show remainingMandatoryEdges) False = undefined
        -- All vertices and mandatory edges were visited
        | Set.size visitedVertices == length vertices
            && null remainingMandatoryEdges
            && elem startVertex (neighbors currentVertex) =
               traceIf ("Cycle found with path: " ++ show visitedVertices) True
        -- There is a mandatory edge to visit (and the algorithm will go this way to save time)
        | lookupIsSuccessful lookupResult
            && Set.notMember (fromJust lookupResult) visitedVertices =
                let nextVertex = fromJust lookupResult
                    updatedMandatoryEdges = removeUndirectedEdge remainingMandatoryEdges (Edge currentVertex nextVertex)
                in traceIf ("Following mandatory edge from " ++ show currentVertex ++ " to " ++ show nextVertex ++ ", Updated edges:" ++ show updatedMandatoryEdges) $
                    dfs nextVertex (Set.insert nextVertex visitedVertices) updatedMandatoryEdges
        -- If there is no mandatory edge, try all possible neighbors
        | otherwise =
                let currentNeighbors = neighbors currentVertex
                    validNextVertices = filter (`notElem` visitedVertices) currentNeighbors
                in traceIf ("Current vertex: " ++ show currentVertex ++ ", valid next vertices: " ++ show validNextVertices) $
                    any (\v -> dfs v (Set.insert v visitedVertices) remainingMandatoryEdges) validNextVertices
      where
        lookupResult = lookupVertex currentVertex mandatoryNeighbors

-- TESTS
removalTest :: Bool
removalTest = test edges (Edge (Vertex [1, 1, 0]) (Vertex [1, 1, 1])) [Edge (Vertex [0, 1, 1]) (Vertex [0, 0, 1])]
    && test edges (Edge (Vertex [1, 1, 1])  (Vertex [1, 1, 0])) [Edge (Vertex [0, 1, 1]) (Vertex [0, 0, 1])]
    && test edges (Edge (Vertex [2, 2, 2])  (Vertex [1, 1, 0])) edges
    where
        test :: [Edge] -> Edge -> [Edge] -> Bool
        test allEdges toRemove result = removeUndirectedEdge allEdges toRemove == result
        edges = [Edge (Vertex [1, 1, 0]) (Vertex [1, 1, 1]), Edge (Vertex [0, 1, 1]) (Vertex [0, 0, 1])]
