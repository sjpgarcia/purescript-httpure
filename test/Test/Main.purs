module Test.Main where

import Prelude

import Effect.Aff (launchAff_)
import Test.HTTPure.BodySpec (bodySpec)
import Test.HTTPure.IntegrationSpec (integrationSpec)
import Test.HTTPure.LookupSpec (lookupSpec)
import Test.HTTPure.MethodSpec (methodSpec)
import Test.HTTPure.PathSpec (pathSpec)
import Test.HTTPure.QuerySpec (querySpec)
import Test.HTTPure.RequestHeadersSpec (requestHeadersSpec)
import Test.HTTPure.RequestSpec (requestSpec)
import Test.HTTPure.ResponseHeadersSpec (responseHeadersSpec)
import Test.HTTPure.ResponseSpec (responseSpec)
import Test.HTTPure.ServerSpec (serverSpec)
import Test.HTTPure.StatusSpec (statusSpec)
import Test.HTTPure.TestHelpers (TestSuite)
import Test.HTTPure.UtilsSpec (utilsSpec)
import Test.HTTPure.VersionSpec (versionSpec)
import Test.Spec (describe)
import Test.Spec.Reporter (specReporter)
import Test.Spec.Runner (runSpec)

main :: TestSuite
main = launchAff_ $ runSpec [ specReporter ] $ describe "HTTPure" do
  bodySpec
  lookupSpec
  methodSpec
  pathSpec
  querySpec
  requestHeadersSpec
  requestSpec
  responseHeadersSpec
  responseSpec
  serverSpec
  statusSpec
  utilsSpec
  versionSpec
  integrationSpec
