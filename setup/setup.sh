cd ..
haxelib --global install hxpkg
haxelib --global run hxpkg setup
hxpkg install --force
read -n 1 -p -s "Press any key to continue..."