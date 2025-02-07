module HTTPure.Response
  ( Response
  , ResponseM
  , send
  , response
  , response'
  , emptyResponse
  , emptyResponse'
  -- 1xx
  , continue
  , continue'
  , switchingProtocols
  , switchingProtocols'
  , processing
  , processing'
  -- 2xx
  , ok
  , ok'
  , created
  , created'
  , accepted
  , accepted'
  , nonAuthoritativeInformation
  , nonAuthoritativeInformation'
  , noContent
  , noContent'
  , resetContent
  , resetContent'
  , partialContent
  , partialContent'
  , multiStatus
  , multiStatus'
  , alreadyReported
  , alreadyReported'
  , iMUsed
  , iMUsed'
  -- 3xx
  , multipleChoices
  , multipleChoices'
  , movedPermanently
  , movedPermanently'
  , found
  , found'
  , seeOther
  , seeOther'
  , notModified
  , notModified'
  , useProxy
  , useProxy'
  , temporaryRedirect
  , temporaryRedirect'
  , permanentRedirect
  , permanentRedirect'
  -- 4xx
  , badRequest
  , badRequest'
  , unauthorized
  , unauthorized'
  , paymentRequired
  , paymentRequired'
  , forbidden
  , forbidden'
  , notFound
  , notFound'
  , methodNotAllowed
  , methodNotAllowed'
  , notAcceptable
  , notAcceptable'
  , proxyAuthenticationRequired
  , proxyAuthenticationRequired'
  , requestTimeout
  , requestTimeout'
  , conflict
  , conflict'
  , gone
  , gone'
  , lengthRequired
  , lengthRequired'
  , preconditionFailed
  , preconditionFailed'
  , payloadTooLarge
  , payloadTooLarge'
  , uRITooLong
  , uRITooLong'
  , unsupportedMediaType
  , unsupportedMediaType'
  , rangeNotSatisfiable
  , rangeNotSatisfiable'
  , expectationFailed
  , expectationFailed'
  , imATeapot
  , imATeapot'
  , misdirectedRequest
  , misdirectedRequest'
  , unprocessableEntity
  , unprocessableEntity'
  , locked
  , locked'
  , failedDependency
  , failedDependency'
  , upgradeRequired
  , upgradeRequired'
  , preconditionRequired
  , preconditionRequired'
  , tooManyRequests
  , tooManyRequests'
  , requestHeaderFieldsTooLarge
  , requestHeaderFieldsTooLarge'
  , unavailableForLegalReasons
  , unavailableForLegalReasons'
  -- 5xx
  , internalServerError
  , internalServerError'
  , notImplemented
  , notImplemented'
  , badGateway
  , badGateway'
  , serviceUnavailable
  , serviceUnavailable'
  , gatewayTimeout
  , gatewayTimeout'
  , hTTPVersionNotSupported
  , hTTPVersionNotSupported'
  , variantAlsoNegotiates
  , variantAlsoNegotiates'
  , insufficientStorage
  , insufficientStorage'
  , loopDetected
  , loopDetected'
  , notExtended
  , notExtended'
  , networkAuthenticationRequired
  , networkAuthenticationRequired'
  ) where

import Prelude

import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import HTTPure.Body (class Body, defaultHeaders, write)
import HTTPure.ResponseHeaders (ResponseHeaders, empty)
import HTTPure.ResponseHeaders (write) as ResponseHeaders
import HTTPure.Status (Status)
import HTTPure.Status
  ( accepted
  , alreadyReported
  , badGateway
  , badRequest
  , conflict
  , continue
  , created
  , expectationFailed
  , failedDependency
  , forbidden
  , found
  , gatewayTimeout
  , gone
  , hTTPVersionNotSupported
  , iMUsed
  , imATeapot
  , insufficientStorage
  , internalServerError
  , lengthRequired
  , locked
  , loopDetected
  , methodNotAllowed
  , misdirectedRequest
  , movedPermanently
  , multiStatus
  , multipleChoices
  , networkAuthenticationRequired
  , noContent
  , nonAuthoritativeInformation
  , notAcceptable
  , notExtended
  , notFound
  , notImplemented
  , notModified
  , ok
  , partialContent
  , payloadTooLarge
  , paymentRequired
  , permanentRedirect
  , preconditionFailed
  , preconditionRequired
  , processing
  , proxyAuthenticationRequired
  , rangeNotSatisfiable
  , requestHeaderFieldsTooLarge
  , requestTimeout
  , resetContent
  , seeOther
  , serviceUnavailable
  , switchingProtocols
  , temporaryRedirect
  , tooManyRequests
  , uRITooLong
  , unauthorized
  , unavailableForLegalReasons
  , unprocessableEntity
  , unsupportedMediaType
  , upgradeRequired
  , useProxy
  , variantAlsoNegotiates
  , write
  ) as Status
import Node.HTTP (Response) as HTTP

-- | The `ResponseM` type simply conveniently wraps up an HTTPure monad that
-- | returns a response. This type is the return type of all router/route
-- | methods.
type ResponseM = Aff Response

-- | A `Response` is a status code, headers, and a body.
type Response =
  { status :: Status
  , headers :: ResponseHeaders
  , writeBody :: HTTP.Response -> Aff Unit
  }

-- | Given an HTTP `Response` and a HTTPure `Response`, this method will return
-- | a monad encapsulating writing the HTTPure `Response` to the HTTP `Response`
-- | and closing the HTTP `Response`.
send :: forall m. MonadEffect m => MonadAff m => HTTP.Response -> Response -> m Unit
send httpresponse { status, headers, writeBody } = do
  liftEffect $ Status.write httpresponse status
  liftEffect $ ResponseHeaders.write httpresponse headers
  liftAff $ writeBody httpresponse

-- | For custom response statuses or providing a body for response codes that
-- | don't typically send one.
response :: forall m b. MonadAff m => Body b => Status -> b -> m Response
response status = response' status empty

-- | The same as `response` but with headers.
response' ::
  forall m b.
  MonadAff m =>
  Body b =>
  Status ->
  ResponseHeaders ->
  b ->
  m Response
response' status headers body = liftEffect do
  defaultHeaders' <- defaultHeaders body
  pure
    { status
    , headers: defaultHeaders' <> headers
    , writeBody: write body
    }

-- | The same as `response` but without a body.
emptyResponse :: forall m. MonadAff m => Status -> m Response
emptyResponse status = emptyResponse' status empty

-- | The same as `emptyResponse` but with headers.
emptyResponse' :: forall m. MonadAff m => Status -> ResponseHeaders -> m Response
emptyResponse' status headers = response' status headers ""

---------
-- 1xx --
---------
-- | 100
continue :: forall m. MonadAff m => m Response
continue = continue' empty

-- | 100 with headers
continue' :: forall m. MonadAff m => ResponseHeaders -> m Response
continue' = emptyResponse' Status.continue

-- | 101
switchingProtocols :: forall m. MonadAff m => m Response
switchingProtocols = switchingProtocols' empty

-- | 101 with headers
switchingProtocols' :: forall m. MonadAff m => ResponseHeaders -> m Response
switchingProtocols' = emptyResponse' Status.switchingProtocols

-- | 102
processing :: forall m. MonadAff m => m Response
processing = processing' empty

-- | 102 with headers
processing' :: forall m. MonadAff m => ResponseHeaders -> m Response
processing' = emptyResponse' Status.processing

---------
-- 2xx --
---------
-- | 200
ok :: forall m b. MonadAff m => Body b => b -> m Response
ok = ok' empty

-- | 200 with headers
ok' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
ok' = response' Status.ok

-- | 201
created :: forall m. MonadAff m => m Response
created = created' empty

-- | 201 with headers
created' :: forall m. MonadAff m => ResponseHeaders -> m Response
created' = emptyResponse' Status.created

-- | 202
accepted :: forall m. MonadAff m => m Response
accepted = accepted' empty

-- | 202 with headers
accepted' :: forall m. MonadAff m => ResponseHeaders -> m Response
accepted' = emptyResponse' Status.accepted

-- | 203
nonAuthoritativeInformation :: forall m b. MonadAff m => Body b => b -> m Response
nonAuthoritativeInformation = nonAuthoritativeInformation' empty

-- | 203 with headers
nonAuthoritativeInformation' ::
  forall m b.
  MonadAff m =>
  Body b =>
  ResponseHeaders ->
  b ->
  m Response
nonAuthoritativeInformation' = response' Status.nonAuthoritativeInformation

-- | 204
noContent :: forall m. MonadAff m => m Response
noContent = noContent' empty

-- | 204 with headers
noContent' :: forall m. MonadAff m => ResponseHeaders -> m Response
noContent' = emptyResponse' Status.noContent

-- | 205
resetContent :: forall m. MonadAff m => m Response
resetContent = resetContent' empty

-- | 205 with headers
resetContent' :: forall m. MonadAff m => ResponseHeaders -> m Response
resetContent' = emptyResponse' Status.resetContent

-- | 206
partialContent :: forall m b. MonadAff m => Body b => b -> m Response
partialContent = partialContent' empty

-- | 206 with headers
partialContent' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
partialContent' = response' Status.partialContent

-- | 207
multiStatus :: forall m b. MonadAff m => Body b => b -> m Response
multiStatus = multiStatus' empty

-- | 207 with headers
multiStatus' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
multiStatus' = response' Status.multiStatus

-- | 208
alreadyReported :: forall m. MonadAff m => m Response
alreadyReported = alreadyReported' empty

-- | 208 with headers
alreadyReported' :: forall m. MonadAff m => ResponseHeaders -> m Response
alreadyReported' = emptyResponse' Status.alreadyReported

-- | 226
iMUsed :: forall m b. MonadAff m => Body b => b -> m Response
iMUsed = iMUsed' empty

-- | 226 with headers
iMUsed' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
iMUsed' = response' Status.iMUsed

---------
-- 3xx --
---------
-- | 300
multipleChoices :: forall m b. MonadAff m => Body b => b -> m Response
multipleChoices = multipleChoices' empty

-- | 300 with headers
multipleChoices' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
multipleChoices' = response' Status.multipleChoices

-- | 301
movedPermanently :: forall m b. MonadAff m => Body b => b -> m Response
movedPermanently = movedPermanently' empty

-- | 301 with headers
movedPermanently' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
movedPermanently' = response' Status.movedPermanently

-- | 302
found :: forall m b. MonadAff m => Body b => b -> m Response
found = found' empty

-- | 302 with headers
found' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
found' = response' Status.found

-- | 303
seeOther :: forall m b. MonadAff m => Body b => b -> m Response
seeOther = seeOther' empty

-- | 303 with headers
seeOther' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
seeOther' = response' Status.seeOther

-- | 304
notModified :: forall m. MonadAff m => m Response
notModified = notModified' empty

-- | 304 with headers
notModified' :: forall m. MonadAff m => ResponseHeaders -> m Response
notModified' = emptyResponse' Status.notModified

-- | 305
useProxy :: forall m b. MonadAff m => Body b => b -> m Response
useProxy = useProxy' empty

-- | 305 with headers
useProxy' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
useProxy' = response' Status.useProxy

-- | 307
temporaryRedirect :: forall m b. MonadAff m => Body b => b -> m Response
temporaryRedirect = temporaryRedirect' empty

-- | 307 with headers
temporaryRedirect' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
temporaryRedirect' = response' Status.temporaryRedirect

-- | 308
permanentRedirect :: forall m b. MonadAff m => Body b => b -> m Response
permanentRedirect = permanentRedirect' empty

-- | 308 with headers
permanentRedirect' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
permanentRedirect' = response' Status.permanentRedirect

---------
-- 4xx --
---------
-- | 400
badRequest :: forall m b. MonadAff m => Body b => b -> m Response
badRequest = badRequest' empty

-- | 400 with headers
badRequest' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
badRequest' = response' Status.badRequest

-- | 401
unauthorized :: forall m. MonadAff m => m Response
unauthorized = unauthorized' empty

-- | 401 with headers
unauthorized' :: forall m. MonadAff m => ResponseHeaders -> m Response
unauthorized' = emptyResponse' Status.unauthorized

-- | 402
paymentRequired :: forall m. MonadAff m => m Response
paymentRequired = paymentRequired' empty

-- | 402 with headers
paymentRequired' :: forall m. MonadAff m => ResponseHeaders -> m Response
paymentRequired' = emptyResponse' Status.paymentRequired

-- | 403
forbidden :: forall m. MonadAff m => m Response
forbidden = forbidden' empty

-- | 403 with headers
forbidden' :: forall m. MonadAff m => ResponseHeaders -> m Response
forbidden' = emptyResponse' Status.forbidden

-- | 404
notFound :: forall m. MonadAff m => m Response
notFound = notFound' empty

-- | 404 with headers
notFound' :: forall m. MonadAff m => ResponseHeaders -> m Response
notFound' = emptyResponse' Status.notFound

-- | 405
methodNotAllowed :: forall m. MonadAff m => m Response
methodNotAllowed = methodNotAllowed' empty

-- | 405 with headers
methodNotAllowed' :: forall m. MonadAff m => ResponseHeaders -> m Response
methodNotAllowed' = emptyResponse' Status.methodNotAllowed

-- | 406
notAcceptable :: forall m. MonadAff m => m Response
notAcceptable = notAcceptable' empty

-- | 406 with headers
notAcceptable' :: forall m. MonadAff m => ResponseHeaders -> m Response
notAcceptable' = emptyResponse' Status.notAcceptable

-- | 407
proxyAuthenticationRequired :: forall m. MonadAff m => m Response
proxyAuthenticationRequired = proxyAuthenticationRequired' empty

-- | 407 with headers
proxyAuthenticationRequired' :: forall m. MonadAff m => ResponseHeaders -> m Response
proxyAuthenticationRequired' = emptyResponse' Status.proxyAuthenticationRequired

-- | 408
requestTimeout :: forall m. MonadAff m => m Response
requestTimeout = requestTimeout' empty

-- | 408 with headers
requestTimeout' :: forall m. MonadAff m => ResponseHeaders -> m Response
requestTimeout' = emptyResponse' Status.requestTimeout

-- | 409
conflict :: forall m b. MonadAff m => Body b => b -> m Response
conflict = conflict' empty

-- | 409 with headers
conflict' :: forall m b. MonadAff m => Body b => ResponseHeaders -> b -> m Response
conflict' = response' Status.conflict

-- | 410
gone :: forall m. MonadAff m => m Response
gone = gone' empty

-- | 410 with headers
gone' :: forall m. MonadAff m => ResponseHeaders -> m Response
gone' = emptyResponse' Status.gone

-- | 411
lengthRequired :: forall m. MonadAff m => m Response
lengthRequired = lengthRequired' empty

-- | 411 with headers
lengthRequired' :: forall m. MonadAff m => ResponseHeaders -> m Response
lengthRequired' = emptyResponse' Status.lengthRequired

-- | 412
preconditionFailed :: forall m. MonadAff m => m Response
preconditionFailed = preconditionFailed' empty

-- | 412 with headers
preconditionFailed' :: forall m. MonadAff m => ResponseHeaders -> m Response
preconditionFailed' = emptyResponse' Status.preconditionFailed

-- | 413
payloadTooLarge :: forall m. MonadAff m => m Response
payloadTooLarge = payloadTooLarge' empty

-- | 413 with headers
payloadTooLarge' :: forall m. MonadAff m => ResponseHeaders -> m Response
payloadTooLarge' = emptyResponse' Status.payloadTooLarge

