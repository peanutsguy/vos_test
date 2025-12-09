#!/bin/bash
set -e
array=( https://extensions.gnome.org/extension/615/appindicator-support/
https://extensions.gnome.org/extension/4655/date-menu-formatter/
https://extensions.gnome.org/extension/3628/arcmenu/
https://extensions.gnome.org/extension/3193/blur-my-shell/
https://extensions.gnome.org/extension/1160/dash-to-panel/
https://extensions.gnome.org/extension/19/user-themes/)

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    EXTENSION_URL=$(curl -s $i | grep -oP '(?<=id="extension_url">)[^<]+')
    EXTENSION_REPO=$(echo $EXTENSION_URL | sed 's/https:\/\/github.com\///')
    EXTENSION_VERSION=$(curl -s https://api.github.com/repos/$EXTENSION_REPO/releases/latest | jq -r .tag_name)
    wget "https://github.com/$EXTENSION_REPO/releases/download/$EXTENSION_VERSION/$EXTENSION_ID.zip" -O "$EXTENSION_ID.zip"
    gnome-extensions install --force ${EXTENSION_ID}.zip
    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done
