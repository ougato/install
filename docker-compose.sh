#!/bin/bash

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ougato/install/refs/heads/master/docker-compose.sh)" -s i
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ougato/install/refs/heads/master/docker-compose.sh)" -s r

# 安装路径
readonly HOST="https://raw.githubusercontent.com/ougato/install/refs/heads/master"

readonly INSTALL="i"
readonly REMOVE="r"
readonly HELP_TIPS=(
    "i: 安装"
    "r: 卸载后移除所有安装项"
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
    /bin/bash -c "$(curl -fsSL ${HOST}/python3.sh)" -s i
    /bin/bash -c "$(curl -fsSL ${HOST}/pip3.sh)" -s i
    pip3 install docker-compose
}

remove() {
    pip3 uninstall docker-compose
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