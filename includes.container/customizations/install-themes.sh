#!/bin/bash
set -e
mkdir -p /deb-pkgs/.themerepo
cd /deb-pkgs/.themerepo

git clone https://github.com/yeyushengfan258/Win11-icon-theme.git icons
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git theme
git clone https://github.com/peanutsguy/segoe-ui-linux font

cd icons
./install.sh
cd ..

cd theme
./install.sh
cd ..

cd font
./install.sh
cd ..
