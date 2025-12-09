#!/bin/bash
set -e
array=( https://extensions.gnome.org/extension/4655/date-menu-formatter/ )

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    mkdir -p /usr/share/gnome-shell/extensions/${EXTENSION_ID}
    unzip -o ${EXTENSION_ID}.zip -d /usr/share/gnome-shell/extensions/${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done
