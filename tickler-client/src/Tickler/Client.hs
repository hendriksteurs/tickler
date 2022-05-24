{-# LANGUAGE DataKinds #-}

module Tickler.Client
  ( module Tickler.Client,
    module Tickler.API,
    module Data.UUID.Typed,
    NoContent (..),
    Token,
    module Servant.Client,
  )
where

import Data.Time
import qualified Data.UUID.Typed
import Import
import Servant.API
import Servant.API.Flatten
import Servant.Auth.Client
import Servant.Client
import Tickler.API

clientGetItems :: Token -> ClientM [ItemInfo]
clientPostItem :: Token -> Tickle -> ClientM ItemUUID
clientGetItem :: Token -> ItemUUID -> ClientM ItemInfo
clientPutItem :: Token -> ItemUUID -> Tickle -> ClientM NoContent
clientDeleteItem :: Token -> ItemUUID -> ClientM NoContent
clientGetTriggers :: Token -> ClientM [TriggerInfo]
clientGetTrigger :: Token -> TriggerUUID -> ClientM TriggerInfo
clientPostIntrayTrigger :: Token -> AddIntrayTrigger -> ClientM (Either Text TriggerUUID)
clientPostEmailTrigger :: Token -> AddEmailTrigger -> ClientM TriggerUUID
clientPostEmailTriggerVerify :: Token -> TriggerUUID -> EmailVerificationKey -> ClientM NoContent
clientPostEmailTriggerResendVerificationEmail :: Token -> TriggerUUID -> ClientM NoContent
clientDeleteTrigger :: Token -> TriggerUUID -> ClientM NoContent
clientGetAccountInfo :: Token -> ClientM AccountInfo
clientGetAccountSettings :: Token -> ClientM AccountSettings
clientPostChangePassphrase :: Token -> ChangePassphrase -> ClientM NoContent
clientPutAccountSettings :: Token -> AccountSettings -> ClientM NoContent
clientDeleteAccount :: Token -> ClientM NoContent
clientPostRegister :: Registration -> ClientM NoContent
clientPostLogin :: LoginForm -> ClientM (Headers '[Header "Set-Cookie" Text] NoContent)
clientGetPricing :: ClientM (Maybe Pricing)
clientAdminGetStats :: Token -> ClientM AdminStats
clientAdminDeleteAccount :: Token -> AccountUUID -> ClientM NoContent
clientAdminGetAccount :: Token -> Username -> ClientM AccountInfo
clientAdminGetAccounts :: Token -> ClientM [AccountInfo]
clientAdminPutUserSubscription :: Token -> Username -> UTCTime -> ClientM NoContent
clientGetItems
  :<|> clientPostItem
  :<|> clientGetItem
  :<|> clientPutItem
  :<|> clientDeleteItem
  :<|> clientGetTriggers
  :<|> clientGetTrigger
  :<|> clientPostIntrayTrigger
  :<|> clientPostEmailTrigger
  :<|> clientPostEmailTriggerVerify
  :<|> clientPostEmailTriggerResendVerificationEmail
  :<|> clientDeleteTrigger
  :<|> clientGetAccountInfo
  :<|> clientGetAccountSettings
  :<|> clientPostChangePassphrase
  :<|> clientPutAccountSettings
  :<|> clientDeleteAccount
  :<|> clientPostRegister
  :<|> clientPostLogin
  :<|> clientGetPricing
  :<|> clientAdminGetStats
  :<|> clientAdminDeleteAccount
  :<|> clientAdminGetAccount
  :<|> clientAdminGetAccounts
  :<|> clientAdminPutUserSubscription =
    client (flatten ticklerAPI)
