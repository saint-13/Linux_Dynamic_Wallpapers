#!/bin/bash

# install_user.sh — User-level installation of the Dynamic Wallpapers
#
# Installs wallpapers into the user's home directory instead of /usr/share.
# This makes the script work on immutable distributions such as
# Fedora Silverblue, Bazzite, or Vanilla OS.
#
# Usage:
#   ./install_user.sh              # Install
#   ./install_user.sh --uninstall  # Uninstall

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WALLPAPER_SRC="${SRC_DIR}/Dynamic_Wallpapers"
XML_SRC="${SRC_DIR}/xml"

WALLPAPER_DEST="${HOME}/.local/share/backgrounds/Dynamic_Wallpapers"
PROPS_DEST="${HOME}/.local/share/gnome-background-properties"

OLD_PREFIX="/usr/share/backgrounds/Dynamic_Wallpapers"
NEW_PREFIX="${HOME}/.local/share/backgrounds/Dynamic_Wallpapers"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

check_source() {
    if [[ ! -d "${WALLPAPER_SRC}" || ! -d "${XML_SRC}" ]]; then
        echo "Error: This script must be run from the Linux_Dynamic_Wallpapers directory." >&2
        echo "  Expected: ${WALLPAPER_SRC}" >&2
        exit 1
    fi
}

warn_if_mutable() {
    if touch /usr/share/.dw_write_test 2>/dev/null; then
        rm -f /usr/share/.dw_write_test
        echo "Note: /usr/share is writable on this system."
        echo "      For a system-wide installation (all users), you can use"
        echo "      install.sh with sudo instead."
        echo ""
    fi
}

# ---------------------------------------------------------------------------
# Uninstall
# ---------------------------------------------------------------------------

uninstall() {
    local removed=0

    if [[ -d "${WALLPAPER_DEST}" ]]; then
        rm -rf "${WALLPAPER_DEST}"
        echo "Removed: ${WALLPAPER_DEST}"
        removed=1
    fi

    # Only remove the picker XMLs that belong to this package
    if [[ -d "${PROPS_DEST}" ]]; then
        local count=0
        while IFS= read -r -d '' xml_file; do
            local name
            name="$(basename "${xml_file}")"
            local target="${PROPS_DEST}/${name}"
            if [[ -f "${target}" ]]; then
                rm -f "${target}"
                (( count++ ))
            fi
        done < <(find "${XML_SRC}" -maxdepth 1 -name "*.xml" -print0)

        if (( count > 0 )); then
            echo "Removed: ${count} picker XMLs from ${PROPS_DEST}"
            removed=1
        fi
    fi

    if (( removed == 0 )); then
        echo "Nothing to uninstall — no installation found."
    else
        echo "Uninstall complete."
    fi
}

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

install() {
    warn_if_mutable

    # Clean up any existing installation
    if [[ -d "${WALLPAPER_DEST}" ]]; then
        echo "Cleaning up existing installation..."
        rm -rf "${WALLPAPER_DEST}"
    fi

    echo "Installing wallpapers to ${WALLPAPER_DEST} ..."

    # Create target directories
    mkdir -p "${WALLPAPER_DEST}"
    mkdir -p "${PROPS_DEST}"

    # Copy image subdirectories (directories only, no .xml files)
    while IFS= read -r -d '' wallpaper_dir; do
        cp -r "${wallpaper_dir}" "${WALLPAPER_DEST}/"
    done < <(find "${WALLPAPER_SRC}" -mindepth 1 -maxdepth 1 -type d -print0)

    # Adjust and copy slideshow XMLs (Dynamic_Wallpapers/*.xml)
    local slideshow_count=0
    while IFS= read -r -d '' xml_file; do
        local name
        name="$(basename "${xml_file}")"
        sed "s|${OLD_PREFIX}|${NEW_PREFIX}|g" "${xml_file}" > "${WALLPAPER_DEST}/${name}"
        (( slideshow_count++ ))
    done < <(find "${WALLPAPER_SRC}" -maxdepth 1 -name "*.xml" -print0)

    # Adjust and copy picker XMLs (xml/*.xml)
    local props_count=0
    while IFS= read -r -d '' xml_file; do
        local name
        name="$(basename "${xml_file}")"
        sed "s|${OLD_PREFIX}|${NEW_PREFIX}|g" "${xml_file}" > "${PROPS_DEST}/${name}"
        (( props_count++ ))
    done < <(find "${XML_SRC}" -maxdepth 1 -name "*.xml" -print0)

    echo ""
    echo "Installation complete!"
    echo "  ${slideshow_count} slideshow XMLs installed (paths adjusted)"
    echo "  ${props_count} picker XMLs installed (paths adjusted)"
    echo ""
    echo "You can now select your wallpaper in GNOME Settings"
    echo "under 'Background'."
    echo ""
    echo "To uninstall: ./install_user.sh --uninstall"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

check_source

case "${1}" in
    --uninstall)
        uninstall
        ;;
    "")
        install
        ;;
    *)
        echo "Unknown option: ${1}" >&2
        echo "Usage: $0 [--uninstall]" >&2
        exit 1
        ;;
esac
