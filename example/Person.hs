{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE DerivingStrategies    #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE OverloadedLabels      #-}
{-# LANGUAGE OverloadedLists       #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE StandaloneDeriving    #-}
module Person where

import           Data.Generics.Labels  ()
import           GHC.Generics
import qualified Generics.SOP as SOP
import           Schemas
import           Schemas.SOP

data Education = NoEducation | Degree {unDegree :: String} | PhD {unPhD :: String}
  deriving (Generic, Eq, Show)

instance HasSchema Education where
  schema = union'
    [alt "NoEducation" #_NoEducation
    ,alt "PhD" #_PhD
    ,alt "Degree" #_Degree
    ]

data Person = Person
  { name      :: String
  , age       :: Int
  , addresses :: [String]
  , studies   :: Education
  }
  deriving (Generic, Eq, Show)
  deriving anyclass (SOP.Generic, SOP.HasDatatypeInfo)

instance HasSchema Person where
  schema = gSchema defOptions

pepe :: Person
pepe = Person
  "Pepe"
  38
  ["2 Edward Square", "La Mar 10"]
  (PhD "Computer Science")

-- >>> import Data.Aeson.Encode.Pretty
-- >>> import qualified Data.ByteString.Lazy.Char8 as B
-- >>> B.putStrLn $ encodePretty $ encode pepe
-- {
--     "addresses": [
--         "2 Edward Square",
--         "La Mar 10"
--     ],
--     "age": 38,
--     "studies": {
--         "PhD": "Computer Science"
--     },
--     "name": "Pepe"
-- }

-- >>> B.putStrLn $ encodePretty $ encode (theSchema @Person)
-- {
--     "Record": {
--         "addresses": {
--             "schema": {
--                 "Array": {
--                     "Prim": "String"
--                 }
--             }
--         },
--         "age": {
--             "schema": {
--                 "Prim": "Int"
--             }
--         },
--         "studies": {
--             "schema": {
--                 "Union": [
--                     {
--                         "schema": {
--                             "Empty": {}
--                         },
--                         "constructor": "NoEducation"
--                     },
--                     {
--                         "schema": {
--                             "Prim": "String"
--                         },
--                         "constructor": "PhD"
--                     },
--                     {
--                         "schema": {
--                             "Prim": "String"
--                         },
--                         "constructor": "Degree"
--                     }
--                 ]
--             }
--         },
--         "name": {
--             "schema": {
--                 "Prim": "String"
--             }
--         }
--     }
-- }

-- >>> import Text.Pretty.Simple
-- >>> pPrintNoColor $ decode @Person $ encode pepe
-- Right
--     ( Person
--         { name = "Pepe"
--         , age = 38
--         , addresses =
--             [ "2 Edward Square"
--             , "La Mar 10"
--             ]
--         , studies =
--             ( PhD { unPhD = "Computer Science" } )
--         }
--     )
