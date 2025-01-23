#!/bin/bash
WALPAPER_DEST="/usr/share/backgrounds/Dynamic_Wallpapers"
XML_DEST="/usr/share/gnome-background-properties/"
GIT_URL="https://github.com/saint-13/Linux_Dynamic_Wallpapers.git/"

# clean the remaining git directory on pwd on exit
trap 'rm -rf "$PWD/Linux_Dynamic_Wallpapers"' EXIT

# Clone .git folder -> Lightweigh checkout
git clone --filter=blob:none --no-checkout "$GIT_URL"

# List files in repo and create array of available walpapers
walpaper_list="$(git --git-dir Linux_Dynamic_Wallpapers/.git ls-tree --full-name --name-only -r HEAD | \
	grep xml/ | \
	sed -e 's/^xml\///' | \
	sed -e 's/.xml//' | \
	sed -e 's/$/,,OFF/' | \
	tr "\n" "," \
)"
IFS=',' read -r -a choiceArray <<< "$walpaper_list"

# Display interactive list to user
user_selection=$(whiptail --title "Select walpapers to install" --checklist \
	"Walpapers:" $LINES $COLUMNS $(( $LINES - 8 )) \
	"${choiceArray[@]}" \
	3>&1 1>&2 2>&3 | sed -e 's/" "/"\n"/')

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
echo "- Walpapers destionation: $WALPAPER_DEST"
echo "- XML slideshows destination: $XML_DEST"
sudo mkdir -p "$WALPAPER_DEST"
echo "✅ Created $WALPAPER_DEST"
sudo mkdir -p "$XML_DEST"
echo "✅ Created $XML_DEST"

echo "-------------------------"
echo " 🚀 Installing walpapers"
echo "-------------------------"
while IFS= read -r to_install; do
	# Delete quotes in name
	name=$(echo "$to_install" | tr -d '"')
	echo "- Installing $name"

	# List jpeg files to install
	list_to_install=$(git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:Dynamic_Wallpapers/$name" | \
		tail -n +3)

	# Install jpeg files
	while IFS= read -r file; do
		echo " Downloading Dynamic_Wallpapers/$name/$file"
		sudo mkdir -p "$WALPAPER_DEST/$name"
		git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:Dynamic_Wallpapers/$name/$file" | \
			sudo tee "$WALPAPER_DEST/$name/$file" >/dev/null
	done <<< "$list_to_install"

	# Install xml
	echo " Downloading Dynamic_Wallpapers/$name.xml"
	git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:Dynamic_Wallpapers/$name.xml" | \
		sudo tee "$WALPAPER_DEST/$name.xml" >/dev/null

	# Install slideshow xml
	echo " Downloading xml/$name.xml"
	git --no-pager --git-dir Linux_Dynamic_Wallpapers/.git show "main:xml/$name.xml" | \
		sudo tee "$XML_DEST/$name.xml" >/dev/null
done <<< "$user_selection"

echo

echo "Success !"
echo "💜 Please support on https://github.com/saint-13/Linux_Dynamic_Wallpapers"
