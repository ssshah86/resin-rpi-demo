#!/bin/bash
# Script that tries to connect to google.com 
curl -s --connect-timeout 52 http://www.google.com  > /dev/null
if [[ $? != 0 ]]; then
    echo "Internet connection seems down, restarting device" >> /data/soracom.log;
    # Reset USB
    echo 0 > /sys/devices/platform/soc/3f980000.usb/buspower;
    sleep 5
    echo 1 > /sys/devices/platform/soc/3f980000.usb/buspower;
    sleep 5
	if [[ -n "${CELLULAR_ONLY}" ]]; then
		# Reset WiFi
		/sbin/modprobe -r brcmfmac
		/sbin/modprobe -r brcmutil
		echo 0x0 > /sys/devices/platform/soc/3f980000.usb/buspower
		sleep 5
		/sbin/modprobe brcmfmac
		/sbin/modprobe brcmutil
		echo 0x1 > /sys/devices/platform/soc/3f980000.usb/buspower
		sleep 5
	fi
    # Resin SUPERVISOR call to reboot the device
    curl -X POST --header "Content-Type:application/json" "$RESIN_SUPERVISOR_ADDRESS/v1/reboot?apikey=$RESIN_SUPERVISOR_API_KEY"
fi