#!/bin/bash

read -p "Insert the path of the day wallpaper: " daywallpaper
read -p "Insert the path of the night wallpaper: " nightwallpaper
read -p "What name would like to attribute to the dynamic wallpaper? " dwallpapername

daywallpapername=$(basename -- "$daywallpaper")
daywallpaperextension="${daywallpapername##*.}"

nightwallpapername=$(basename -- "$nightwallpaper")
nightwallpaperextension="${nightwallpapername##*.}"

mv -v "$daywallpaper" "${dwallpapername}-1.${daywallpaperextension}"

mv -v "$nightwallpaper" "${dwallpapername}-2.${nightwallpaperextension}"

mkdir Dynamic_Wallpapers/$dwallpapername
echo "Created $dwallpapername folder"
chmod u+rwx Dynamic_Wallpapers/$dwallpapername

mv -t Dynamic_Wallpapers/$dwallpapername "${dwallpapername}-1.${daywallpaperextension}" "${dwallpapername}-2.${nightwallpaperextension}"
echo "Moved wallpapers in $dwallpapername folder"
cd Dynamic_Wallpapers
echo "<background>
	<starttime>
		<year>2018</year>
		<month>1</month>
		<day>1</day>
		<hour>6</hour>
		<minute>0</minute>
		<second>0</second>
	</starttime>

	<static>
		<file>/usr/share/backgrounds/Dynamic_Wallpapers/$dwallpapername/"${dwallpapername}-1.${daywallpaperextension}"</file>
		<duration>42300.0</duration>
	</static>

	<transition type=\"overlay\">
		<duration>900.0</duration>
		<from>/usr/share/backgrounds/Dynamic_Wallpapers/$dwallpapername/"${dwallpapername}-1.${daywallpaperextension}"</from>
		<to>/usr/share/backgrounds/Dynamic_Wallpapers/$dwallpapername/"${dwallpapername}-2.${nightwallpaperextension}"</to>
	</transition>

	<static>
		<file>/usr/share/backgrounds/Dynamic_Wallpapers/$dwallpapername/"${dwallpapername}-2.${nightwallpaperextension}"</file>
		<duration>42300.0</duration>
	</static>

	<transition type=\"overlay\">
		<duration>900.0</duration>
    <from>/usr/share/backgrounds/Dynamic_Wallpapers/$dwallpapername/"${dwallpapername}-2.${nightwallpaperextension}"</from>
		<to>/usr/share/backgrounds/Dynamic_Wallpapers/$dwallpapername/"${dwallpapername}-1.${daywallpaperextension}"</to>
	</transition>
    </background>" > $dwallpapername.xml
chmod	u+rwx $dwallpapername.xml
cd ..
cd xml
echo "<?xml version=\"1.0\"?>
<!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">
<wallpapers>
  <wallpaper deleted=\"false\">
    <name>$dwallpapername</name>
    <filename>/usr/share/backgrounds/Dynamic_Wallpapers/$dwallpapername.xml</filename>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#3465a4</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
</wallpapers>" > $dwallpapername.xml
chmod	u+rwx $dwallpapername.xml
echo "Created xml files"
echo "Done!"
