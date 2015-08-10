#!/bin/bash
# Simulator Controller
# Author: vish
set -e
. common.sh

usage() {
	echo "
	------------------------
	IOS SIMULATOR CONTROLLER
	------------------------
	Controls start, install and setup of simulators. Can also send test-media
	to the simulator.
	To be run from Mac OS X machine only. Requires ios-sim, Xcode,
	Xcode Commandline Tools (xcrun). Tested working on OS X 10.10.4.
	
	Notes:
	- Shutdown of iOS Sim not needed. Simply start a new sim.
	- Only one sim can be started at a time.
	


	USAGE
	$0 [OPTS]
	
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
	EXAMPLES
	Start iPhone 4S Simulator:
		$0 -d iPhone-4s -s 
		(OR)
		$0 -d com.apple.CoreSimulator.SimdeviceType.iPhone-4s
		
	Start iPhone 4S Simulator, Install Crunch.app to this simulator
		$0 -d iPhone-4s -s -i /path/to/Crunch.app

	Start iPhone 4S Simulator, Install Crunch.ipa to this simulator
		$0 -d iPhone-4s -s -i /path/to/Crunch.ipa
	"
}
######
# MAIN
# PARSE ARGS
######
SIM_ID=
TESTMEDIA=
APP_PATH=
while getopts "h?i:d:m:strlf" opt; do
    case "$opt" in
    h|\?)
        usage 
        exit 0
        ;;
    m)  TRANSFERMEDIA=true
    	TESTMEDIA="$OPTARG"
        ;;
    d)  SIM_ID="$OPTARG"
        ;;
    s)	START_SIM=true
    	;;
    l)	getSimulators
    	exit 0
    	;;
    r)	getSimulatorRuntime
    	exit 0
    	;;
    f)	GET_FRIENDLY_NAME=true
    	;;
    i)	INSTALL_APP=true
    	APP_PATH="$OPTARG"
    	;;
    *) 	usage
    	exit 0
    	;;    	
    esac
done



DEVICETYPEID=`xcrun simctl list devicetypes | ggrep -i "$SIM_ID)" | ggrep -oP "(?<=\().*(?=\))"`	
RUNTIME=`getSimulatorRuntime`


if [ "$GET_FRIENDLY_NAME" == true ]; then
	getFriendlyName $DEVICETYPEID
	exit 0
fi
echo "-- Selected Simulator: $DEVICETYPEID, Runtime $RUNTIME"


SIM_SERIAL=
if [ "$START_SIM" == true ]; then
	echo "-- Launching Simulator $DEVICETYPEID,$RUNTIME"
	set -x
	ios-sim start --devicetypeid "$DEVICETYPEID, $RUNTIME"
	SIM_SERIAL=`getBootedSimulatorSerial $DEVICETYPEID`
	set +x
fi

if [ "$INSTALL_APP" == true ]; then

	# is it a .APP or .IPA
	ext=`getExt $APP_PATH`
	if [[ "$ext" =~ "ipa" ]]; then
		echo "-- converting $APP_PATH to IPA"
		APP_PATH=`convertIPAtoApp "$APP_PATH"`
		echo "-- path to IPA: $APP_PATH"
	fi

	# get corresponding simulator ID 
	echo "-- Sim Serial Number: $SIM_SERIAL"
	echo "-- Freshly installing $APP_PATH on $SIM_ID"
	set -x
	installAppOnSimulator $SIM_SERIAL $APP_PATH
	set +x
fi

if [ "$TRANSFERMEDIA" == true ]; then
	sendMediaToSimulator "$TESTMEDIA" $SIM_SERIAL
fi

