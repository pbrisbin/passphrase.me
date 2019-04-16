{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Handler.Root
    ( getRootR
    )
where

import Control.Monad.Logger
import Data.Maybe (fromMaybe)
import Data.Monoid ((<>))
import Data.Text (Text)
import qualified Data.Text as T
import Foundation
import Network.HTTP.Types (status200, status500)
import Settings
import WordList
import Yesod.Core
import Yesod.Form

getRootR :: Handler Text
getRootR = do
    App {..} <- getYesod

    let choose k = getWord k $ appWordList appSettings
        passphrase ints = T.unwords (map choose $ fromStream ints) <> "\n"

    size <- getField intField "size" $ appDefaultSize appSettings
    result <- liftIO $ appGetRandomInts $ size * keyLength

    case result of
        Left err -> do
            logErrorN $ T.pack err
            sendResponseStatus status500 err
        Right ints -> do
            logDebugN $ "result=" <> T.pack (show ints)
            sendResponseStatus status200 $ passphrase ints

getField :: MonadHandler m => Field m a -> Text -> a -> m a
getField field name value = fromMaybe value <$> runInputGet (iopt field name)
