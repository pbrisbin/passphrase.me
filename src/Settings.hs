{-# LANGUAGE RecordWildCards #-}
module Settings
    ( AppSettings(..)
    , loadAppSettings
    ) where

import WordList

import Data.Text (Text)
import LoadEnv
import System.Environment

import qualified Data.Text as T

data AppSettings = AppSettings
    { appDefaultSize :: Int
    , appRandomApiKey :: Text
    , appRandomRequestSize :: Int
    , appWordList :: WordList
    }

loadAppSettings :: IO AppSettings
loadAppSettings = do
    loadEnv

    appDefaultSize <- read <$> getEnv "PASSPHRASE_SIZE"
    appRandomApiKey <- T.pack <$> getEnv "RANDOM_API_KEY"
    appRandomRequestSize <- read <$> getEnv "RANDOM_REQUEST_SIZE"

    fp <- getEnv "WORDLIST_FILE"
    appWordList <- either (error . show) id <$> readWordList fp

    return AppSettings{..}
