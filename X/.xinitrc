xmodmap ~/.Xmodmap
xmodmap ~/layouts/dvorak
nappis.zsh
xrdb ~/.Xresources

#syndaemon -k -i 1 -d &

export GTK_IM_MODULE="scim"
export XMODIFIERS=@im=SCIM
export QT_IM_MODULE="scim"
scim -d 
pulseaudio --start &

#autocutsel -fork &
#autocutsel -selection PRIMARY -fork &

feh --bg-tile ~/pics/cat_tiling.png

#exec cinnamon-session

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
#xrandr --output eDP-1-0 --off

exec xmonad
