{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Foundation where

import Settings

import Yesod.Core
import Yesod.Form

data App = App
    { appSettings :: AppSettings
    , appGetRandomInts :: Int -> IO (Either String [Int])
    }

mkYesodData "App" [parseRoutes|
    / RootR GET
    /about AboutR GET
|]

instance Yesod App

-- Required for intField (error messages)
instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage
