#!/bin/bash
IFS=$(echo -ne "\n\b")
export DOWNFILE=${3}
#-------------------------------------------------------------------
#<程序基本運行函數>
INI_MKDIR(){
	if [[ ! -d $1 ]]
	then
		mkdir -p $1
	fi
}
SET_BASIC_ENV_VAR(){
	export UNZIP_THREAD=5
	export APP_BIN=${SHELL_BOX_PATH}/bin/
	export PATH=${PATH}:${APP_BIN}
	export SHELL_BIN=${SHELL_BOX_PATH}/bin/sh/
	export PASSWD_FILE=${SHELL_BOX_PATH}/conf/passwd.conf
	export TEMP_PATH=${SHELL_BOX_PATH}/temp
	export TEMP_UNZIP_PATH=${SHELL_BOX_PATH}/temp/unzip/
	export INPUT_DIR=${TEMP_UNZIP_PATH}
	export RCLONE="${SHELL_BOX_PATH}/conf/rclone.conf"
	INI_MKDIR ${SHELL_BIN%\/*}
	INI_MKDIR ${TEMP_UNZIP_PATH}
	chmod -R a+rwx ${SHELL_BOX_PATH}
	export PASSWD=($(cat ${PASSWD_FILE}))
}
VIDEO_DOWNLOAD_CHECK(){
	if [[ ${DOWNFILE##*.} == "m3u8" ]]
	then
		export ORG_URL=$(cat /root/.aria2c/aria2.session|grep "${DOWNFILE}"|head -1)
	fi
}
#-------------------------------------------------------------------
#<Main_Program_Body>
#<程序運行-环境参数>
	VIDEO_DOWNLOAD_CHECK
	SHELL_BOX_PATH=$(readlink -f ${0})
	export SHELL_BOX_PATH=${SHELL_BOX_PATH%\/*}
	SET_BASIC_ENV_VAR
#-----------------------------------------------------------------------
	[[ ! -z ${ORG_URL} ]] && source ${SHELL_BIN}m3u8_rc.sh || source ${SHELL_BIN}auto_unzip.sh
#-----------------------------------------------------------------------
find /home/ -type f -name *.aria2 -delete
IFS=$OLD_IFS
exit 0