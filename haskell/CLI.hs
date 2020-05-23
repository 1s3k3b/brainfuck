module Main where

import Compiler
import System.Environment (getArgs)
import System.IO

main = do
    args <- getArgs
    content <- readFile (args !! 0)
    compile (parse content) (args !! 1)