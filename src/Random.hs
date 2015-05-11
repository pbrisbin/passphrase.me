{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module Random
    ( requestInts
    ) where

import Data.Aeson
import Data.Aeson.Encode.Pretty
import Data.Bifunctor
import Data.ByteString.Lazy (ByteString)
import Data.Text (Text)
import Network.HTTP.Conduit

import qualified Data.Text as T
import qualified Data.ByteString.Lazy.Char8 as BL

newtype Random = Random { randomData :: [Int] }

instance FromJSON Random where
    parseJSON = withObject "random" $ \o -> Random
        <$> (o .: "result" >>= (.: "random") >>= (.: "data"))

requestInts :: Text -> Int -> (Int, Int) -> IO (Either Text [Int])
requestInts apiKey size (lower, upper) = do
    response <- randomRPC $ object
        [ "apiKey" .= apiKey
        , "n" .= size
        , "min" .= lower
        , "max" .= upper
        ]

    return $ randomData <$> response

randomRPC :: FromJSON a => Value -> IO (Either Text a)
randomRPC params = do
    request <- parseUrl apiUrl
    response <- withManager $ httpLbs request
        { requestBody = RequestBodyLBS $ encode $ object
            [ "jsonrpc" .= apiVersion
            , "id" .= requestId
            , "method" .= apiMethod
            , "params" .= params
            ]
        }

    return $ first (formatError response) $
        eitherDecode $ responseBody response

  where
    formatError :: Response ByteString -> String -> Text
    formatError resp err = T.pack $ unlines
        [ "Unable to access random.org"
        , "Status: " ++ show (responseStatus resp)
        , "Response: "
        , "---"
        , BL.unpack $ formatBody $ responseBody resp
        , "---"
        , "Error: " ++ err
        ]

    formatBody :: ByteString -> ByteString
    formatBody bs = maybe bs encodePretty (decode bs :: Maybe Value)

apiUrl :: String
apiUrl = "https://api.random.org/json-rpc/1/invoke"

apiVersion :: Text
apiVersion = "2.0"

apiMethod :: Text
apiMethod = "generateIntegers"

requestId :: Text
requestId = "ignored"
