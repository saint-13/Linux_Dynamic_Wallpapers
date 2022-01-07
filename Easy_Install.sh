#!/bin/bash
cd ~
echo "Downloading needed files started"
git clone https://github.com/saint-13/Linux_Dynamic_Wallpapers.git
echo "Files downloaded"
cd Linux_Dynamic_Wallpapers
if [[ -d /usr/share/backgrounds/Dynamic_Wallpapers ]]
then 
	sudo rm -r /usr/share/backgrounds/Dynamic_Wallpapers
	echo "Cleaning up"
fi	
echo "Installing wallpapers..."
sudo cp -r ./Dynamic_Wallpapers/ /usr/share/backgrounds/
sudo cp ./xml/* /usr/share/gnome-background-properties/
cd ~ 
echo "Deleting files used only for the installation process"
sudo rm -r Linux_Dynamic_Wallpapers
echo "Wallpapers has been installed. Enjoy setting them as your desktop background!"

