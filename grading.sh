# Joshua Hull (jhull@clemson.edu)

ASSIGNMENT=$1
WORKING=~/Desktop/grading
BAD=()

cd cpsc4820-003/assignments/A${ASSIGNMENT}

STUDENTS=`ls -d */ | sed 's#/##'`

xcpretty --version > /dev/null
if [ $? -ne 0 ]; then
	exit 1
fi

for STUDENT in $STUDENTS; do
	mkdir -p $WORKING/$STUDENT
	if [[ -f $STUDENT/$STUDENT.a$ASSIGNMENT.zip ]]; then
		unzip -q $STUDENT/$STUDENT.a$ASSIGNMENT.zip -d $WORKING/$STUDENT
	elif [[ -f $STUDENT/$STUDENT.a$ASSIGNMENT.tar ]]; then
		tar xf $STUDENT/$STUDENT.a$ASSIGNMENT.tar --directory $WORKING/$STUDENT
	else
		echo Didn\'t Find Any Archive for $STUDENT
		BAD+=($STUDENT)
	fi
done

cd $WORKING

for STUDENT in $STUDENTS; do
	cd $STUDENT
	if [[ " ${BAD[*]} " == *" $STUDENT "* ]]; then
    	cd ../
    	continue
	fi
	GOOD=`ls | grep xcodeproj | wc -l`
	if [[ $GOOD -eq '1' ]]; then
		echo \\nBuilding $STUDENT\\n
		xcodebuild -configuration Debug -sdk iphonesimulator7.1 | xcpretty
		cp -r build/Debug-iphonesimulator/*.app .
		if [[ ${PIPESTATUS[0]} -ne '0' ]]; then
			echo \\n\\nBUILD ERROR\\n\\n
		else
			IOSSIM=`ios-sim --version`
			if [ $? -ne 0 ]; then
				open *.xcodeproj
			fi
			IOSSIMVERSION=(`echo $IOSSIM | tr '.' ' '`)
			if [[ $IOSSIMVERSION[0] -lt '3' ]]; then
				open *.xcodeproj
			else
				ios-sim launch *.app --exit --timeout 120 --devicetypeid "com.apple.CoreSimulator.SimDeviceType.iPhone-5 7.1"
			fi
		fi
		echo \\n
	else
		echo \\nBad file structure for $STUDENT\\n
	fi
	cd ../
done