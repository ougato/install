#!/bin/bash

#/bin/bash -c "$(curl -fsSL https://file.ougato.com:8443/d/install/gogs.sh)" -s i
#/bin/bash -c "$(curl -fsSL https://file.ougato.com:8443/d/install/gogs.sh)" -s r

# 安装路径
readonly HOST="https://file.ougato.com:8443/d"

readonly INSTALL="i"
readonly REMOVE="r"
readonly REMOVE_LIST=(
    python3
)
readonly DEPEND_LIST=(
    python3
)
readonly HELP_TIPS=(
    "i：安装"
    "r：卸载后移除所有安装项"
)
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

install() {
    for item in "${DEPEND_LIST[@]}"
    do
        if ! yum list installed "${item}">/dev/null 2>"1"; then
            sudo yum install -y "${item}"
        fi
    done
    if [ ! "$(command -v pip3)" ]; then
        read -r -p "未安装 pip3 是否安装 [y/n]：" is_install
        if [ "$is_install" == "Y" ] || [ "$is_install" == "y" ]; then
            /bin/bash -c "$(curl -fsSL ${HOST}/pip3.sh)" -s i
        fi
    fi
}

remove() {
    /bin/bash -c "$(curl -fsSL ${HOST}/pip3.sh)" -s r
    for item in "${REMOVE_LIST[@]}"
    do
        if yum list installed "${item}">/dev/null 2>"1"; then
            sudo yum remove -y "${item}"
        fi
    done
}

input_option() {
    ((input_count++)) || true
    read -r -p "输入选项：" option
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