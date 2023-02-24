
resourceDir=''
outputDir='res'

while getopts a:r:o:h ops
do
	case ${ops} in
		a)
			IFS=',' read -r -a specifyExtensionArr <<< "${OPTARG}"
			;;
		o)
			outputDir=${OPTARG}
			;;
		r)
			resourceDir=${OPTARG}
			;;
		h)
			echo "help : "
			echo "-a specify file extension like jpg,png"
			echo "-r resource dir path"
			echo "-o output dir path"
			echo "-h help"
			exit
			;;
		*)
			echo "unknow params"
			exit
			;;
	esac

done

if [[ ! -e $resourceDir ]]; then
	echo "error ! resource dir not found"
	exit
fi

if [[ ! -e $outputDir ]]; then
	mkdir $outputDir
fi


function check_extension(){
	if [[ ${#specifyExtensionArr[@]} -le 0 ]]; then
		echo 1
		exit
	fi

	for element in "${specifyExtensionArr[@]}"
	do
    	if [[ ${element} == ${1##*.} ]]; then
    		echo 1
    		exit
    	fi
	done

	echo 0
	exit
}

checkFileExistTempPath=''
function check_file_exist(){

	if [[ -e $2 ]]; then
    	local originDirPath=`dirname $1`
    	local originDirName=`basename ${originDirPath}`
    	local desDirName=`dirname $2`
    	local fileName=`basename $1`

    	check_file_exist $1 ${desDirName}/${originDirName}_${fileName}
   	else
    	checkFileExistTempPath=$2
   	fi
}

function move_file(){
for file in $1/*
do
	echo $file
    if [[ -f ${file} ]]
    then
    	local res=$(check_extension ${file})
    	if [[ ${res} -eq 0 ]]; then
    		echo "jump because specify extension"
    		continue
    	fi

    	local desFilePath=$2/`basename ${file}`
    	check_file_exist ${file} ${desFilePath}
    	mv ${file} ${checkFileExistTempPath}
    else
    	local fileDir
    	fileDir=${file}
        move_file ${file} $2
        echo "rm : ${fileDir}"
        if [[ -e $fileDir ]]; then
        	rm -rf ${fileDir}
        else
        	echo "Error : ${fileDir} not exist"
        fi
    fi
done
}

read -p "(y/n)" ready

if [[ $ready != 'y' ]]; then
	#statements
	echo "exit"
	exit
fi

cp -rf $resourceDir $outputDir
move_file $outputDir $outputDir
if [[ -f $file ]]; then
	open $outputDir/..
else
	open $outputDir
fi

