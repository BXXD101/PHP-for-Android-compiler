# PHP-for-Android-compiler
This script will cross compile the latest PHP as single file to Android for aarch64. Make sure to have git and wget installed in your Linux distro. 

Just run ./compileandroid.sh and all will be done for you. 

After the build is finished you can find the php binary in the dir where you ran the script. 

This PHP wont work with PocketMine-MP since it requires additional libs. These will be added to the script soon.

# How can i run the generated PHP on my Android device?
You will need ADB installed on your computer. You can get it from: https://dl.google.com/android/repository/platform-tools-latest-windows.zip
Extract the zip file and then open CMD and cd to the directory where adb.exe is located.
run adb start-server then push php to /data/local/tmp using adb push pathtophpfile /data/local/tmp.
Now run adb shell and do cd /data/local/tmp. Make php executable by doing chmod +x php and run ./php --version

Enjoy.

# Important
The generated PHP only works for Android devices with aarch64. The binary does not work on other archs.
