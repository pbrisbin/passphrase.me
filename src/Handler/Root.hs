{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
module Handler.Root where

import Foundation
import Settings

import WordList

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>))
import Data.Text (Text)
import Network.HTTP.Types (status200, status500)
import Yesod.Core
import Yesod.Form

import qualified Data.Text as T

getRootR :: Handler Text
getRootR = do
    App{..} <- getYesod

    size <- getField intField "size" $ appDefaultSize appSettings
    result <- liftIO $ appGetRandomInts $ size * keyLength

    logResult result

    let choose k = getWord k $ appWordList appSettings
        passphrase ints = T.unwords (map choose $ fromStream ints) <> "\n"

    either
        (sendResponseStatus status500)
        (sendResponseStatus status200 . passphrase)
        result

  where
    getField field name value =
        fromMaybe value <$> runInputGet (iopt field name)

logResult :: Either Text a -> Handler ()
logResult (Right _) = return ()
logResult (Left err) = $(logError) err
