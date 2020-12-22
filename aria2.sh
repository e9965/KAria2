<<COMMENT
wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip -q -o ngrok-stable-linux-amd64.zip && rm -f ngrok-stable-linux-amd64.zip
./ngrok authtoken 1jamTLHeHJPl6hRK2Lhg8iyYn6p_56mkMEbGcUnyK9S6UbkXT
rm -rf /home/*
wget --no-check-certificate -O /home/DAria2.zip https://github.com/e9965/DAria2/blob/main/DAria2.zip?raw=true && unzip /home/DAria2.zip -d /home/ && chmod +rwx /home/aria2.sh && chmod +rwx /home/sh.sh && rm -rf /home/DAria2.zip
./ngrok tcp 6800 & sudo bash /home/aria2.sh
stress-ng -c 1 -l 2 -t 180d
COMMENT
sh_ver="2.7.3"
export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin
aria2_conf_dir="/root/.aria2c"
download_path="/home/temp/unzip"
aria2_conf="${aria2_conf_dir}/aria2.conf"
aria2_log="${aria2_conf_dir}/aria2.log" && touch ${aria2_log}
aria2c="/usr/local/bin/aria2c"
Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"

APT_INSTALL(){
	IFS=" "
	touch /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb http://mirrors.aliyun.com/debian/ buster main non-free contrib" > /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib" >> /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb http://mirrors.aliyun.com/debian-security buster/updates main" >> /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb-src http://mirrors.aliyun.com/debian-security buster/updates main" >> /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list.d/aliyun.list
	sudo echo "deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list.d/aliyun.list
	sudo apt-get update -y
	for i in p7zip-full p7zip-rar file rsync dos2unix cron wget curl nano ca-certificates findutils jq tar gzip dpkg stress-ng
	do
		apt-get install ${i} -y
	done
	if [[ ! -s /etc/ssl/certs/ca-certificates.crt ]]; then
        wget -qO- git.io/ca-certificates.sh | bash
    fi
    curl https://rclone.org/install.sh | sudo bash
	IFS=$(echo -en "\n\b")
}
check_pid() {
    PID=$(ps -ef | grep "aria2c" | grep -v grep | grep -v "aria2.sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
}
check_new_ver() {
    aria2_new_ver=$(
        {
            wget -t2 -T3 -qO- "https://api.github.com/repos/P3TERX/aria2-builder/releases/latest" ||
                wget -t2 -T3 -qO- "https://gh-api.p3terx.com/repos/P3TERX/aria2-builder/releases/latest"
        } | grep -o '"tag_name": ".*"' | head -n 1 | cut -d'"' -f4
    )
    if [[ -z ${aria2_new_ver} ]]; then
        echo -e "${Error} Aria2 最新版本获取失败，请手动获取最新版本号[ https://github.com/P3TERX/aria2-builder/releases ]"
        read -e -p "请输入版本号:" aria2_new_ver
        [[ -z "${aria2_new_ver}" ]] && echo "取消..." && exit 1
    fi
}
Download_aria2() {
    while [[ $(which aria2c) ]]; do
        echo -e "${Info} 删除旧版 Aria2 二进制文件..."
        rm -vf $(which aria2c)
    done
    DOWNLOAD_URL="https://github.com/P3TERX/aria2-builder/releases/download/${aria2_new_ver}/aria2-${aria2_new_ver%_*}-static-linux-amd64.tar.gz"
    {
        wget -t2 -T3 -O- "${DOWNLOAD_URL}" ||
            wget -t2 -T3 -O- "https://gh-acc.p3terx.com/${DOWNLOAD_URL}"
    } | tar -zx
    [[ ! -s "aria2c" ]] && echo -e "${Error} Aria2 下载失败 !" && exit 1
    [[ ${update_dl} = "update" ]] && rm -f "${aria2c}"
    mv -f aria2c "${aria2c}"
    [[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 主程序安装失败！" && exit 1
    chmod +x ${aria2c}
    echo -e "${Info} Aria2 主程序安装完成！"
}
Download_aria2_conf() {
    PROFILE_URL1="https://p3terx.github.io/aria2.conf"
    PROFILE_URL2="https://aria2c.now.sh"
    PROFILE_URL3="https://cdn.jsdelivr.net/gh/P3TERX/aria2.conf@master"
    PROFILE_LIST="
aria2.conf
clean.sh
core
script.conf
rclone.env
upload.sh
delete.sh
dht.dat
dht6.dat
move.sh
LICENSE
"
    mkdir -p "${aria2_conf_dir}" && cd "${aria2_conf_dir}"
    for PROFILE in ${PROFILE_LIST}; do
        [[ ! -f ${PROFILE} ]] && rm -rf ${PROFILE}
        wget -N -t2 -T3 ${PROFILE_URL1}/${PROFILE} ||
            wget -N -t2 -T3 ${PROFILE_URL2}/${PROFILE} ||
            wget -N -t2 -T3 ${PROFILE_URL3}/${PROFILE}
        [[ ! -s ${PROFILE} ]] && {
            echo -e "${Error} '${PROFILE}' 下载失败！清理残留文件..."
            rm -vrf "${aria2_conf_dir}"
            exit 1
        }
    done
    sed -i "s@^\(dir=\).*@\1${download_path}@" ${aria2_conf}
    sed -i "s@/root/.aria2/@${aria2_conf_dir}/@" ${aria2_conf_dir}/*.conf
    sed -i "s@^\(rpc-secret=\).*@\1e9965@" ${aria2_conf}
    sed -i "s@^#\(retry-on-.*=\).*@\1true@" ${aria2_conf}
    sed -i "s@^\(max-connection-per-server=\).*@\132@" ${aria2_conf}
    sed -i '/complete/'d ${aria2_conf}
    echo "on-download-complete=/home/sh.sh" >> ${aria2_conf}
    touch aria2.session
    chmod +x *.sh
    echo -e "${Info} Aria2 完美配置下载完成！"
}
Service_aria2() {
    wget -N -t2 -T3 "https://raw.githubusercontent.com/P3TERX/aria2.sh/master/service/aria2_debian" -O /etc/init.d/aria2 ||
        wget -N -t2 -T3 "https://cdn.jsdelivr.net/gh/P3TERX/aria2.sh@master/service/aria2_debian" -O /etc/init.d/aria2 ||
        wget -N -t2 -T3 "https://gh-raw.p3terx.com/P3TERX/aria2.sh/master/service/aria2_debian" -O /etc/init.d/aria2
    [[ ! -s /etc/init.d/aria2 ]] && {
        echo -e "${Error} Aria2服务 管理脚本下载失败 !"
        exit 1
    }
    chmod +x /etc/init.d/aria2
    update-rc.d -f aria2 defaults
    echo -e "${Info} Aria2服务 管理脚本下载完成 !"
}

Install_aria2() {
    [[ -e ${aria2c} ]] && echo -e "${Error} Aria2 已安装，请检查 !" && exit 1
    echo -e "${Info} 开始下载/安装 主程序..."
    check_new_ver
    Download_aria2
    echo -e "${Info} 开始下载/安装 Aria2 完美配置..."
    Download_aria2_conf
    echo -e "${Info} 开始下载/安装 服务脚本(init)..."
    Service_aria2
    Read_config
    aria2_RPC_port=${aria2_port}
    echo -e "${Info} 开始设置 iptables 防火墙..."
    Set_iptables
    echo -e "${Info} 开始添加 iptables 防火墙规则..."
    Add_iptables
    echo -e "${Info} 开始保存 iptables 防火墙规则..."
    Save_iptables
    echo -e "${Info} 开始创建 下载目录..."
    mkdir -p ${download_path}
    echo -e "${Info} 所有步骤 安装完毕，开始启动..."
    /etc/init.d/aria2 start
}
Read_config() {
    status_type=$1
    if [[ ! -e ${aria2_conf} ]]; then
        if [[ ${status_type} != "un" ]]; then
            echo -e "${Error} Aria2 配置文件不存在 !" && exit 1
        fi
    else
        conf_text=$(cat ${aria2_conf} | grep -v '#')
        aria2_dir=$(echo -e "${conf_text}" | grep "^dir=" | awk -F "=" '{print $NF}')
        aria2_passwd=$(echo -e "${conf_text}" | grep "^rpc-secret=" | awk -F "=" '{print $NF}')
        aria2_bt_port=$(echo -e "${conf_text}" | grep "^listen-port=" | awk -F "=" '{print $NF}')
        aria2_dht_port=$(echo -e "${conf_text}" | grep "^dht-listen-port=" | awk -F "=" '{print $NF}')
    fi
}
View_Aria2() {
    Read_config
    wget -O tunnels http://127.0.0.1:4040/api/tunnels > /dev/null 2>&1
    raw=$(grep -o "tcp://\{1\}[[:print:]].*,\{1\}" tunnels) && raw=${raw##*/} && raw=${raw%%\"*}
    IPV4=${raw%%:*} && aria2_port=${raw##*:}
    echo -e "\nAria2 简单配置信息：\n
 IPv4 地址\t: ${Green_font_prefix}${IPV4}${Font_color_suffix}
 RPC 端口\t: ${Green_font_prefix}${aria2_port}${Font_color_suffix}
 RPC 密钥\t: ${Green_font_prefix}${aria2_passwd}${Font_color_suffix}"
}
crontab_update_start() {
    crontab -l >"/tmp/crontab.bak"
    sed -i "/aria2.sh update-bt-tracker/d" "/tmp/crontab.bak"
    sed -i "/tracker.sh/d" "/tmp/crontab.bak"
    echo -e "\n0 7 * * * /bin/bash <(wget -qO- git.io/tracker.sh) ${aria2_conf} RPC 2>&1 | tee ${aria2_conf_dir}/tracker.log" >>"/tmp/crontab.bak"
    crontab "/tmp/crontab.bak"
    rm -f "/tmp/crontab.bak"
    Update_bt_tracker
    echo && echo -e "${Info} 自动更新 BT-Tracker 开启成功 !"
}
Update_bt_tracker() {
    check_pid
    [[ -z $PID ]] && {
        bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}
    } || {
        bash <(wget -qO- git.io/tracker.sh) ${aria2_conf} RPC
    }
}
Add_iptables() {
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_RPC_port} -j ACCEPT
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_bt_port} -j ACCEPT
    iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${aria2_dht_port} -j ACCEPT
}
Del_iptables() {
    iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_port} -j ACCEPT
    iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_bt_port} -j ACCEPT
    iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${aria2_dht_port} -j ACCEPT
}
Save_iptables() {
    if [[ ${release} == "centos" ]]; then
        service iptables save
    else
        iptables-save >/etc/iptables.up.rules
    fi
}
Set_iptables() {
    iptables-save >/etc/iptables.up.rules
    echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' >/etc/network/if-pre-up.d/iptables
    chmod +x /etc/network/if-pre-up.d/iptables
}
PASSWD_FILE_INSERT(){
    cat > /bin/pw <<\EOF
[[ ! -z ${1} ]] && [[ -z $(grep -oE "${1}" /home/conf/passwd.conf) ]] && echo "$1" >> /home/conf/passwd.conf && echo "Success - Insert [${1}] -"    
EOF
}
echo "开始初始化"
APT_INSTALL > /dev/null 2>&1
echo "完成初始化 & 开始安装Aria2"
Install_aria2 > /dev/null 2>&1
echo "完成安装Aria2 & 开始准备链接数据"
crontab_update_start > /dev/null 2>&1
echo "准备完成 & 开始打印Aria2链接数据"
PASSWD_FILE_INSERT
View_Aria2
