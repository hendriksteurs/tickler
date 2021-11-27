{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Tickler.API.Types
  ( module Tickler.API.Types,
    module Data.UUID.Typed,
  )
where

import Data.Aeson as JSON
import Data.UUID.Typed
import Import
import Intray.API ()
import Servant.API
import Servant.Auth
import Servant.Auth.Server
import Servant.HTML.Blaze
import Text.Blaze as HTML
import Text.Blaze.Html as HTML
import Tickler.Data
import qualified Web.Stripe.Plan as Stripe

type ProtectAPI = Auth '[JWT] AuthCookie

newtype AuthCookie = AuthCookie
  { authCookieUserUUID :: AccountUUID
  }
  deriving (Show, Eq, Generic, FromJSON, ToJSON)

instance FromJWT AuthCookie

instance ToJWT AuthCookie

data Registration = Registration
  { registrationUsername :: Username,
    registrationPassword :: Text
  }
  deriving (Show, Eq, Ord, Generic)

instance Validity Registration

instance ToJSON Registration where
  toJSON Registration {..} =
    object ["name" .= registrationUsername, "password" .= registrationPassword]

instance FromJSON Registration where
  parseJSON =
    withObject "Registration Text" $ \o -> Registration <$> o .: "name" <*> o .: "password"

data LoginForm = LoginForm
  { loginFormUsername :: Username,
    loginFormPassword :: Text
  }
  deriving (Show, Eq, Ord, Generic)

instance Validity LoginForm

instance FromJSON LoginForm where
  parseJSON = withObject "LoginForm" $ \o -> LoginForm <$> o .: "username" <*> o .: "password"

instance ToJSON LoginForm where
  toJSON LoginForm {..} = object ["username" .= loginFormUsername, "password" .= loginFormPassword]

data ChangePassphrase = ChangePassphrase
  { changePassphraseOld :: Text,
    changePassphraseNew :: Text
  }
  deriving (Show, Eq, Generic)

instance Validity ChangePassphrase

instance FromJSON ChangePassphrase where
  parseJSON =
    withObject "ChangePassphrase" $ \o ->
      ChangePassphrase <$> o .: "old-passphrase" <*> o .: "new-passphrase"

instance ToJSON ChangePassphrase where
  toJSON ChangePassphrase {..} =
    object ["old-passphrase" .= changePassphraseOld, "new-passphrase" .= changePassphraseNew]

data Pricing = Pricing
  { pricingPlan :: !Stripe.PlanId,
    pricingTrialPeriod :: !(Maybe Int),
    pricingPrice :: !Stripe.Amount,
    pricingCurrency :: !Stripe.Currency,
    pricingStripePublishableKey :: !Text,
    pricingMaxItemsFree :: !Int
  }
  deriving (Show, Eq, Generic)

instance Validity Pricing

instance FromJSON Pricing where
  parseJSON =
    withObject "Pricing" $ \o ->
      Pricing <$> o .: "plan" <*> o .:? "trial-period" <*> o .: "price" <*> o .: "currency"
        <*> o
        .: "publishable-key"
        <*> o
        .: "max-items-free"

instance ToJSON Pricing where
  toJSON Pricing {..} =
    object
      [ "plan" .= pricingPlan,
        "trial-period" .= pricingTrialPeriod,
        "price" .= pricingPrice,
        "currency" .= pricingCurrency,
        "publishable-key" .= pricingStripePublishableKey,
        "max-items-free" .= pricingMaxItemsFree
      ]

data LoopersInfo = LoopersInfo
  { emailerLooperInfo :: LooperInfo,
    triggererLooperInfo :: LooperInfo,
    verificationEmailConverterLooperInfo :: LooperInfo,
    triggeredIntrayItemSchedulerLooperInfo :: LooperInfo,
    triggeredIntrayItemSenderLooperInfo :: LooperInfo,
    triggeredEmailSchedulerLooperInfo :: LooperInfo,
    triggeredEmailConverterLooperInfo :: LooperInfo,
    adminNotificationEmailConverterLooperInfo :: LooperInfo,
    stripeEventsFetcherLooperInfo :: LooperInfo,
    stripeEventsRetrierLooperInfo :: LooperInfo
  }
  deriving (Show, Eq, Generic)

instance Validity LoopersInfo

instance FromJSON LoopersInfo

instance ToJSON LoopersInfo

data LooperInfo = LooperInfo
  { looperInfoStatus :: LooperStatus,
    looperInfoPeriod :: Maybe Int,
    looperInfoRetryDelay :: Maybe Int,
    looperInfoRetryAmount :: Maybe Int
  }
  deriving (Show, Eq, Generic)

instance Validity LooperInfo

instance FromJSON LooperInfo

instance ToJSON LooperInfo

data LooperStatus
  = LooperStatusDisabled
  | LooperStatusRunning
  | LooperStatusErrored Text
  | LooperStatusStopped
  deriving (Show, Eq, Generic)

instance Validity LooperStatus

instance FromJSON LooperStatus

instance ToJSON LooperStatus

newtype GetDocsResponse = GetDocsResponse
  { unGetDocsResponse :: HTML.Html
  }
  deriving (Generic)

instance MimeUnrender HTML GetDocsResponse where
  mimeUnrender Proxy bs = Right $ GetDocsResponse $ HTML.unsafeLazyByteString bs

instance ToMarkup GetDocsResponse where
  toMarkup (GetDocsResponse html) = toMarkup html
