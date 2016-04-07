set -e
#####
# This script contains common Functionality
# Include this in a script as . common.sh
# Then call any method as if it were in that script.
#####

####
# get a list of all simulator "devicetypes" on your system.
####
getSimulators() {
	deviceTypes=`ios-sim showdevicetypes | awk -F, '{print $1}'`
	for i in $deviceTypes; do
		echo "com.apple.CoreSimulator.SimDeviceType.$i"
	done
}

#####
# For a booted simulator, get its Simulator Serial Number
# which is used by many xcrun simctl commands.
#####
getBootedSimulatorSerial() {
	SIM_SERIAL=`xcrun simctl list devices | ggrep -i "booted" | ggrep -oP "(?<=\()[0-9A-F-]+(?=\))"`
	[[ "$SIM_SERIAL" == "" ]] && { echo "no serial number found for simulator $1."; exit 1; }
	echo "$SIM_SERIAL"
}


###
# Get extension of file
# arg: a full path or just the filename
###

getExt() {
	fullfile=$(basename "$1")
	extension="${fullfile##*.}"
	echo $extension
}


getFilename() {
	fullfile=$(basename "$1")
	filename="${fullfile%.*}"
	echo $filename
}

####
# Convert an IPA to APP file.
# return the location of the APP file. (tmpdir)
####
convertIPAtoApp() {
	# get filename and extension of IPA file

	extension=`getExt $1`
	filename=`getFilename $1`
# 	fullfile=$(basename "$1")
# 	extension="${fullfile##*.}"
# 	filename="${fullfile%.*}"

	if [[ "$extension" == "app" ]]; then
		echo "$fullfile is already a .app file" && return;
	fi

	if [[ ! "$extension" =~ "ipa" ]]; then
		echo "$extension is invalid; need an IPA file" && return;
	fi
	
	cp $1 $TMPDIR/${filename}.zip
	
	# clean up past attempts
	if [ -e "$TMPDIR/${filename}/Payload/Crunch.app" ]; then
		rm -rf $TMPDIR/${filename} > /dev/null
	fi

	unzip $TMPDIR/${filename}.zip -d $TMPDIR/${filename} > /dev/null
	
	if [ ! -e "$TMPDIR/${filename}/Payload/Crunch.app" ]; then
		echo "could not find $TMPDIR/${filename}/Payload/Crunch.app" && return;
	else
		echo $TMPDIR/${filename}/Payload/Crunch.app
	fi
		
}

##### 
# Install App to Simulator
# 1st arg: Simulator Serial No
# 2nd arg: the path to the .app file to install
#####
installAppOnSimulator() {
	xcrun simctl install $1 $2
}

####
# Get the simulator runtime OS on the system.
####
getSimulatorRuntime() {
	RUNTIME=`xcrun simctl list runtimes | ggrep -i ios | awk '{print $2}'`
	echo -n $RUNTIME
}


###
# Transfer all media from a folder to a running simulator.
# 1: path to folder containing media
# 2: simulator serial no
###
sendMediaToSimulator() {
	for i in `ls $1`; do
		set -x
		xcrun simctl addphoto $2 "$1/$i"
		set +x
	done
}

###
# Given fully-qualified ID, return the appium-friendly name
# as in instruments -s devices
# e.g. given argument com.apple.CoreSimulator.SimDeviceType.iPhone-6
# returns "iPhone 6"
###
getFriendlyName() {
	deviceName=`xcrun simctl list devicetypes | ggrep -oP ".*(?=\s\($1\))"`
	#instruments -s devices | ggrep "$deviceName\s("
	echo -n $deviceName
}
