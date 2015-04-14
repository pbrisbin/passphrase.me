{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module Random
    ( requestInts
    ) where

import Data.Aeson
import Data.Text (Text)
import Network.Connection (TLSSettings(..))
import Network.HTTP.Conduit

newtype RPCRandom = RPCRandom [Int]

instance FromJSON RPCRandom where
    parseJSON = withObject "random" $ \o -> RPCRandom
        <$> (o .: "result" >>= (.: "random") >>= (.: "data"))

requestInts :: Text -> Int -> Int -> Int -> IO [Int]
requestInts apiKey size lower upper = do
    response <- randomRPC $ object
        [ "jsonrpc" .= apiVersion
        , "id" .= requestId
        , "method" .= apiMethod
        , "params" .= object
            [ "apiKey" .= apiKey
            , "n" .= size
            , "min" .= lower
            , "max" .= upper
            ]
        ]

    case response of
        Left err -> error $ "could not parse API response " ++ err
        Right (RPCRandom ints) -> return ints

randomRPC :: FromJSON a => Value -> IO (Either String a)
randomRPC reqObject = do
    request <- parseUrl apiUrl

    eitherDecode . responseBody <$> withManagerSettings settings
        (httpLbs request { requestBody = RequestBodyLBS $ encode reqObject })

  where
    settings = mkManagerSettings
        -- TODO: www.random.org's cert has no Common Name, I can do nothing
        -- except be insecure and disable verification.
        (TLSSettingsSimple True False False) Nothing

apiUrl :: String
apiUrl = "https://api.random.org/json-rpc/1/invoke"

apiVersion :: Text
apiVersion = "2.0"

apiMethod :: Text
apiMethod = "generateIntegers"

requestId :: Text
requestId = "ignored"
