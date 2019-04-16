{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Application
import Settings
import System.Random
import Test.Hspec
import Test.Hspec.Wai
import WordList
import Yesod.Core

main :: IO ()
main = hspec spec

spec :: Spec
spec = withApp $ do
    describe "getting passphrases" $ do
        it "returns random passphrases" $ do
            get "/" `shouldRespondWith` "balk il climb stu\n"
            get "/" `shouldRespondWith` "mask doria one spin\n"
            get "/" `shouldRespondWith` "lobo hertz minor e'er\n"
            get "/" `shouldRespondWith` "bulge franz sturm qr\n"

        it "accepts a size parameter" $ do
            get "/?size=3" `shouldRespondWith` "balk il climb\n"

withApp :: SpecWith Application -> Spec
withApp = before $ do
    setStdGen $ mkStdGen 1

    Right wordlist <- readWordList "wordlist"

    let
        settings = AppSettings
            { appDefaultSize = 4
            , appRandomApiKey = ""
            , appRandomRequestSize = 20
            , appWordList = wordlist
            }

    foundation <- makeFoundation settings $ do
        ints <- randomRs keyRange <$> newStdGen

        pure $ Right $ take (appRandomRequestSize settings) ints

    toWaiAppPlain foundation
