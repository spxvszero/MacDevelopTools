

workPath=''
workspace=''
scheme=''
outputPath='outPut'
configuration=''
archiveInfoPlist=''
isFramework=false


while getopts p:o:w:s:i:hdfr OPTION
do
    case $OPTION in
        o)                       
            outputPath=$OPTARG
            ;;
        r)
            configuration='Release'
            ;;
        d)
            configuration='Debug'
            ;;
        p)
			workPath=$OPTARG
            ;;
        w) 
			workspace=$OPTARG
			;;
		s)
			scheme=$OPTARG
			;;
		i)
			archiveInfoPlist=$OPTARG
			;;
		f)
			isFramework=true
			;;
        h)
			echo 'help :'
			echo '-o  outputPath'
			echo '-r  Release configuration'
			echo '-d  Debug configuration'
			echo '-p  projectPath'
			echo '-w  workspace'
			echo '-s  scheme'
			echo '-i  archive info plist'
			echo '-f  build for framework'
			echo '-h  help'
			exit 0
			;;
        *)                       
            echo "error params $OPTARG"
            exit 0
            ;;
    esac
done

function ipa(){
if [[ ! -e $workPath/$workspace ]]; then
	#statements
	echo "error ! workspace not found"
	exit
fi

if [[ -z $scheme ]]; then
	#statements
	echo "error ! need scheme"
	exit
fi

if [[ ! -e $archiveInfoPlist ]]; then
	#statements
	echo "error ! need archive info plist"
	exit
fi


if [[ -z $configuration ]]; then
	#statements
	echo "error configuration need params -r(Release)/-d(Debug)"
	exit
fi

if [[ ! -e $outputPath ]]; then
	#statements
	echo "output path does not exist ! auto create"
	mkdir $outputPath
fi

archiveFile="${outputPath}/archive"
#change ruby env
rvm use system
#build xcarchive
xcodebuild -workspace ${workPath}/${workspace} -scheme ${scheme} -configuration ${configuration} -archivePath ${archiveFile} archive
#archive
xcodebuild -exportArchive -archivePath ${archiveFile}.xcarchive -exportPath ${outputPath} -exportOptionsPlist ${archiveInfoPlist}

}

function framework(){
	if [[ ! -e $workPath/$workspace ]]; then
	#statements
	echo "error ! workspace not found"
	exit
	fi

	if [[ -z $scheme ]]; then
		#statements
		echo "error ! need scheme"
		exit
	fi

if [[ -z $configuration ]]; then
	#statements
	echo "error configuration need params -r(Release)/-d(Debug)"
	exit
fi

if [[ ! -e $outputPath ]]; then
	#statements
	echo "output path does not exist ! auto create"
	mkdir $outputPath
fi

currentPath=`pwd`
debug='Debug'
release='Release'
iphone='iphoneos'
simulator='iphonesimulator'

buildDir=`xcodebuild -workspace ${workPath}/${workspace} -scheme ${scheme} -showBuildSettings | grep '^[ ]*BUILT_PRODUCTS_DIR' | sed 's|.* = \(/.*\)/.*[^/]|\1|'`

#wail show log
echo "#################### build iphone #################"
sleep 1
#build iphone
xcodebuild -workspace ${workPath}/${workspace} -scheme ${scheme} -configuration ${configuration} -sdk ${iphone} clean build
#wail show log
echo "#################### build simulator #################"
sleep 1
#build simulator
xcodebuild -workspace ${workPath}/${workspace} -scheme ${scheme} -configuration ${configuration} -sdk ${simulator} clean build

#lipo framework
path="${buildDir}/${configuration}-${iphone}/${scheme}.framework"

if [[ ! -e $path ]]; then
	echo 'error : framework file not found'
	exit 0
fi

echo "#################### lipo #################"
sleep 1
if [[ ! -e ${outputPath}/${scheme}.framework ]]; then
	#statements
	mkdir ${outputPath}/${scheme}.framework
fi

lipo -create ${buildDir}/${configuration}-${iphone}/${scheme}.framework/${scheme} ${buildDir}/${configuration}-${simulator}/${scheme}.framework/${scheme} -output ${outputPath}/${scheme}.framework/${scheme}

#copy header
cp -rf ${buildDir}/${configuration}-${iphone}/${scheme}.framework/Headers ${outputPath}/${scheme}.framework

open ${outputPath}


}

if ${isFramework} ; then
	#statements
	echo 'building framework'
	sleep 2
	framework
else
	echo 'building ipa'
	sleep 2
	ipa
fi


