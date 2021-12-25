#!/bin/bash

echo "installing the wallpepers to /usr/share/backgrounds/Dynamic_Wallpapers/"
sudo cp -r ./Dynamic_Wallpapers/ /usr/share/backgrounds/
sudo cp ./xml/* /usr/share/gnome-background-properties/
echo "Wallpapers has been installed"
