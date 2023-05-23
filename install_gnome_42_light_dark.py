#!/usr/bin/env python
import argparse
import re
import shutil

from xml.dom import minidom
from pathlib import Path

P_COLOR = "#3465a4"
S_COLOR = "#000000"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("bundle_name")
    parser.add_argument("path_to_wallpapers", type=Path)
    parser.add_argument("install_dir", type=Path)
    args = parser.parse_args()

    process_wallpapers(
        args.bundle_name,
        args.path_to_wallpapers,
        args.install_dir / "backgrounds" / args.bundle_name,
        args.install_dir / "gnome-background-properties",
    )


def process_wallpapers(bundle_name: str, input_path: Path, output_image_dir: Path, output_xml_dir: Path):
    print(bundle_name, input_path, output_image_dir, output_xml_dir)
    filtered = filter_wallpapers(input_path)
    renamed = rename_wallpapers(filtered)
    new_paths = prepare_output_paths(renamed, output_image_dir)
    wallpaper_xmls = create_wallpaper_descriptions(new_paths)
    output_xml_dir.mkdir(parents=True, exist_ok=True)
    output_image_dir.mkdir(parents=True, exist_ok=True)
    with open(output_xml_dir / f"{bundle_name}.xml", "w") as xml_file:
        wallpaper_xmls.writexml(xml_file, indent="  ", addindent="  ", newl="\n")
    copy_wallpapers(filtered, new_paths)


def prepare_output_paths(
    wallpapers: dict[str, tuple[Path, Path]],
    output_dir: Path,
) -> dict[str, tuple[Path, Path]]:
    changed_dir = {}
    for wallpaper, (light_variant, dark_variant) in wallpapers.items():
        changed_dir[wallpaper] = (
            output_dir / light_variant.name,
            output_dir / dark_variant.name,
        )
    return changed_dir


def filter_wallpapers(input_path: Path) -> dict[str, tuple[Path, Path]]:
    wallpaper_dirs = [d for d in input_path.iterdir() if d.is_dir()]
    filtered_wallpapers = {}
    for wallpaper in wallpaper_dirs:
        variants = sorted(wallpaper.iterdir())
        if len(variants) < 2:
            continue
        filtered_wallpapers[wallpaper.name] = variants[0], variants[-1]
    return filtered_wallpapers


def rename_wallpapers(wallpapers: dict[str, tuple[Path, Path]]) -> dict[str, tuple[Path, Path]]:
    renamed_wallpapers = {}
    for wallpaper, (light_variant, dark_variant) in wallpapers.items():
        renamed_wallpapers[wallpaper] = rename(light_variant, dark_variant)
    return renamed_wallpapers


def rename(light_variant: Path, dark_variant: Path) -> tuple[Path, Path]:
    new_light_name, new_dark_name = [
        re.sub(r"[-_]?(\d+|day|night)$", "", v.stem) for v in (light_variant, dark_variant)
    ]
    return (
        light_variant.with_stem(f"{new_light_name}-l"),
        dark_variant.with_stem(f"{new_dark_name}-d"),
    )


def create_text_element(doc: minidom.Document, element_name: str, text: str):
    node = doc.createElement(element_name)
    node.appendChild(doc.createTextNode(text))
    return node


def create_wallpaper_descriptions(wallpapers: dict[str, tuple[Path, Path]]):
    descriptions = {}
    imp = minidom.getDOMImplementation()
    dt = imp.createDocumentType("wallpapers", None, "gnome-wp-list.dtd")
    doc = imp.createDocument("http://www.w3.org/1999/xhtml", "wallpapers", doctype=dt)
    e_wallpapers = doc.documentElement

    for wallpaper, (light_variant, dark_variant) in wallpapers.items():
        # Create elements
        e_wallpaper = doc.createElement("wallpaper")
        e_name = create_text_element(doc, "name", wallpaper)
        e_filename = create_text_element(doc, "filename", str(light_variant.absolute()))
        e_filename_dark = create_text_element(doc, "filename-dark", str(dark_variant.absolute()))
        e_options = create_text_element(doc, "options", "zoom")
        e_shade_type = create_text_element(doc, "shade_type", "solid")
        e_pcolor = create_text_element(doc, "pcolor", P_COLOR)
        e_scolor = create_text_element(doc, "scolor", S_COLOR)

        # Create structure
        for elem in [e_name, e_filename, e_filename_dark, e_options, e_shade_type, e_pcolor, e_scolor]:
            e_wallpaper.appendChild(elem)
        e_wallpapers.appendChild(e_wallpaper)

    xml_str = doc.toprettyxml(indent="  ")
    return doc


def copy_wallpapers(source_wallpapers, dest_wallpapers: dict[str, tuple[Path, Path]]) -> None:
    for wallpaper in dest_wallpapers:
        light_src, dark_src = source_wallpapers[wallpaper]
        light_dst, dark_dst = dest_wallpapers[wallpaper]
        shutil.copy(light_src, light_dst)
        shutil.copy(dark_src, dark_dst)


if __name__ == "__main__":
    main()
