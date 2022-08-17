#!/bin/bash

# Designed to use with Git Bash, not WSL!!! (https://gitforwindows.org/)

MODS_ROOT="/c/Program Files (x86)/Steam/steamapps/common/HatinTime/HatinTimeGame/Mods"

cd `dirname $0`
echo "Working dir: `pwd`"

export PATH=$PATH:`dirname $0`/RepoTools

rm -rf "mcu8_mods_BH" "mcu8_maps_SpaceshipEx"

echo "Copying HubSwapper files..."
cp -r "$MODS_ROOT/mcu8_mods_BH" "mcu8_mods_BH"

echo "Copying SpaceshipEX files..."
cp -r "$MODS_ROOT/mcu8_maps_SpaceshipEx" "mcu8_maps_SpaceshipEx"


echo "Removing CookedPC..."
rm -rf mcu8_*/CookedPC

echo "Removing CompiledScripts..."
rm -rf mcu8_*/CompiledScripts

echo "Removing Shadercache..."
rm -rf mcu8_*/Shadercache

echo "Packing release archives..."

mkdir -p Releases

rm Releases/mcu8_*.zip
zip.exe -r Releases/mcu8_mods_BH.zip mcu8_mods_BH/*
zip.exe -r Releases/mcu8_maps_SpaceshipEx.zip mcu8_maps_SpaceshipEx/*
zip.exe -r Releases/Examples.zip Examples/*

echo "OK!"
git add --all && git status && git commit
