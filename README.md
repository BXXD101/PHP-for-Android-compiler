# PHP-for-Android-compiler
Cross compile the latest PHP as single file to Android for aarch64 or x86_64. Make sure to have git and wget installed in your Linux distro. 
Supported targets: aarch64-linux, x86_64-linux

Building for aarch64: ./compileandroid.sh aarch64-linux
Building for x86_64: ./compileandroid.sh x86_64

After the build is finished you can find the php binary in the dir where you ran the script. 

This PHP wont work with PocketMine-MP since it requires additional libs. These will be added to the script soon.


# How can i run the generated PHP on my Android device?
You will need ADB installed on your computer. You can get it from: https://dl.google.com/android/repository/platform-tools-latest-windows.zip
Extract the zip file and then open CMD and cd to the directory where adb.exe is located.
run adb start-server then push php to /data/local/tmp using adb push pathtophpfile /data/local/tmp.
Now run adb shell and do cd /data/local/tmp. Make php executable by doing chmod +x php and run ./php --version

Enjoy.

# Important
Only aarch64-linux, x86_64-linux are supported yet. More will be added later. You can of course extend the script.
