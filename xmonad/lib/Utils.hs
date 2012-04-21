{-# LANGUAGE TypeSynonymInstances, DeriveDataTypeable, MultiParamTypeClasses #-}

module Utils where

import Codec.Binary.UTF8.String
import Control.Applicative
import Control.Concurrent (threadDelay)
import Control.Monad
import Data.List
import Data.Maybe
import Data.Monoid
import Data.Set (Set)
import System.Environment (getEnvironment)
import System.Posix.Process (createSession, executeFile, forkProcess)
import System.Posix.Types (ProcessGroupID(..))
import Text.Regex.Posix ((=~))
import qualified Data.Set as S
import qualified Network.MPD as MPD

import XMonad
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.MultiToggle
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Util.WorkspaceCompare
import XMonad.Util.Run
import qualified XMonad.StackSet as W
import qualified XMonad.Util.ExtensibleState as XS

import Proc

data TNBFULL = TNBFULL deriving (Read, Show, Eq, Typeable)

instance Transformer TNBFULL Window where
    transform TNBFULL x k = k (tag "Triggered" $ noBorders Full) (const x)
      where tag t = renamed [ PrependWords t ]

data BorderUrgencyHook = BorderUrgencyHook !String
    deriving (Show, Read)

instance UrgencyHook BorderUrgencyHook where
    urgencyHook (BorderUrgencyHook cs) w = withDisplay $ \dpy -> io $
        initColor dpy cs >>= maybe (return ()) (setWindowBorder dpy w)

to9 :: [String] -> [String]
to9 ws = (ws ++) . drop (length ws) $ map show [1..9]

queryAny :: Eq a => Query a -> [a] -> Query Bool
queryAny q xs = foldl1 (<||>) $ (q =?) <$> xs

(~?) :: (Functor f) => f String -> String -> f Bool
q ~? x = (=~ x) <$> q

prefixed :: (Functor f) => f String -> String -> f Bool
q `prefixed` x = (x `isPrefixOf`) <$> q

composeOneCaught :: ManageHook -> [MaybeManageHook] -> ManageHook
composeOneCaught f h = composeOne $ h ++ [ Just <$> f ]

role :: Query String
role = stringProperty "WM_WINDOW_ROLE"

isFirefoxPreferences :: Query Bool
isFirefoxPreferences = className =? "Firefox" <&&> role =? "Preferences"

withFocused' :: (Window -> X ()) -> X ()
withFocused' f = withWindowSet $ \ws -> whenJust (W.peek ws) $
    \w -> hasResource [ "scratchpad" ] w >>= flip unless (f w)

hasResource :: [String] -> Window -> X Bool
hasResource ign w = withDisplay $ \d -> io $ (`elem` ign) . resName <$> getClassHint d w

getSortByIndexWithoutNSP :: X WorkspaceSort
getSortByIndexWithoutNSP = (. filter ((/= "NSP") . W.tag)) <$> getSortByIndex

delayedSpawn :: Int -> String -> [String] -> X ()
delayedSpawn d cmd args = io (threadDelay d) >> safeSpawn cmd args

env :: String -> IO (Maybe String)
env = (<$> getEnvironment) . lookup

getBrowser :: String -> IO String
getBrowser = (<$> env "BROWSER") . fromMaybe

getHome :: IO String
getHome = fromMaybe "/home/simongmzlj" <$> env "HOME"

startServices :: [String] -> X ()
startServices cmds = io (service <$> pidSet) >>= forM_ cmds
  where
    service pm cmd = when (S.null $ findCmd cmd pm) $ safeSpawn cmd []

data CompositorPID = CompositorPID (Maybe ProcessGroupID) deriving (Read, Show, Typeable)

instance ExtensionClass CompositorPID where
   initialValue  = CompositorPID Nothing
   extensionType = PersistentExtension

startCompositor :: String -> [String] -> X ()
startCompositor prog args = XS.get >>= \(CompositorPID p) -> do
    case p of
        Just pid -> return ()
        Nothing  -> CompositorPID . Just <$> safeSpawnPid prog args >>= XS.put

safeSpawnPid :: MonadIO m => FilePath -> [String] -> m ProcessGroupID
safeSpawnPid prog args = io $ forkProcess $ do
  uninstallSignalHandlers
  _ <- createSession
  executeFile (encodeString prog) True (map encodeString args) Nothing

withMPD :: MPD.MPD a -> X ()
withMPD = io . void . MPD.withMPD
