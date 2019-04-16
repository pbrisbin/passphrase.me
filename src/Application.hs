{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Application
    ( makeFoundation
    , waiApp
    ) where

import Data.IORef
import qualified Data.Traversable as T
import Data.Tuple
import Foundation
import Handler.About
import Handler.Root
import Random
import Settings
import WordList
import Yesod.Core

mkYesodDispatch "App" resourcesApp

makeFoundation :: AppSettings -> IO (Either String [Int]) -> IO App
makeFoundation settings refill = do
    ref <- newIORef []

    pure $ App settings $ \size -> do
        ints <- atomicModifyIORef ref $ swap . splitAt size

        if length ints >= size
            then pure $ Right ints
            else do
                result <- refill

                T.forM result $ \ints' -> do
                    let (first, rest) = splitAt size ints'
                    writeIORef ref rest
                    pure first

waiApp :: IO Application
waiApp = do
    settings <- loadAppSettings
    foundation <- makeFoundation settings $ requestInts
        (appRandomApiKey settings)
        (appRandomRequestSize settings)
        keyRange
    toWaiApp foundation
