export GTK_IM_MODULE=scim
export XMODIFIERS=@im=SCIM
export QT_IM_MODULE=scim

scim -d
urxvtd -q -o -f

setxkbmap dvorak
xmodmap ~/.Xmodmap

i3
