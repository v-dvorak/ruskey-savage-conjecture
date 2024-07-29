
module Hypercube (
    Hypercube(..),
    Edge(..),
    Vertex(..),
    createHypercube,
    areAdjacent,
    generateHypercubeNeighbors
) where

-- Define a data type for Hypercube and other data types
data Hypercube = Hypercube { dimension :: Int, vertices :: [Vertex], edges :: [Edge] }
data Edge = Edge Vertex Vertex
    deriving (Eq, Ord)
instance Show Edge where
    show (Edge v1 v2) = "(" ++ show v1 ++ ", " ++ show v2 ++ ")"
newtype Vertex = Vertex { unVertex :: [Int] }
    deriving (Eq, Ord)
instance Show Vertex where
    show (Vertex v) = show v

-- Creates a hypercube of dimension n
createHypercube :: Int -> Hypercube
createHypercube n = Hypercube n _vertices _edges
  where
    _vertices = generateHypercubeVertices n
    _edges = generateHypercubeEdges _vertices

-- Check if two vertices are adjacent in a hypercube
areAdjacent :: Vertex -> Vertex -> Bool
areAdjacent (Vertex v1) (Vertex v2) = length (filter id $ zipWith (/=) v1 v2) == 1 -- two adjacent edges differ in exactly one coordinate

generateHypercubeNeighbors :: Vertex -> [Vertex]
generateHypercubeNeighbors (Vertex v) =
    let n = length v
        -- Generate neighbors by flipping each bit
        neighbors = [ Vertex (toggleBit v i) | i <- [0..n-1] ]
    in neighbors
  where
    -- Function to toggle the ith bit of a binary sequence
    toggleBit :: [Int] -> Int -> [Int]
    toggleBit bits i =
        let (before, rest) = splitAt i bits
            (currentBit : after) = rest
        in before ++ [1 - currentBit] ++ after

generateHypercubeVertices :: Int -> [Vertex]
generateHypercubeVertices n | n < 1  = [Vertex []]
generateHypercubeVertices n = [Vertex (0 : unVertex vertex) | vertex <- nextVertices] ++
                              [Vertex (1 : unVertex vertex) | vertex <- nextVertices]
    where
        nextVertices = generateHypercubeVertices (n - 1)

-- Generate all edges of the hypercube
generateHypercubeEdges :: [Vertex] -> [Edge]
generateHypercubeEdges _vertices = [Edge v1 v2 | v1 <- _vertices, v2 <- _vertices, areAdjacent v1 v2, v1 < v2]
