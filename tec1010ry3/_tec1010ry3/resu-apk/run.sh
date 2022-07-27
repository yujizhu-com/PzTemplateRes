#!/bin/sh

source ~/.bash_profile
export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8
export PATH=$JAVA_TOOL_OPTIONS:$PATH
shFilePath=$(cd "$(dirname "$0")"; pwd)  			#sh文件路径即apk目录
basePath=$(cd $shFilePath; cd ..; pwd)   			#sh文件上级目录也就是源资源目录
codePath=$shFilePath"/code"							#解压后的code目录
assetsPath=$codePath"/assets"					#解压后的assets目录
keystorePath=$shFilePath"/daguan.keystore"          #签名文件的路径
echo 'shFilePath:'$shFilePath
echo 'basePath:'$basePath
echo 'codePath:'$codePath
echo 'assetsPath:'$assetsPath

# Debug
# set -x

#res拷贝
function ergodic(){
	local resDir="${assetsPath}/res/tec1010ry3"
	rm -rf $resDir
	mkdir $resDir

	# echo $1
	for file in ` ls $1`
	do
	    local path=$1"/"$file #得到文件的完整的目录
	    if [ -d $path ] #如果 file存在且是一个目录则为真
	    then
	    	if [ $file == "ccb" -o ${file:0:4} == "resu" ]; then
	    		echo 忽略拷贝目录$file
	    	else
	    		echo 拷贝目录$file
	    		`cp -rf $path $resDir `
	    	fi  
	    else
	    	echo 拷贝文件$file
	    	`cp -f $path $resDir `
	   fi
	done

	#清理不需要的文件
	find $resDir -type f -name "*.js" -o -name "*.pes" -o -name "*.tps" -o -name "*.GlyphProject" -o -name "*.pdf"  -o -name "*.sh" | xargs rm -rf;
}

echo '------------------开始解压apk包------------------'
cd $shFilePath
needUnZipApk=false
ApkVersion_servers=`cat apkversion_servers.txt`
if [[ ! -e "./apkversion_my.txt" ]]; then
	needUnZipApk=true;
else
	ApkVersion_my=`cat apkversion_my.txt`
	if [[ $ApkVersion_my != $ApkVersion_servers ]]; then
		needUnZipApk=true;
	fi
fi
if [[ $needUnZipApk = true ]]; then
	cat apkversion_servers.txt > apkversion_my.txt
	rm -rf $codePath
	apktool2 d ./*.apk -o ./code
else
	echo '------------------apk无更新，不需要解压------------------'
fi
echo '------------------结束解压apk包------------------'


echo '------------------开始删除一些res下的东西------------------'
# sed  -i -e  '/LockScreen/d'  $codePath/res/values-v24/styles.xml
# sed  -i -e '/OptionsPanel/d'  $codePath/res/values-v24/styles.xml
# rm -rf $codePath/res/values-v24/styles.xml-e
echo '------------------结束删除一些res下的东西------------------'




echo '------------------开始替换资源文件------------------'
ergodic $basePath  
echo '------------------结束替换资源文件------------------'
#apktool2 b 生成apk
echo '------------------开始生成未签名的nosign.apk------------------'
cd $codePath
apktool2 b ./ -o ./dist/nosign.apk
echo '------------------结束生成未签名的nosign.apk------------------'
#签名
echo '------------------开始给apk签名------------------'
signFrom=$codePath"/dist/nosign.apk"
signTo=$codePath"/dist/sign.apk"
# /usr/bin/jarsigner -verbose -keystore $keystorePath -signedjar $signTo $signFrom daguan.keystore -digestalg SHA1 -sigalg MD5withRSA
/usr/bin/expect $shFilePath"/sign.sh" $keystorePath $signTo $signFrom
echo '------------------结束给apk签名------------------'
echo '------------------开始给apk对齐------------------'
okApk=$codePath"/dist/ok.apk"
zipalign -f -v 4 $signTo $okApk
echo '------------------结束给apk对齐------------------'
echo '------------------开始安装apk------------------'
adb install -r $okApk
echo '------------------结束安装apk------------------'
