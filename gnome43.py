#! /usr/bin/python3

import os
from shutil import copy as shcopy


def generate_xml_wallpaper(name, day_relative_path, night_relative_path):
    return \
f"""<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>{name}</name>
    <filename>/usr/share/backgrounds/Dynamic_Wallpapers/{day_relative_path}</filename>
    <filename-dark>/usr/share/backgrounds/Dynamic_Wallpapers/{night_relative_path}</filename-dark>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#3465a4</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
</wallpapers>
"""


if __name__ == "__main__":
    root_dir = os.getcwd()
    xml_43_dir = os.path.join(root_dir, 'xml_gnome43')
    dynamic_dir = os.path.join(root_dir, 'Dynamic_Wallpapers')
    
    if not os.path.exists(dynamic_dir):
        print('Run this script from its directory.')
        exit(1)
    if not os.path.exists(xml_43_dir):
        os.mkdir(xml_43_dir)
        
    for wallpaper_name in os.listdir(dynamic_dir):
        content = os.listdir(os.path.join(dynamic_dir, wallpaper_name))
        if len(content) != 2:
            for xml in os.listdir(os.path.join(root_dir, 'xml')):
                if xml.startswith(wallpaper_name):
                    print(f'Copying old configuration for {wallpaper_name} wallpaper...')
                    shcopy(os.path.join(root_dir, 'xml', xml), xml_43_dir)                
            continue
                
        day_relative_path = os.path.join(wallpaper_name, content[0])
        night_relative_path = os.path.join(wallpaper_name, content[1])
        
        print(f'Writing configuration for {wallpaper_name} wallpaper...')
        with open(os.path.join(xml_43_dir, wallpaper_name + '.xml'), 'w') as fd:
            fd.write(generate_xml_wallpaper(wallpaper_name, day_relative_path, night_relative_path))
        