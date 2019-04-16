{-# LANGUAGE OverloadedStrings #-}

module WordList
    ( Key
    , WordList
    , getWord
    , keyRange
    , keyLength
    , fromList
    , fromStream
    , readWordList
    ) where

import Control.Monad (replicateM)
import Data.Bifunctor
import Data.Char (digitToInt)
import Data.Ix
import Data.Maybe (fromJust)
import Data.Text (Text)
import Text.Parsec
import Text.Parsec.Text

import qualified Data.Map as M
import qualified Data.Text as T
import qualified Data.Text.IO as T

newtype Key = Key Int deriving (Eq, Ord, Show)
newtype WordList = WordList (M.Map Key Text) deriving Show

getWord :: Key -> WordList -> Text
getWord k (WordList wl) = fromJust $ M.lookup k wl

--------------------------------------------------------------------------------
-- Building Keys
--------------------------------------------------------------------------------
keyRange :: (Int, Int)
keyRange = (1, 6)

keyLength :: Int
keyLength = 5

fromList :: [Int] -> Maybe Key
fromList ints
    | length ints /= keyLength = Nothing
    | not $ all (inRange keyRange) ints = Nothing
    | otherwise = Just $ Key $ read $ concatMap show ints

fromStream :: [Int] -> [Key]
fromStream [] = []
fromStream ints = consKey $ fromStream rest
  where
    consKey = maybe id (:) $ fromList batch

    (batch, rest) = splitAt keyLength $ filter (inRange keyRange) ints

--------------------------------------------------------------------------------
-- Reading a WordList from disk
--------------------------------------------------------------------------------
readWordList :: FilePath -> IO (Either String WordList)
readWordList fp = first show . parse parseWordList fp <$> T.readFile fp

parseWordList :: Parser WordList
parseWordList = WordList . M.fromList <$> many1 parseWord

parseWord :: Parser (Key, Text)
parseWord = do
    k <- parseKey
    _ <- tab
    v <- parseValue

    pure (k, v)

parseKey :: Parser Key
parseKey = do
    ints <- map digitToInt <$> replicateM 5 digit
    maybe (fail $ "invalid key " ++ show ints) pure $ fromList ints

parseValue :: Parser Text
parseValue = T.pack <$> manyTill anyToken newline
