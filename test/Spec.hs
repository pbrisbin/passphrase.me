{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module Main where

import Application
import WordList

import Test.Hspec
import Test.Hspec.Wai

import System.Random
import Yesod.Core

main :: IO ()
main = hspec spec

spec :: Spec
spec = withApp $ do
    describe "getting passphrases" $ do
        it "returns random passphrases" $ do
            get "/" `shouldRespondWith` "meter space siva saxon\n"
            get "/" `shouldRespondWith` "dingy mg grass bake\n"
            get "/" `shouldRespondWith` "conway owens stead hydro\n"
            get "/" `shouldRespondWith` "glide break faro shear\n"

        it "accepts a size parameter" $ do
            get "/?size=3" `shouldRespondWith` "meter space siva\n"

withApp :: SpecWith Application -> Spec
withApp = before $ do
    setStdGen $ mkStdGen 1

    let appDefaultSize = 4
        appRandomInts size =
            take (size * snd keyRange) . randomRs keyRange <$> newStdGen

    -- toWaiAppPlain avoids logging middleware for quieter specs
    toWaiAppPlain $ App{..}
