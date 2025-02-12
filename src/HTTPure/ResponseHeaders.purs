module HTTPure.ResponseHeaders
  ( ResponseHeaders(..)
  , empty
  , headers
  , headers'
  , header
  , header'
  , toString
  , write
  ) where

import Prelude

import Data.Array.NonEmpty (NonEmptyArray)
import Data.Array.NonEmpty as NonEmptyArray
import Data.Foldable (foldl)
import Data.FoldableWithIndex (foldMapWithIndex)
import Data.Generic.Rep (class Generic)
import Data.Map (Map, insert, singleton, union)
import Data.Map (empty) as Map
import Data.Newtype (class Newtype, unwrap)
import Data.Show.Generic (genericShow)
import Data.String.CaseInsensitive (CaseInsensitiveString(CaseInsensitiveString))
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Tuple (Tuple(Tuple))
import Effect (Effect)
import HTTPure.Lookup (class Lookup, (!!))
import Node.HTTP (Response, setHeaders)

-- | The `ResponseHeaders` type is just sugar for a `Map` of `Strings`
-- | that represents the set of headers in an HTTP request or response.
newtype ResponseHeaders = ResponseHeaders (Map CaseInsensitiveString (NonEmptyArray String))

derive instance newtypeResponseHeaders :: Newtype ResponseHeaders _

derive instance genericResponseHeaders :: Generic ResponseHeaders _

-- | Given a string, return a `Maybe` containing the value of the matching
-- | header, if there is any.
instance lookupResponseHeaders :: Lookup ResponseHeaders String (NonEmptyArray String) where
  lookup (ResponseHeaders responseHeaders) key = responseHeaders !! key

instance showResponseHeaders :: Show ResponseHeaders where
  show = genericShow

-- | Compare two `ResponseHeaders` objects by comparing the underlying
-- | `Objects`.
derive newtype instance eqResponseHeaders :: Eq ResponseHeaders

-- | Allow one `ResponseHeaders` objects to be appended to another.
instance semigroupResponseHeaders :: Semigroup ResponseHeaders where
  append (ResponseHeaders a) (ResponseHeaders b) = ResponseHeaders $ union b a

-- | Given an HTTP `Response` and a `ResponseHeaders` object, return an
-- | effect that will write the `ResponseHeaders` to the `Response`.
write :: Response -> ResponseHeaders -> Effect Unit
write response (ResponseHeaders responseHeaders) = void $ traverseWithIndex writeField responseHeaders
  where
  writeField key = setHeaders response (unwrap key) <<< NonEmptyArray.toArray

-- | Return a `ResponseHeaders` containing nothing.
empty :: ResponseHeaders
empty = ResponseHeaders Map.empty

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `ResponseHeaders`
-- | object.
headers :: Array (Tuple String String) -> ResponseHeaders
headers = foldl insertField Map.empty >>> ResponseHeaders
  where
  insertField x (Tuple key value) = insert (CaseInsensitiveString key) (NonEmptyArray.singleton value) x

-- | Convert an `Array` of `Tuples` of `Strings` and `NonEmptyArray Strings`
-- | to a `ResponseHeaders` object.
headers' :: Array (Tuple String (NonEmptyArray String)) -> ResponseHeaders
headers' = foldl insertField Map.empty >>> ResponseHeaders
  where
  insertField x (Tuple key value) = insert (CaseInsensitiveString key) value x

-- | Create a singleton header from a key-value pair.
header :: String -> String -> ResponseHeaders
header key = NonEmptyArray.singleton >>> singleton (CaseInsensitiveString key) >>> ResponseHeaders

-- | Create a header from a key-values pair.
header' :: String -> NonEmptyArray String -> ResponseHeaders
header' key = singleton (CaseInsensitiveString key) >>> ResponseHeaders

-- | Allow a `ResponseHeaders` to be represented as a string. This string
-- | is formatted in HTTP headers format.
toString :: ResponseHeaders -> String
toString (ResponseHeaders responseHeaders) = foldMapWithIndex showField responseHeaders <> "\n"
  where
  showField key value = unwrap key <> ": " <> NonEmptyArray.intercalate "," value <> "\n"