-- | 414
uRITooLong :: forall m. MonadAff m => m Response
uRITooLong = uRITooLong' empty

-- | 414 with headers
uRITooLong' :: forall m. MonadAff m => ResponseHeaders -> m Response
uRITooLong' = emptyResponse' Status.uRITooLong

-- | 415
unsupportedMediaType :: forall m. MonadAff m => m Response
unsupportedMediaType = unsupportedMediaType' empty

-- | 415 with headers
unsupportedMediaType' :: forall m. MonadAff m => ResponseHeaders -> m Response
unsupportedMediaType' = emptyResponse' Status.unsupportedMediaType

-- | 416
rangeNotSatisfiable :: forall m. MonadAff m => m Response
rangeNotSatisfiable = rangeNotSatisfiable' empty

-- | 416 with headers
rangeNotSatisfiable' :: forall m. MonadAff m => ResponseHeaders -> m Response
rangeNotSatisfiable' = emptyResponse' Status.rangeNotSatisfiable

-- | 417
expectationFailed :: forall m. MonadAff m => m Response
expectationFailed = expectationFailed' empty

-- | 417 with headers
expectationFailed' :: forall m. MonadAff m => ResponseHeaders -> m Response
expectationFailed' = emptyResponse' Status.expectationFailed

-- | 418
imATeapot :: forall m. MonadAff m => m Response
imATeapot = imATeapot' empty

-- | 418 with headers
imATeapot' :: forall m. MonadAff m => ResponseHeaders -> m Response
imATeapot' = emptyResponse' Status.imATeapot

-- | 421
misdirectedRequest :: forall m. MonadAff m => m Response
misdirectedRequest = misdirectedRequest' empty

-- | 421 with headers
misdirectedRequest' :: forall m. MonadAff m => ResponseHeaders -> m Response
misdirectedRequest' = emptyResponse' Status.misdirectedRequest

-- | 422
unprocessableEntity :: forall m. MonadAff m => m Response
unprocessableEntity = unprocessableEntity' empty

-- | 422 with headers
unprocessableEntity' :: forall m. MonadAff m => ResponseHeaders -> m Response
unprocessableEntity' = emptyResponse' Status.unprocessableEntity

-- | 423
locked :: forall m. MonadAff m => m Response
locked = locked' empty

-- | 423 with headers
locked' :: forall m. MonadAff m => ResponseHeaders -> m Response
locked' = emptyResponse' Status.locked

-- | 424
failedDependency :: forall m. MonadAff m => m Response
failedDependency = failedDependency' empty

-- | 424 with headers
failedDependency' :: forall m. MonadAff m => ResponseHeaders -> m Response
failedDependency' = emptyResponse' Status.failedDependency

-- | 426
upgradeRequired :: forall m. MonadAff m => m Response
upgradeRequired = upgradeRequired' empty

-- | 426 with headers
upgradeRequired' :: forall m. MonadAff m => ResponseHeaders -> m Response
upgradeRequired' = emptyResponse' Status.upgradeRequired

-- | 428
preconditionRequired :: forall m. MonadAff m => m Response
preconditionRequired = preconditionRequired' empty

-- | 428 with headers
preconditionRequired' :: forall m. MonadAff m => ResponseHeaders -> m Response
preconditionRequired' = emptyResponse' Status.preconditionRequired

-- | 429
tooManyRequests :: forall m. MonadAff m => m Response
tooManyRequests = tooManyRequests' empty

-- | 429 with headers
tooManyRequests' :: forall m. MonadAff m => ResponseHeaders -> m Response
tooManyRequests' = emptyResponse' Status.tooManyRequests

-- | 431
requestHeaderFieldsTooLarge :: forall m. MonadAff m => m Response
requestHeaderFieldsTooLarge = requestHeaderFieldsTooLarge' empty

-- | 431 with headers
requestHeaderFieldsTooLarge' :: forall m. MonadAff m => ResponseHeaders -> m Response
requestHeaderFieldsTooLarge' = emptyResponse' Status.requestHeaderFieldsTooLarge

