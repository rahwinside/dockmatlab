#!/bin/bash

eval printf %.1s '-{1..'"${COLUMNS:-$(tput cols)}"\}; echo
echo dockMATLAB by theflyingrahul
# Written by Rahul (FPM-2121012) (C)2022
# eval printf %.1s '-{1..'"${COLUMNS:-$(tput cols)}"\}; echo
echo ;

function get_unused_port() {
  for port in $(seq $1 $2);
  do
    echo -ne "\035" | telnet 127.0.0.1 $port > /dev/null 2>&1;
    [ $? -eq 1 ] && echo "$port" && break;
  done
}

# find free VNC port
VNC_PORT="$(get_unused_port 5901 6079)"
echo Starting VNC on: $VNC_PORT

# find free noVNC port
NOVNC_PORT="$(get_unused_port 6080 6256)"
echo Starting noVNC on: $NOVNC_PORT

# generate random password
PASSWORD="$(echo $RANDOM | md5sum | head -c 8)"

# eval printf %.1s '-{1..'"${COLUMNS:-$(tput cols)}"\}; echo

echo ;
echo "Instructions to access MATLAB installation:"

echo "If you are using an VNC Client (like RealVNC VNC Viewer), connect via:"
printf "\t172.21.100.193:`expr $VNC_PORT - 5900`\n"
printf "\tPassword: $PASSWORD \n"

echo ;
echo "To access MATLAB from your browser, navigate to the below URL:"
printf "\thttp://172.21.100.193:$NOVNC_PORT/vnc.html?password="$PASSWORD"&autoconnect=true&resize=remote\n"

echo ;
echo "Your user home directory '/home/$USER' is mounted at '/home/matlab/""$USER""_home'. Please save your working files inside this directory only."
echo "WARNING: Your work will be lost if you save your files elsewhere!"

echo ;
echo "To quit MATLAB and exit to console, press Control^+C."
eval printf %.1s '-{1..'"${COLUMNS:-$(tput cols)}"\}; echo

docker run -it --rm -p $VNC_PORT:5901 -p $NOVNC_PORT:6080 --shm-size=512M -v /home/$USER/:/home/matlab/"$USER"_home/ -e PASSWORD=$PASSWORD  mathworks/matlab:r2021b -vnc >/dev/null 2>&1

