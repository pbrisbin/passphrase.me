{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
module Application
    ( App(..)
    , waiApp

    -- Exported to silence unused warnings
    , Widget
    , resourcesApp
    ) where

import Random
import WordList

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>))
import Data.Text (Text)
import LoadEnv
import System.Environment
import Yesod.Core
import Yesod.Form

import qualified Data.Text as T

data App = App
    { appDefaultSize :: Int
    , appRandomInts :: (Int -> IO [Int])
    }

mkYesod "App" [parseRoutes|
    / RootR GET
|]

instance Yesod App

-- Required for intField (error messages)
instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage

getRootR :: Handler Text
getRootR = do
    App{..} <- getYesod

    ints <- liftIO . appRandomInts
        =<< getField intField "size" appDefaultSize

    return $ buildPassphrase ints <> "\n"

  where
    getField field name value =
        fromMaybe value <$> runInputGet (iopt field name)

buildPassphrase :: [Int] -> Text
buildPassphrase = T.unwords . map getWord . fromStream

waiApp :: IO Application
waiApp = do
    loadEnv

    apiKey <- T.pack <$> getEnv "RANDOM_API_KEY"
    appDefaultSize <- read <$> getEnv "PASSPHRASE_SIZE"

    let appRandomInts size =
            -- Request integers from random.org
            requestInts apiKey (size * upper) lower upper

    toWaiApp $ App{..}

  where
    (lower, upper) = keyRange
