#!/bin/bash
WALLPAPER_DEST="/usr/share/backgrounds/Dynamic_Wallpapers"
XML_DEST="/usr/share/gnome-background-properties/"
GIT_URL="https://github.com/saint-13/Linux_Dynamic_Wallpapers.git"

# Check dependencies
for cmd in git whiptail; do
	command -v "$cmd" >/dev/null 2>&1 || {
		echo "❌ '$cmd' is required but not installed, exiting..."
		exit 1
	}
done

# Clone .git folder into a temporary directory -> Lightweight checkout
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
REPO_GIT="$TMP_DIR/Linux_Dynamic_Wallpapers/.git"
git clone --filter=blob:none --no-checkout "$GIT_URL" "$TMP_DIR/Linux_Dynamic_Wallpapers" || {
	echo "❌ Failed to clone $GIT_URL, exiting..."
	exit 1
}

# List files in repo and create array of available wallpapers
wallpaper_list="$(git --git-dir "$REPO_GIT" ls-tree --name-only HEAD xml/ | \
	sed -e 's#^xml/##' -e 's/\.xml$//' -e 's/$/,,OFF/' | \
	tr "\n" "," \
)"
IFS=',' read -r -a choiceArray <<< "$wallpaper_list"

# $LINES and $COLUMNS are not set in non-interactive shells
LINES=$(tput lines 2>/dev/null || echo 24)
COLUMNS=$(tput cols 2>/dev/null || echo 80)

# Display interactive list to user (one selected item per line)
user_selection=$(whiptail --title "Select wallpapers to install" --separate-output --checklist \
	"Wallpapers:" "$LINES" "$COLUMNS" $(( LINES - 8 )) \
	"${choiceArray[@]}" \
	3>&1 1>&2 2>&3)

echo "-----------------"
echo " ✔️ Selection: "
echo "-----------------"
[[ -z "$user_selection" ]] && {
	echo "❌ No selection, exiting..."
	exit 1
} || {
	echo "$user_selection"
}

# Create directories
echo "-----------------"
echo " ⚙️ Configuration"
echo "-----------------"
echo "- Wallpapers destination: $WALLPAPER_DEST"
echo "- XML slideshows destination: $XML_DEST"
sudo mkdir -p "$WALLPAPER_DEST"
echo "✅ Created $WALLPAPER_DEST"
sudo mkdir -p "$XML_DEST"
echo "✅ Created $XML_DEST"

echo "-------------------------"
echo " 🚀 Installing wallpapers"
echo "-------------------------"
while IFS= read -r name; do
	echo "- Installing $name"

	# List jpeg files to install
	list_to_install=$(git --git-dir "$REPO_GIT" ls-tree --name-only HEAD "Dynamic_Wallpapers/$name/" | \
		sed -e 's#^.*/##')

	# Install jpeg files
	sudo mkdir -p "$WALLPAPER_DEST/$name"
	while IFS= read -r file; do
		echo " Downloading Dynamic_Wallpapers/$name/$file"
		git --no-pager --git-dir "$REPO_GIT" show "HEAD:Dynamic_Wallpapers/$name/$file" | \
			sudo tee "$WALLPAPER_DEST/$name/$file" >/dev/null
	done <<< "$list_to_install"

	# Install xml
	echo " Downloading Dynamic_Wallpapers/$name.xml"
	git --no-pager --git-dir "$REPO_GIT" show "HEAD:Dynamic_Wallpapers/$name.xml" | \
		sudo tee "$WALLPAPER_DEST/$name.xml" >/dev/null

	# Install slideshow xml
	echo " Downloading xml/$name.xml"
	git --no-pager --git-dir "$REPO_GIT" show "HEAD:xml/$name.xml" | \
		sudo tee "$XML_DEST/$name.xml" >/dev/null
done <<< "$user_selection"

echo
echo "Success !"
echo "💜 Please support on https://github.com/saint-13/Linux_Dynamic_Wallpapers"
