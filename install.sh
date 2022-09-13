#!/bin/bash
if [[ -d /usr/share/backgrounds/Dynamic_Wallpapers ]]
then 
	sudo rm -r /usr/share/backgrounds/Dynamic_Wallpapers
	echo "Cleaning up"
fi

echo "Installing wallpapers..."
sudo mkdir -p /usr/share/backgrounds/
sudo mkdir -p /usr/share/gnome-background-properties/ 
sudo cp -r $(pwd)/Dynamic_Wallpapers /usr/share/backgrounds/Dynamic_Wallpapers
sudo cp $(pwd)/xml/* /usr/share/gnome-background-properties/
echo "Wallpapers has been installed. Enjoy setting them as your desktop background!"
