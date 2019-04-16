module Main where

import Application (waiApp)
import Network.Wai.Handler.Warp (runEnv)

main :: IO ()
main = runEnv 3000 =<< waiApp
