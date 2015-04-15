{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module Main where

import Application
import Settings

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
            get "/" `shouldRespondWith` "yarn sib 300 model\n"
            get "/" `shouldRespondWith` "lossy flour piotr caruso\n"
            get "/" `shouldRespondWith` "hark sp quay hook\n"
            get "/" `shouldRespondWith` "slant walk pogo twin\n"

        it "accepts a size parameter" $ do
            get "/?size=3" `shouldRespondWith` "yarn sib 300\n"

withApp :: SpecWith Application -> Spec
withApp = before $ do
    setStdGen $ mkStdGen 1

    Right wordlist <- readWordList "wordlist"

    let settings = AppSettings
            { appDefaultSize = 4
            , appRandomApiKey = ""
            , appRandomRequestSize = 20
            , appWordList = wordlist
            }

    foundation <- makeFoundation settings $ do
        ints <- randomRs keyRange <$> newStdGen

        return $ Right $ take (appRandomRequestSize settings) ints

    toWaiAppPlain foundation
