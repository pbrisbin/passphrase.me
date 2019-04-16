{-# LANGUAGE OverloadedStrings #-}

module Random
    ( requestInts
    ) where

import Data.Aeson
import Data.Bifunctor
import Data.Text (Text)
import Network.HTTP.Conduit
import Network.HTTP.Simple

newtype Random = Random { randomData :: [Int] }

instance FromJSON Random where
    parseJSON = withObject "random" $ \o -> Random
        <$> (o .: "result" >>= (.: "random") >>= (.: "data"))

requestInts :: Text -> Int -> (Int, Int) -> IO (Either String [Int])
requestInts apiKey size (lower, upper) = do
    response <- randomRPC $ object
        ["apiKey" .= apiKey, "n" .= size, "min" .= lower, "max" .= upper]

    pure $ randomData <$> response

randomRPC :: FromJSON a => Value -> IO (Either String a)
randomRPC params = do
    request <- buildRequest <$> parseUrlThrow apiUrl
    first show . responseBody <$> httpJSONEither request
  where
    buildRequest = setRequestBodyJSON $ object
        [ "jsonrpc" .= apiVersion
        , "id" .= requestId
        , "method" .= apiMethod
        , "params" .= params
        ]

apiUrl :: String
apiUrl = "https://api.random.org/json-rpc/1/invoke"

apiVersion :: Text
apiVersion = "2.0"

apiMethod :: Text
apiMethod = "generateIntegers"

requestId :: Text
requestId = "ignored"
