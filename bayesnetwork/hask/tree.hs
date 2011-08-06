import System.IO
import Data.List
import Data.Char
import Control.Parallel.Strategies

-- I make my own data rather then importing Data.Tree for educational pruposes
-- 
data CTree elem num = Leaf
                    | Node { getElem::elem
                           , getNum::num
                           , getTree::(CTree elem num)}
                    | CTree {children::[CTree elem num]}
    deriving (Show, Eq, Ord)

-- Recursive function to count chars, there should be other methods
-- probably better methods.
mkCTree :: String -> CTree Char Int
mkCTree [] = Leaf
mkCTree [' '] = CTree ([Node c 0 Leaf | c <- ['a'..'z']]++[Node ' ' 1 Leaf])
mkCTree (x:xs) = CTree (front++new++end++[Node ' ' 0 Leaf])
    where
        front = [Node c 0 Leaf| c <- init ['a'..x]]
        end = [Node c 0 Leaf| c <- tail [x..'z']]
        new = [Node x 1 (mkCTree xs)]

--Both Leaf cases should not be needed any more only a Leaf Leaf case is needed.
-- Only defining (+) in Class Num is not a good habit
-- The below allows for CTrees to be addded together for example:
-- (mkCTree "hi) + (mkCtree "you") + (mkCTree "hi")
instance Num (CTree Char Int) where
    (+) Leaf l = l
    (+) r Leaf = r
    (+) (Node c n1 tree1) (Node _ n2 tree2) = Node c (n1+n2) (tree1+tree2)
    (+) (CTree lst1) (CTree lst2) = CTree [tr + tl | (tr,tl) <- zip lst1 lst2]

-- Filters out any words that have that have non-letters
-- Probably too strict of a filter
cfilter :: [String] -> [String]
cfilter wordlist = [word | word <- wordlist, not (any (not . isLetter) word)]

-- custum compare function works by comparing the num part in CTree elem num
compareNode :: CTree elm Int -> CTree elm Int -> Ordering
compareNode Leaf Leaf = EQ
compareNode Leaf _ = GT
compareNode _ Leaf = GT
compareNode (Node _ num _) (Node _ num2 _) = compare num2 num

-- Find most common word
mostCommon :: CTree Char Int -> String
mostCommon Leaf = ""
mostCommon (CTree lst) = c:(mostCommon cTree)
    where
        cNode = head $ sortBy compareNode lst
        c = getElem cNode
        cTree = getTree cNode

mostCommonWC Leaf = []
mostCommonWC (CTree lst) = c:(mostCommonWC cTree)
    where
        cNode = head $ sortBy compareNode lst
        c = (getElem cNode, getNum cNode)
        cTree = getTree cNode

totalCount (CTree lst) = sum $ map getNum lst

-- This is currently over kill since the list is always 26 long.
fc (CTree lst) c = [x | x <- lst, c == getElem x] 

-- Find longenst word
-- Very slow because it touches everything in the tree
flong :: CTree Char Int -> String
fLong Leaf = ""
fLong (Node c 0 tree) = ""
fLong (Node c _ tree) = c:fLong tree
fLong (CTree lst) = head $ sortBy (\a b -> compare 
                                           (length b)
                                           (length a))
                                  $ map fLong lst 

-- Where I test my functions as I program in repl
test = do
        hHuck <- openFile "huck.txt" ReadMode
        contents <- hGetContents hHuck
        hHuckTree <- openFile "huck.tree" WriteMode
        let htree = foldl (+) Leaf $ parMap rpar mkCTree
                                   $ cfilter
                                   $ words
                                   $ map toLower contents
        hPutStr hHuckTree $ show htree

test2 = do
        hHuck <- openFile "huck.txt" ReadMode
        contents <- hGetContents hHuck
        let htree = foldl (+) Leaf $ parMap rpar mkCTree
                                   $ cfilter
                                   $ words
                                   $ map toLower contents
        return htree

main = test
