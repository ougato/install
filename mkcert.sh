#!/bin/bash

#/bin/bash -c "$(curl -fsSL "https://raw.githubusercontent.com/ougato/install/refs/heads/master/mkcert.sh)" -s i
#/bin/bash -c "$(curl -fsSL "https://raw.githubusercontent.com/ougato/install/refs/heads/master/mkcert.sh)" -s r

# 安装路径
readonly HOST="https://raw.githubusercontent.com/ougato/install/refs/heads/master"

readonly INSTALL="i"
readonly REMOVE="r"
readonly DEPEND_LIST=(
    nss-tools
)
readonly HELP_TIPS=(
    "i: 安装"
    "r: 卸载后移除所有安装项"
)
# 最大输入错误次数
readonly MAX_ERROR_COUNT=3
# 当前输入错误次数
input_count=0

print_help() {
    for item in "${HELP_TIPS[@]}"; do
        echo "$item"
    done
}

install() {
    for item in "${DEPEND_LIST[@]}"; do
        if ! yum list installed "${item}" >/dev/null 2>"1"; then
            sudo yum install -y "${item}"
        fi
    done

    wget "${HOST}/package/linux/centos/mkcert-v1.4.4-linux-amd64" -O /usr/local/bin/mkcert
    chmod +x /usr/local/bin/mkcert
}

remove() {
    rm /usr/local/bin/mkcert

    for item in "${REMOVE_LIST[@]}"; do
        if yum list installed "${item}" >/dev/null 2>"1"; then
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
