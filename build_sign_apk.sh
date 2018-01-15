#!/bin/bash

# YOU MAY NEED TO MODIFY THIS SCRIPT TO REFLECT WHERE YOUR TOOLS ARE 
# LOCATED ON YOUR SYSTEM. USE THIS SCRIPT WITH CAUTION. I HAVE NOT 
# OPTIMIZED IT IN ANY WAY AND IT MAY HAVE ADVERSE AFFECTS.

###################################################################################
#TERMINOLOGY
#===========
#APK			Android Application Package (Zip File)
#DEX			Compiled Android Binary (Think of it like an Executable)
#MANIFEST		Contains Settings/Permissions/Details About The APK
#SMALI			Think of this as Assembly Language for Android Applications

#TOOLS
#=====
#APKTOOL		Disassembles/Builds APK Files
#d2j-apk-sign		Can Sign A Newly Built APK File
#d2j-dex2jar		Turns An APK Into A JAR
#jadx			Turns JAR file into Java Class Source Files
#adb			Android SDK Tool to install/uninstall APKs From Emulator
#Android Studio		IDE Environment to code Android Applications
#Smalidea		Plugin to debug native smali code
#FAKENET		Windows Application To Mimic Network Services. (Running on another VM)

#QUIRKS
#======
#Modify AndroidManifest.xml
#<application>...android:debuggable="true"</application>
###################################################################################

filename=$(echo $1 | cut -f 1 -d ".")

package=$(head $filename/AndroidManifest.xml | egrep -oh 'package=\"[A-Za-z\.0-9]*"\s' | cut -f 2 -d "\"")
echo $package
echo -e "\n\n\t1. Decompile APK and Generate Java Sources\n\t2. Build APK and Sign"

read choice

case $choice in
	1 ) 
	apktool d -f -o $filename/ $1
	apktool b -f -o $filename-unsigned.apk $filename/
	d2j-dex2jar -o $filename.jar $filename-unsigned.apk
	/root/Downloads/jadx/bin/jadx -d $filename/src/ $filename.jar
	;;
	
	2 ) 
	rm -f /root/Desktop/$filename-signed.apk
	/root/Android/Sdk/platform-tools/adb uninstall $package
	apktool b -f -o $filename-unsigned.apk $filename
	d2j-apk-sign -f -o $filename-signed.apk $filename-unsigned.apk
	/root/Android/Sdk/platform-tools/adb install $filename-signed.apk 
	;;
esac

rm -f /root/Desktop/$filename-unsigned.apk
rm -f /root/Desktop/$filename.jar
