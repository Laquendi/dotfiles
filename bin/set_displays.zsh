#!/bin/zsh
xrandr --fb 5760x1200 \
 --output eDP-1-0 --mode 1920x1080 --pos 3840x0 --panning 5760x1200+0+0/1920x1080+3840+0\
 --output HDMI-0 --mode 1920x1200 --pos 1920x0 --primary --panning 5760x1200+0+0/1920x1200+1920+0\
 --output DP-1 --mode 1920x1200 --pos 0x0 --panning 5760x1200+0+0/1920x1200+0+0

#xrandr --fb 5760x1200 \
 #--output eDP-1-0 --mode 1920x1080 --pos 3840x120 --panning 0x0
 #--output HDMI-0 --mode 1920x1200 --pos 1920x0 --panning 0x0

#xrandr --fb 3840x1200 \
 #--output eDP-1-0 --mode 1920x1080 --pos 1920x0\
 #--output DP-1 --mode 1920x1200 --pos 0x0 --primary --panning 3840x1200+0+0/1920x1080+0+0
