import HamiltonianCycle
import Hypercube
import MaximalMatching
import Debug.Trace

testAllMatchings :: Int -> Bool
testAllMatchings n =
    let h = createHypercube n
        matchings = maximalMatchings h
    in trace ("Total matchings: " ++ show (length matchings)) $ all (hasHamiltonianCycle (vertices h)) matchings

dimension2test :: Bool
dimension2test = testAllMatchings 2

dimension3test :: Bool
dimension3test = testAllMatchings 3

dimension4test :: Bool
dimension4test = testAllMatchings 4

test1 :: Bool
test1 = hasHamiltonianCycle (vertices h) mandatoryEdges
    where
        h = createHypercube 2
        mandatoryEdges = head (maximalMatchings h)

test2 :: Bool
test2 = hasHamiltonianCycle (vertices h) mandatoryEdges
    where
        h = createHypercube 2
        mandatoryEdges =  [head (head (maximalMatchings h))]

test3 :: Bool
test3 = hasHamiltonianCycle (vertices h) mandatoryEdges
    where
        h = createHypercube 2
        mandatoryEdges =  tail (head (maximalMatchings h))

main = do
    print test1
    let results = [("Dimension 2", dimension2test), ("Dimension 3", dimension3test), ("Dimension 4", dimension4test)]
    mapM_ printResult results
  where
    printResult (name, result) = putStrLn $ name ++ ": " ++ show result