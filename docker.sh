#!/bin/bash

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ougato/install/refs/heads/master/docker.sh)" -s i
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ougato/install/refs/heads/master/docker.sh)" -s r

# 安装路径
readonly HOST="https://raw.githubusercontent.com/ougato/install/refs/heads/master"

readonly INSTALL="i"
readonly REMOVE="r"
readonly REMOVE_OLD_LIST=(
    docker
    docker-client
    docker-client-latest
    docker-common
    docker-latest
    docker-latest-logrotate
    docker-logrotate
    docker-engine
)
readonly REMOVE_LIST=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-compose-plugin
)
readonly DEPEND_LIST=(
    yum-utils
    docker-ce
    docker-ce-cli
    containerd.io
    docker-compose-plugin
)
readonly HELP_TIPS=(
    "i: 安装后添加到开机启动"
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

remove_old() {
    for item in "${REMOVE_OLD_LIST[@]}"; do
        if yum list installed "${item}" >/dev/null 2>"1"; then
            sudo yum remove -y "${item}"
        fi
    done
}

install_docker_compose() {
    /bin/bash -c "$(curl -fsSL ${HOST}/docker-compose.sh)" -s i
}

remove_docker_compose() {
    /bin/bash -c "$(curl -fsSL ${HOST}/docker-compose.sh)" -s r
}

install() {
    remove_old
    for item in "${DEPEND_LIST[@]}"; do
        if ! yum list installed "${item}" >/dev/null 2>"1"; then
            sudo yum install -y "${item}"
        fi
    done

    # yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

    sleep 1
    systemctl start docker
    systemctl enable docker

    if [ ! "$(command -v docker-compose)" ]; then
        read -r -p "未安装 docker-compose 是否安装 [y/n]: " is_install
        if [ "$is_install" == "Y" ] || [ "$is_install" == "y" ]; then
            install_docker_compose
        fi
    fi
}

remove() {
    systemctl stop docker
    systemctl disable docker
    remove_old
    remove_docker_compose
    for item in "${REMOVE_LIST[@]}"; do
        if yum list installed "${item}" >/dev/null 2>"1"; then
            sudo yum remove -y "${item}"
        fi
    done
    rm -rf /var/lib/docker/
    rm -rf /etc/docker/
    rm -rf /run/docker
    rm -rf /var/lib/dockershim
    rm -rf /usr/libexec/docker/
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
