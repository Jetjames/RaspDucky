#!/bin/bash
# This script is used to setup rspiducky by theresalu on github
# This script will only work on the Raspberry Pi Zero
# It also only works with this image (as far as I am aware): http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2016-02-29/

if [ $EUID -ne 0 ]; then
	echo "You must use sudo to run this script:"
	echo "sudo $0 $@"
	exit
fi

apt-get update 
apt-get upgrade -y
apt-get install rpi-update #???
BRANCH=next rpi-update c053625

## dwc2 drivers
#echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt
sed -i -e "\$adtoverlay=dwc2" /boot/config.txt

##Install git and download rspiducky
wget --no-check-certificate https://raw.githubusercontent.com/anbud/DroidDucky/master/droidducky.sh https://raw.githubusercontent.com/theresalu/rspiducky/master/usleep.c https://raw.githubusercontent.com/theresalu/rspiducky/master/hid-gadget-test.c https://github.com/theresalu/rspiducky/raw/master/hid-gadget-test https://github.com/theresalu/rspiducky/raw/master/usleep https://github.com/theresalu/rspiducky/raw/master/g_hid.ko

##Compile hid-gadget-test
##gcc hid-gadget-test.c -o hid-gadget-test

##Compile usleep 
##make usleep

##Make all nessisary files executeable
cd /home/pi
chmod 755 hid-gadget-test.c droidducky.sh usleep.c g_hid.ko usleep hid-gadget-test
#\cp???
\cp g_hid.ko /lib/modules/4.4.0+/kernel/drivers/usb/gadget/legacy

#echo "dwc2" | sudo tee /etc/modules
#echo "g_hid" | sudo tee -a /etc/modules
cat <<'EOF'>>/etc/modules
dwc2
g_hid
EOF

##Make it so that you can put the payload.dd in the /boot directory
sed -i '/exit/d' /etc/rc.local
cat <<'EOF'>>/etc/rc.local
sleep 3
cat /boot/payload.dd > /home/pi/payload.dd
sleep 1
tr -d '\r' < /home/pi/payload.dd > /home/pi/payload2.dd
sleep 1
/home/pi/droidducky.sh /home/pi/payload2.dd
exit 0
EOF

##Making the first payload
cat <<'EOF'>>/boot/payload.dd
GUI r
DELAY 50
STRING www.youtube.com/watch?v=dQw4w9WgXcQ
ENTER
EOF
