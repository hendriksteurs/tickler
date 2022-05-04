{-# LANGUAGE OverloadedStrings #-}

module Tickler.Server.Looper.VerificationEmailConverterSpec (spec) where

import Data.Time
import Data.UUID as UUID
import Data.UUID.Typed as Typed
import TestImport
import Tickler.Data
import Tickler.Server.Looper.VerificationEmailConverter
import Tickler.Server.OptParse.Types

spec :: Spec
spec = do
  let sets =
        VerificationEmailConverterSettings
          { verificationEmailConverterSetFromAddress = unsafeEmailAddress "tickler" "example.com",
            verificationEmailConverterSetFromName = "tickler",
            verificationEmailConverterSetWebHost = "https://tickler.example.com"
          }
  let ve =
        VerificationEmail
          { verificationEmailTo = unsafeEmailAddress "user" "example.com",
            verificationEmailKey = EmailVerificationKey "49320818b7a577a41ba727ac511b4e63",
            verificationEmailTrigger = Typed.UUID (UUID.fromWords 1 2 3 4),
            verificationEmailScheduled = UTCTime (fromGregorian 2022 05 04) 1234,
            verificationEmailEmail = Nothing
          }
  let urlRender = error "unused"

  it "produces the same subject as last time" $
    pureGoldenTextFile
      "test_resources/email/verification.subject"
      verificationEmailSubject

  it "produces the same text content as last time" $
    pureGoldenTextFile "test_resources/email/verification.text" $
      verificationEmailTextContent sets ve urlRender

  it "produces the same text content as last time" $
    pureGoldenTextFile "test_resources/email/verification.html" $
      verificationEmailHtmlContent sets ve urlRender
