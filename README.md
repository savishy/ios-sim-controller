# ios-sim-controller
Controller for iOS Simulator.

# Introduction

This is a controller for the iOS Simulator. It controls start, install and setup of simulators. Can also send test-media from an entire folder to the simulator.

I wrote this tool primarily for use in an Appium-based iOS test-automation framework. 

Tested working with 
*  OS X 10.10.4 Yosemite
* iPhone Simulators with runtime version 8.3, 8.4
* Xcode 6.3

## Prerequisites
* ios-sim (https://github.com/phonegap/ios-sim)
* Xcode + Command-line tools (xcrun)

##	Notes
* Only one simulator can be started at a time; this is as per the iOS Simulator design.
* Shutdown of a simulator is not needed; starting a new simulator replaces the previously-running simulator session.
	
# Usage
```
./simulator.sh [OPTS]
	
	When run with no options, simply prints out the Simulator device-types on your system.
	
	OPTS
	-d [DEVICE_TYPE_ID] : Specify DEVICE_TYPE_ID of simulator.
		This can either be the fully-qualified ID e.g.
		com.apple.CoreSimulator.SimDeviceType.iPhone-4s
		or just the device name e.g iPhone-4s
		
	-s : If flag is set, start the simulator specified by -d

	-i [APP] : Install APP to Simulator selected by -d. 
			APP should be the full path to a .app file or .ipa file to be installed.
			(If you specify .IPA it is converted to .APP before install)
			
	-m [TESTMEDIA] : Send contents of TESTMEDIA folder to started simulator
	
	-l : list all Device Type IDs on system and exit
	
	-r : list the available runtime on system, and exit.
	
	-f : Given a fully-qualified device-type ID e.g.
			com.apple.CoreSimulator.SimDeviceType.iPhone-4s
		 This gets you the Appium-Friendly form of the same simulator.
		 	iPhone 4s

```

# Examples
```
	Start iPhone 4S Simulator:
		$0 -d iPhone-4s -s 
		(OR)
		$0 -d com.apple.CoreSimulator.SimdeviceType.iPhone-4s
		
	Start iPhone 4S Simulator, Install Crunch.app to this simulator
		$0 -d iPhone-4s -s -i /path/to/Crunch.app

	Start iPhone 4S Simulator, Install Crunch.ipa to this simulator
		$0 -d iPhone-4s -s -i /path/to/Crunch.ipa
	"

```
