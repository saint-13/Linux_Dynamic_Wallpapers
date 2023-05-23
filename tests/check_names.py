#!/bin/python3
import os

XML_SLIDESHOW_PATH = "./xml"
WALLPAPER_PATH = "./Dynamic_Wallpapers"
    
def check_exists(name):
    """
    check if all files have the same name
    """
    # Check xml slideshow
    path = f"{XML_SLIDESHOW_PATH}/{name}.xml"
    if not os.path.exists(path):
        print(f"{path} don't exists")
        return False
    
    # check xml wallpaper
    path = f"{WALLPAPER_PATH}/{name}.xml"
    if not os.path.exists(path):
        print(f"{path} don't exists")
        return False
    
    # check jpeg folder
    path = f"{WALLPAPER_PATH}/{name}/"
    if not os.path.exists(path):
        print(f"{path} don't exists")
        return False
    
    return True

DIR = "./xml"
errors = 0
for filename in os.listdir(DIR):
    if not check_exists(filename.replace(".xml", "")):
        errors += 1

print(f"{errors} errors detected")
