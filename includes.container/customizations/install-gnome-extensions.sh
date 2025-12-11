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
    PK=$(basename "$(dirname "$i")")
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-info?pk=$PK" \
        | jq -r --arg pk "$PK" '.shell_version_map | map(.pk) | max')
    echo "Downloading $EXTENSION_ID version $VERSION_TAG with PK $PK"
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    # Install as a system GNOME extension (/usr/share/gnome-shell/extensions)
    SYS_EXT_DIR="/usr/share/gnome-shell/extensions"
    mkdir -p "$SYS_EXT_DIR"
    tmpdir=$(mktemp -d)

    if command -v unzip >/dev/null 2>&1; then
        unzip -q "${EXTENSION_ID}.zip" -d "$tmpdir"
    elif command -v bsdtar >/dev/null 2>&1; then
        bsdtar -xf "${EXTENSION_ID}.zip" -C "$tmpdir"
    else
        echo "neither unzip nor bsdtar found; cannot unpack ${EXTENSION_ID}.zip" >&2
        rm -rf "$tmpdir"
        continue
    fi

    # locate directory that contains metadata.json (the extension root)
    extdir=$(find "$tmpdir" -type f -name metadata.json -printf '%h\n' | head -n1)
    if [ -n "$extdir" ]; then
        dest="$SYS_EXT_DIR/${EXTENSION_ID}"
        # remove any existing installation and move the new one in place (running as root)
        rm -rf "$dest"
        mv "$extdir" "$dest"
        chown -R root:root "$dest"
        chmod -R a+rX "$dest"
        # compile system-wide gsettings schemas so gschemas.compiled exists
        if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
            glib-compile-schemas /usr/share/glib-2.0/schemas || true
        fi
    else
        # fallback: move everything into the system extensions dir
        mv "$tmpdir"/* "$SYS_EXT_DIR"/ 2>/dev/null || true
        chown -R root:root "$SYS_EXT_DIR"
        chmod -R a+rX "$SYS_EXT_DIR"
        if command -v glib-compile-schemas >/dev/null 2>&1 && [ -d /usr/share/glib-2.0/schemas ]; then
            glib-compile-schemas /usr/share/glib-2.0/schemas || true
        fi
    fi

    rm -rf "$tmpdir"
    echo "Installed ${EXTENSION_ID} to $SYS_EXT_DIR (system-wide)"
    # gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done
