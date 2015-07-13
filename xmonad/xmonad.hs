import XMonad
import Data.Monoid
import System.Exit
import System.Environment
import Control.Monad
 
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.XMonad
import XMonad.Util.Scratchpad
import XMonad.Util.Run
import XMonad.Hooks.DynamicLog 
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.NoBorders
import XMonad.Actions.CopyWindow
import XMonad.SpawnOn

myTerminal      = "urxvt"
 
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
 
myBorderWidth   = 1
 
modm       = mod4Mask
--modAlt     = mod1Mask
 
myWorkspaces = map show [1..22]
 
xftFont = "xft:Mensch:size=10"
colorBlack="#181818"
colorRed="#ab4642"
colorGreen="#a1b56c"
colorYellow="#f7ca88"
colorBlue="#7cafc2"
colorMagenta="#ba8baf"
colorCyan="#86c1b9"
colorWhite="#d8d8d8"
colorGray="#585858"

myNormalBorderColor = colorGray
myFocusedBorderColor = colorRed

myWorkspaceKeys = [(k, m) | m <- masks, k <- keys]
    where masks = [0, controlMask]
          keys = [xK_1, xK_2, xK_3, xK_4, xK_apostrophe, xK_comma, xK_period, xK_p, xK_a, xK_o, xK_e] 

myXPConfig = defaultXPConfig
    { font              = xftFont
    , fgColor           = colorBlue
    , bgColor           = colorBlack
    , bgHLight          = colorBlack
    , fgHLight          = colorRed
    , promptBorderWidth = 0
    , position          = Bottom
    }

myKeys conf = M.fromList $
  [ ((modm  , xK_d ), spawn $ terminal conf )
  , ((modm  , xK_i ), sendMessage NextLayout)
  , ((modm  , xK_k ), windows W.focusDown )
  , ((modm  , xK_j ), windows W.focusUp )
  , ((modm  , xK_Return ), windows W.swapMaster )
  , ((modm  , xK_u), withFocused $ windows . W.sink) -- Push window back into tiling
  , ((modm  , xK_w ), sendMessage Shrink)
  , ((modm  , xK_v ), sendMessage Expand)
  , ((modm  , xK_semicolon ), sendMessage (IncMasterN (-1)))
  , ((modm  , xK_q ), sendMessage (IncMasterN 1))
  , ((modm  , xK_Delete ), kill )
  , ((modm  , xK_b ), kill )
  , ((modm  , xK_r ), shellPrompt myXPConfig )
  , ((modm             , xK_z ), scratchpadSpawnActionTerminal myTerminal)
  , ((modm  , xK_y ), broadcastMessage ReleaseResources >> restart "xmonad" True)

  , ((modm  , xK_h), spawn "random_wallpapers")

  , ((modm  , xK_F1), spawn "setxkbmap dvorak; xmodmap ~/.Xmodmap")
  , ((modm  , xK_F2), spawn "setxkbmap fi")

  , ((modm  , xK_F4), spawn "trackpad-toggle.sh")
  ]
  -- Switch between monitors
  ++
  [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_n, xK_t, xK_s] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
  -- Switch between workspaces
  ++
  [((m1 .|. m2 .|. modm, k), windows $ f i)
    | (i, (k, m1)) <- zip myWorkspaces myWorkspaceKeys
    , (f, m2) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
 
-- Mouse bindings
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
 
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
 
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
 
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
 
myLayout = avoidStruts $ smartBorders (tiled ||| Mirror tiled ||| Full)
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100

myManageHook = scratchpadManageHookDefault <+> composeAll
  [ isFullscreen --> doFullFloat
  , className =? "Firefox"        --> doShift "11"
  , className =? "Smplayer"        --> doFloat
  , className =? "mplayer2"        --> doFloat
  , className =? "mpv"        --> doFloat
  , className =? "mupen64plus"        --> doFloat
  , className =? "Pavucontrol"        --> doFloat
  , className =? "Steam"        --> doFloat
  , className =? "DOTA 2 - OpenGL"        --> doFullFloat
  , className =? "dota_linux"        --> doFullFloat
  , className =? "dota.sh"        --> doFullFloat
  , className =? "Gimp"           --> doFloat
  , className =? "Vlc"           --> doFloat
  , title =? "neflEFortress" --> doFloat
  , title =? "Isaac" --> doFloat
  , className =? "Isaac" --> doFloat
  , className =? "Wine" --> doFullFloat
  , resource  =? "desktop_window" --> doIgnore
  , resource  =? "kdesktop"       --> doIgnore 
  ]
 
myStartupHook = do
    setWMName "LG3D"
    args <- io getArgs
    -- Check for the first start
    unless ("--resume" `elem` args) $ do
        spawnOn "16" "liferea"
        spawnOn "17"  (myTerminal ++ " -e env RUN_POSTGRES=1 zsh -i")
        spawnOn "17"  (myTerminal ++ " -e env RUN_GIZLO=1 zsh -i")
        replicateM 4 $ spawnOn "6"  (myTerminal ++ " -e env RUN_GIZLO=1 zsh -i")
        replicateM 4 $ spawnOn "7"  (myTerminal ++ " -e env RUN_GIZLO_DASHBOARD=1 zsh -i")
        spawnOn "10" "tagainijisho"
        spawn "firefox"
        spawnOn "3"  (myTerminal ++ " -e env RUN_IRC=1 zsh -i")
        spawnOn "20"  (myTerminal ++ " -e env RUN_RTORRENT=1 zsh -i")


toggleStrutsKey XConfig{modMask = modm} = (modm, xK_l)
myStatusBar = statusBar "xmobar" xmobarPP{ppOrder = (\(_:_:t:_) -> [t])} toggleStrutsKey
main = xmonad =<< myStatusBar defaults

defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = modm,

        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
 
      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
 
      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = manageSpawn <+> myManageHook,
        startupHook        = myStartupHook
    }
