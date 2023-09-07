#!/bin/bash

#/bin/bash -c "$(curl -fsSL https://file.ougato.com:8443/d/install/git.sh)" -s i
#/bin/bash -c "$(curl -fsSL https://file.ougato.com:8443/d/install/git.sh)" -s r

# 安装路径
readonly HOST="https://file.ougato.com:8443/d"

readonly INSTALL="i"
readonly REMOVE="r"
readonly REMOVE_LIST=(
    git
)
readonly DEPEND_LIST=(
    git
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

install_zsh() {
    /bin/bash -c "$(curl -fsSL ${HOST}/install/oh-my-zsh.sh)" -s i
}

remove_zsh() {
    /bin/bash -c "$(curl -fsSL ${HOST}/install/oh-my-zsh.sh)" -s r
}

install() {
    for item in "${DEPEND_LIST[@]}"; do
        if ! yum list installed "${item}" >/dev/null 2>"1"; then
            sudo yum install -y "${item}"
        fi
    done
    if [ ! "$(command -v zsh)" ] || [ ! -d "$HOME/.oh-my-zsh" ] || [ ! -f "$HOME/.zshrc" ]; then
        read -r -p "未安装 zsh 是否安装 [y/n]：" is_install
        if [ "$is_install" == "Y" ] || [ "$is_install" == "y" ]; then
            install_zsh
        fi
    fi
}

remove() {
    if [ "$(command -v zsh)" ]; then
        read -r -p "已安装 zsh 是否卸载 [y/n]：" is_remove
        if [ "$is_remove" == "Y" ] || [ "$is_remove" == "y" ]; then
            remove_zsh
        fi
    fi
    for item in "${REMOVE_LIST[@]}"; do
        if yum list installed "${item}" >/dev/null 2>"1"; then
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