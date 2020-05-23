{-# LANGUAGE LambdaCase #-}
module Compiler (compile, parse) where

import System.IO
import Data.Maybe (mapMaybe)
import Data.List (uncons, unfoldr, group, mapAccumL)

data Command = GoRight Int
                | Add Int
                | LoopL Int
                | LoopR Int
                | WriteChar
                | ReadChar
                | Const Int
            deriving (Eq, Show)

type Source = [Command]

parse :: String -> Source
parse =
    optimise .
    snd .
    mapAccumL pairLoops [] .
    snd .
    mapAccumL countLoopLs 0 .
    mapMaybe char2bfc

char2bfc :: Char -> Maybe Command
char2bfc '>' = Just $ GoRight 1
char2bfc '<' = Just $ GoRight (-1)
char2bfc '+' = Just $ Add 1
char2bfc '-' = Just $ Add (-1)
char2bfc '[' = Just $ LoopL undefined
char2bfc ']' = Just $ LoopR undefined
char2bfc '.' = Just WriteChar
char2bfc ',' = Just ReadChar
char2bfc _ = Nothing

countLoopLs :: Int -> Command -> (Int, Command)
countLoopLs n (LoopL _) = (n + 1, LoopL n)
countLoopLs n b = (n, b)

pairLoops :: [Int] -> Command -> ([Int], Command)
pairLoops st (LoopL x) = (x:st, LoopL x)
pairLoops (s:st) (LoopR _) = (st, LoopR s)
pairLoops st b = (st, b)

optimise :: Source -> Source
optimise = within (/=) . iterate (unfoldr $ uncons . reduce)

reduce :: [Command] -> [Command]
reduce [] = []
reduce (Add a : Add b : bs) = Add (a + b) : bs
reduce (GoRight a : GoRight b : bs) = GoRight (a + b) : bs
reduce (Const a : Add b : bs) = Const (a + b) : bs
reduce (Add a : Const b : bs) = Const b : bs
reduce (Const a : Const b : bs) = Const b : bs
reduce (LoopL _ : Add 1 : LoopR _ : bs) = Const 0 : bs
reduce (LoopL _ : Add (-1) : LoopR _ : bs) = Const 0 : bs
reduce (Add 0 : bs) = bs
reduce (GoRight 0 : bs) = bs
reduce bs = bs

within :: (a -> a -> Bool) -> [a] -> a
within f (x:y:xs)
    | f x y = within f xs
    | otherwise = x

compile :: Source -> FilePath -> IO ()
compile input file = do
    handle <- openFile file WriteMode
    hPutStrLn handle $ unlines
        [
            "section .bss",
            "    memory resb 30000",
            "section .text",
            "    global _start",
            "_printChar:",
            "    mov rdx, 1",
            "    mov rbx, 1",
            "    mov rax, 4",
            "    int 80h",
            "    ret",
            "_readChar:",
            "    mov rax, 3",
            "    xor rbx, rbx",
            "    mov rdx, 1",
            "    int 80h",
            "    ret",
            "_start:",
            "    mov rcx, memory"
        ]
    mapM_ (bf2asm handle) input
    hPutStrLn handle "    mov rax, 1"
    hPutStrLn handle "    xor rbx, rbx"
    hPutStr handle "    int 80h"
    hClose handle

bf2asm :: Handle -> Command -> IO ()
bf2asm handle = hPutStrLn handle . \case
    GoRight x -> "    " ++ case () of
        _ | x == 1 -> "inc rcx"
          | x == (-1) -> "dec rcx"
          | x > 0 -> "add rcx," ++ show x
          | otherwise -> "sub rcx," ++ show (-x)
    Add x -> unlines
        [
            "    mov al, [rcx]",
            "    " ++ case () of
              _ | x == 1 -> "inc al"
                | x == (-1) -> "dec al"
                | x > 0 -> "add al, " ++ show x
                | otherwise -> "sub al, " ++ show (-x),
            "    mov [rcx], al"
        ]
    LoopL x -> unlines
        [
            "_LS" ++ show x ++ ":",
            "    mov al, [rcx]",
            "    test al, al",
            "    jz _LE" ++ show x
        ]
    LoopR x -> unlines
        [
            "    jmp _LS" ++ show x,
            "_LE" ++ show x ++ ":"
        ]
    WriteChar -> "    call _printChar"
    ReadChar  -> "    call _readChar"
    Const x -> unlines
        [
            "    " ++ case x of
                0 -> "xor al, al"
                _ -> "mov al, " ++ show x,
            "    mov [rcx], al"
        ]