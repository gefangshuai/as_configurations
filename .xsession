export XIM=SCIM
export XIM_PROGRAM="scim"
export GTK_IM_MODULE="scim"
export QT_IM_MODULE="xim"
export XMODIFIERS="@im=scim"
scim -d
#scim -f socket -ns socket -c simple -d
#export XMODIFIERS=@im=fcitx
#export XIM=fcitx
#export XIM_PROGRAM=fcitx
#export GTK_IM_MODULE=fcitx
#export QT_IM_MODULE=fcitx
#fcitx &
#urxvtd &
#xcompmgr &
exec fvwm