-- | 451
unavailableForLegalReasons :: forall m. MonadAff m => m Response
unavailableForLegalReasons = unavailableForLegalReasons' empty

-- | 451 with headers
unavailableForLegalReasons' :: forall m. MonadAff m => ResponseHeaders -> m Response
unavailableForLegalReasons' = emptyResponse' Status.unavailableForLegalReasons

---------
-- 5xx --
---------
-- | 500
internalServerError :: forall m b. MonadAff m => Body b => b -> m Response
internalServerError = internalServerError' empty

-- | 500 with headers
internalServerError' ::
  forall m b.
  MonadAff m =>
  Body b =>
  ResponseHeaders ->
  b ->
  m Response
internalServerError' = response' Status.internalServerError

-- | 501
notImplemented :: forall m. MonadAff m => m Response
notImplemented = notImplemented' empty

-- | 501 with headers
notImplemented' :: forall m. MonadAff m => ResponseHeaders -> m Response
notImplemented' = emptyResponse' Status.notImplemented

-- | 502
badGateway :: forall m. MonadAff m => m Response
badGateway = badGateway' empty

-- | 502 with headers
badGateway' :: forall m. MonadAff m => ResponseHeaders -> m Response
badGateway' = emptyResponse' Status.badGateway

-- | 503
serviceUnavailable :: forall m. MonadAff m => m Response
serviceUnavailable = serviceUnavailable' empty

-- | 503 with headers
serviceUnavailable' :: forall m. MonadAff m => ResponseHeaders -> m Response
serviceUnavailable' = emptyResponse' Status.serviceUnavailable

-- | 504
gatewayTimeout :: forall m. MonadAff m => m Response
gatewayTimeout = gatewayTimeout' empty

-- | 504 with headers
gatewayTimeout' :: forall m. MonadAff m => ResponseHeaders -> m Response
gatewayTimeout' = emptyResponse' Status.gatewayTimeout

-- | 505
hTTPVersionNotSupported :: forall m. MonadAff m => m Response
hTTPVersionNotSupported = hTTPVersionNotSupported' empty

-- | 505 with headers
hTTPVersionNotSupported' :: forall m. MonadAff m => ResponseHeaders -> m Response
hTTPVersionNotSupported' = emptyResponse' Status.hTTPVersionNotSupported

-- | 506
variantAlsoNegotiates :: forall m. MonadAff m => m Response
variantAlsoNegotiates = variantAlsoNegotiates' empty

-- | 506 with headers
variantAlsoNegotiates' :: forall m. MonadAff m => ResponseHeaders -> m Response
variantAlsoNegotiates' = emptyResponse' Status.variantAlsoNegotiates

-- | 507
insufficientStorage :: forall m. MonadAff m => m Response
insufficientStorage = insufficientStorage' empty

-- | 507 with headers
insufficientStorage' :: forall m. MonadAff m => ResponseHeaders -> m Response
insufficientStorage' = emptyResponse' Status.insufficientStorage

-- | 508
loopDetected :: forall m. MonadAff m => m Response
loopDetected = loopDetected' empty

-- | 508 with headers
loopDetected' :: forall m. MonadAff m => ResponseHeaders -> m Response
loopDetected' = emptyResponse' Status.loopDetected

-- | 510
notExtended :: forall m. MonadAff m => m Response
notExtended = notExtended' empty

-- | 510 with headers
notExtended' :: forall m. MonadAff m => ResponseHeaders -> m Response
notExtended' = emptyResponse' Status.notExtended

-- | 511
networkAuthenticationRequired :: forall m. MonadAff m => m Response
networkAuthenticationRequired = networkAuthenticationRequired' empty

-- | 511 with headers
networkAuthenticationRequired' :: forall m. MonadAff m => ResponseHeaders -> m Response
networkAuthenticationRequired' = emptyResponse' Status.networkAuthenticationRequired
