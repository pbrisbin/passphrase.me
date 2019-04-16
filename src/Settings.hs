{-# LANGUAGE RecordWildCards #-}

module Settings
    ( AppSettings(..)
    , loadAppSettings
    ) where

import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import LoadEnv
import System.Environment
import WordList

data AppSettings = AppSettings
    { appDefaultSize :: Int
    , appRandomApiKey :: Text
    , appRandomRequestSize :: Int
    , appWordList :: WordList
    }

loadAppSettings :: IO AppSettings
loadAppSettings = do
    loadEnv

    -- Required
    appRandomApiKey <- T.pack <$> getEnv "RANDOM_API_KEY"

    -- Optional
    appDefaultSize <- read <$> getEnvDefault "4" "PASSPHRASE_SIZE"
    appRandomRequestSize <- read <$> getEnvDefault "1000" "RANDOM_REQUEST_SIZE"
    fp <- getEnvDefault "wordlist" "WORDLIST_FILE"
    appWordList <- either (error . show) id <$> readWordList fp

    pure AppSettings {..}

getEnvDefault :: String -> String -> IO String
getEnvDefault x k = fromMaybe x <$> lookupEnv k
