{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
module Foundation where

import Settings

import Data.Text (Text)
import Yesod.Core
import Yesod.Form

data App = App
    { appSettings :: AppSettings
    , appGetRandomInts :: Int -> IO (Either Text [Int])
    }

mkYesodData "App" [parseRoutes|
    / RootR GET
|]

instance Yesod App

-- Required for intField (error messages)
instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage
