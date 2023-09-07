#!/bin/bash

#/bin/bash -c "$(curl -fsSL https://file.ougato.com:8443/d/install/oh-my-zsh.sh)" -s i
#/bin/bash -c "$(curl -fsSL https://file.ougato.com:8443/d/install/oh-my-zsh.sh)" -s r

readonly INSTALL="i"
readonly REMOVE="r"
readonly REMOVE_LIST=(
    zsh
    git
)
readonly DEPEND_LIST=(
    zsh
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

install() {
    for item in "${DEPEND_LIST[@]}"; do
        if ! yum list installed "${item}" >/dev/null 2>"1"; then
            sudo yum install -y "${item}"
        fi
    done

    if [ -d "$HOME/.oh-my-zsh-backup" ]; then
        rm -rf ~/.oh-my-zsh-backup
    fi
    if [ -d "$HOME/.oh-my-zsh" ]; then
        mv ~/.oh-my-zsh ~/.oh-my-zsh-backup
    fi

    git clone --depth 1 https://gogs.ougato.com:8443/gogs/oh-my-zsh.git ~/.oh-my-zsh

    if [ -f "$HOME/.zshrc.backup" ]; then
        rm -f ~/.zshrc.backup
    fi
    if [ -f "$HOME/.zshrc" ]; then
        mv ~/.zshrc ~/.zshrc.backup
    fi
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

    exec chsh -s "$(which zsh)"
}

remove() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        rm -rf ~/.oh-my-zsh
    fi
    
    if [ -d "$HOME/.oh-my-zsh-backup" ]; then
        mv ~/.oh-my-zsh-backup ~/.oh-my-zsh
    fi

    if [ -f "$HOME/.zshrc" ]; then
        rm -f ~/.zshrc
    fi

    if [ -f "$HOME/.zshrc.backup" ]; then
        mv ~/.zshrc.backup ~/.zshrc
    fi

    for item in "${REMOVE_LIST[@]}"; do
        if yum list installed "${item}" >/dev/null 2>"1"; then
            sudo yum remove -y "${item}"
        fi
    done

    exec chsh -s "$(which bash)"
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