#!/bin/bash
cd ~
echo "Downloading needed files started"
git clone https://github.com/saint-13/Linux_Dynamic_Wallpapers.git  
cd Linux_Dynamic_Wallpapers
echo "Files downloaded"

if [[ -d /usr/share/backgrounds/Dynamic_Wallpapers ]]
then 
	sudo rm -r /usr/share/backgrounds/Dynamic_Wallpapers
	echo "Setting up"
fi

echo "Installing wallpapers..."
sudo cp -r ./Dynamic_Wallpapers/ /usr/share/backgrounds/
sudo cp ./xml/* /usr/share/gnome-background-properties/
echo "Dynamic Wallpapers has been installed!"
cd ~ 
echo "Deleting files used only for the installation process"
sudo rm -r Linux_Dynamic_Wallpapers
echo "    |"
echo "    '---> Deleted unneeded files!"
echo "Now, don't forget to set your preferred dynamic wallpaper from Settings!"
