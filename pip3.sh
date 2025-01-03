#!/bin/bash

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ougato/install/refs/heads/master/pip3.sh)" -s i
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ougato/install/refs/heads/master/pip3.sh)" -s r

readonly INSTALL="i"
readonly REMOVE="r"
readonly REMOVE_LIST=(
    python3-pip
)
readonly DEPEND_LIST=(
    python3-pip
)
readonly HELP_TIPS=(
    "i: 安装"
    "r: 卸载后移除所有安装项"
)
readonly INDEX_URL=(
    # 阿里云
    "https://mirrors.aliyun.com/pypi/simple/"
    # 清华大学
    "https://pypi.tuna.tsinghua.edu.cn/simple "
    # 科技大学
    "https://pypi.mirrors.ustc.edu.cn/simple/ "
)
readonly TRUSTED_HOST=(
    # 阿里云
    "mirrors.aliyun.com"
    # 清华大学
    "pypi.tuna.tsinghua.edu.cn"
    # 科技大学
    "pypi.mirrors.ustc.edu.cn"
)
readonly REPO_NAME=(
    "阿里云"
    "清华大学"
    "科技大学"
)
readonly TIMEOUT=6000
# 最大输入错误次数
readonly MAX_ERROR_COUNT=3
# 当前输入错误次数
input_count=0

print_help() {
    for item in "${HELP_TIPS[@]}"
    do
        echo "$item"
    done
}

write_repo() {
    str_global="[global]"
    str_timeout="timeout = ${TIMEOUT}"
    str_index_url="index-url = ${INDEX_URL[$1]}"
    str_trusted_host="trusted-host = ${TRUSTED_HOST[$1]}"
    mkdir -p ~/.pip
    echo "$str_global"$'\n'"$str_timeout"$'\n'"$str_index_url"$'\n'"$str_trusted_host" > ~/.pip/pip.conf
}

set_repo() {
    echo "0: 阿里云"
    echo "1: 清华大学"
    echo "2: 科技大学"
    read -r -p "输入国内源选项: " option
    
    if [ "$option" == "0" ] ||
        [ "$option" == "1" ] ||
        [ "$option" == "2" ]; then
        num_option=10#${option}
        write_repo "$num_option"
        echo "使用${REPO_NAME[$num_option]}源"
    else
        echo "使用默认源"
    fi
}

upgrade_pip3() {
    read -r -p "是否升级 pip3 [y/n]: " is_upgrade
    if [ "$is_upgrade" == "Y" ] || [ "$is_upgrade" == "y" ]; then
        python3 -m pip install --upgrade pip
    fi
}

install() {
    for item in "${DEPEND_LIST[@]}"
    do
        if ! yum list installed "${item}">/dev/null 2>"1"; then
            sudo yum install -y "${item}"
        fi
    done
    
    set_repo
    upgrade_pip3
}

remove() {
    for item in "${REMOVE_LIST[@]}"
    do
        if yum list installed "${item}">/dev/null 2>"1"; then
            sudo yum remove -y "${item}"
        fi
    done
}

input_option() {
    ((input_count++)) || true
    read -r -p "输入选项: " option
    main "$option"
}

main() {
    if [ "$input_count" -ge $MAX_ERROR_COUNT ]; then
        exit 1
    fi

    if [ $# -le 0 ]; then
        print_help
        exit 1
    fi

    if [ "$1" == $INSTALL ]; then
        install
    elif [ "$1" == $REMOVE ]; then
        remove
    else
        print_help
        input_option
    fi

}

main "$1"