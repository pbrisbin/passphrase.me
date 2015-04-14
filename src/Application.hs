{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Application
    ( makeFoundation
    , waiApp
    ) where

import Foundation
import Settings
import Handler.Root
import Handler.About

import Random
import WordList

import Data.IORef
import Data.Text (Text)
import Data.Tuple
import Yesod.Core

import qualified Data.Traversable as T

mkYesodDispatch "App" resourcesApp

makeFoundation :: AppSettings -> IO (Either Text [Int]) -> IO App
makeFoundation settings refill = do
    ref <- newIORef []

    return $ App settings $ \size -> do
        ints <- atomicModifyIORef ref $ swap . splitAt size

        if length ints >= size
            then return $ Right ints
            else do
                result <- refill

                T.forM result $ \ints' -> do
                    let (first, rest) = splitAt size ints'
                    writeIORef ref rest
                    return first

waiApp :: IO Application
waiApp = do
    settings <- loadAppSettings
    foundation <- makeFoundation settings $
        requestInts
            (appRandomApiKey settings)
            (appRandomRequestSize settings)
            keyRange

    toWaiApp $ foundation
