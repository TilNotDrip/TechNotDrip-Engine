# Building TechNotDrip Engine

## Platforms:
* [Windows](#Windows)
* [Android](#Android)

## Windows:
### Prerequisites:
1. [Haxe](https://haxe.org/) installed
2. [Git](https://git-scm.com/) installed
3. Visual Studio Build Tools (C++ workload)
4. Windows SDK installed

### Steps:
1. Setup Haxelib (if not already setup) by running `haxelib setup`
2. Install required tooling. Run the following:
	- `haxelib git haxelib https://github.com/FunkinCrew/haxelib.git funkin-patches`
	- `haxelib git hmm https://github.com/FunkinCrew/hmm funkin-patches`
3. Install project dependencies. Run these inside the project root which should contain `hmm.json`
	- `cd <project-root>`
	- `haxelib run hmm install -q`
4. Build hxcpp tools (one-time per machine)
	- Find the active haxelib repository path by running `haxelib config`
	- Go to the `hxcpp` folder by running `cd <haxelib-config-path>\hxcpp\git\tools\hxcpp`
	- Now that you're in the right folder, run `haxe compile.hxml`
5. We can now finally build the project
	- Return to the project root by running `cd <project-root>`
	- Finally, you can build the engine by running `haxelib run lime build windows`

## Android:
1. Install Android Studio from [developer.android.com](https://developer.android.com/studio)
2. Install Java 17 from [oracle.com](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
	- NOTE: Write down the install location, we will need it later.
3. Open Android Studio.
4. Click on Projects.
5. At the very right of the window, there should be three dots. Click on them.
6. Select SDK Manager from the dropdown.
	- NOTE: This will show the Android SDK location. Write it down, as we will need it later.
7. Select the following:
	- SDK Platforms:
		- Android 10.0 ("Q")
	- SDK Tools
		- NOTE: Make sure to select show package details. That way you can download the exact version.
		- Android SDK Build-Tools
			- 32.0.0
		- NDK (Side by Side)
			- 21.4.7075529
8. Apply and wait for it to download.
9. Run `lime setup android` in command prompt.
	- NOTE: This is where we use the locations from earlier. Replace [SDK_LOCATION] with the SDK location, and replace [JAVA_LOCATION] with the Java location.
10. Put as following:
	- Absolute path to Android SDK: [SDK_LOCATION]
	- Absolute path to Android NDK: [SDK_LOCATION]/ndk/21.4.7075529
	- Absolute path to Java JDK: [JAVA_LOCATION]
11. You can now compile to Android!
	- NOTE: Run and Debug from Visual Studio Code doesn't support Android Debugging, so you will need to compile from the command itself.
	- The command is `lime build android`.
