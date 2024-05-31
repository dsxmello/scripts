#!/bin/bash
echo -e "\033[01;33m\nZram Enable Script By Twel12 \033[0m"

read -p "Enter Size in MB to Enable Zram for Example for 20MB enter 20
" ZRAM_SIZE

re='^[0-9]+$'
if ! [[ $ZRAM_SIZE =~ $re ]] ; then
   echo "error: Entered Value is not a valid integer value!" >&2; exit 1

fi

sudo swapoff -a

function script_error() {
exit_code=$?
if [[ $exit_code != 0 ]]; then
	if [[ $1 != "" ]]; then
		echo "$1"
		echo "Could Not Configure Zram $exit_code"
	else
		echo "Could Not Configure Zram $exit_code"
	fi
    	sudo rm -rf /etc/modules-load.d/zram.conf
    	sudo rm -rf /etc/modprobe.d/zram.conf
    	sudo rm -rf /etc/udev/rules.d/99-zram.rules
    	sudo rm -rf /etc/systemd/system/zram.service
	exit $exit_code
fi
}

echo 'zram' | sudo tee -a /etc/modules-load.d/zram.conf
echo 'options zram num_devices=1' | sudo tee -a /etc/modprobe.d/zram.conf
echo 'KERNEL=="zram0", ATTR{disksize}="'$ZRAM_SIZE'M",TAG+="systemd"' | sudo tee -a /etc/udev/rules.d/99-zram.rules
echo "[Unit]
Description=Swap with zram
After=multi-user.target
[Service]
Type=oneshot 
RemainAfterExit=true
ExecStartPre=/sbin/mkswap /dev/zram0
ExecStart=/sbin/swapon /dev/zram0
ExecStop=/sbin/swapoff /dev/zram0
[Install]
WantedBy=multi-user.target" | sudo tee -a  /etc/systemd/system/zram.service
systemctl enable zram
script_error
echo "Zram Successfully Configured"
read -p "Do you want to reboot(y/n)" choice
if [[ $choice == *"y"* ]]; then
    reboot
else
    echo ""
    echo -e "\e[36m\e[1mReboot To See Changes"
fi
