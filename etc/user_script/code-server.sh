#!/usr/bin/env bash
DISTRO_VERSION="1.83.1"
DISTRO_COMMIT="36d13de33ac0d6c684f10f99cff352e2f58228b3"
DISTRO_QUALITY="stable"
DISTRO_VSCODIUM_RELEASE="23285"

SERVER_APP_NAME="codium-server"
SERVER_DATA_DIR="$HOME/.vscodium-server"
SERVER_DIR="$SERVER_DATA_DIR/bin/$DISTRO_COMMIT"

# Mimic output from logs of remote-ssh extension
print_install_results_and_exit() {
    echo "6c0b472d7d7272fa64539a12: start"
    echo "exitCode==$1=="
    echo "listeningOn==$LISTENING_ON=="
    echo "connectionToken==$SERVER_CONNECTION_TOKEN=="
    echo "logFile==$SERVER_LOGFILE=="
    echo "osReleaseId==$OS_RELEASE_ID=="
    echo "arch==$ARCH=="
    echo "platform==$PLATFORM=="
    echo "tmpDir==$TMP_DIR=="
    
    echo "6c0b472d7d7272fa64539a12: end"
    exit 0
}

# Check if platform is supported
KERNEL="$(uname -s)"
case $KERNEL in
    Darwin)
        PLATFORM="darwin"
        ;;
    Linux)
        PLATFORM="linux"
        ;;
    FreeBSD)
        PLATFORM="freebsd"
        ;;
    DragonFly)
        PLATFORM="dragonfly"
        ;;
    *)
        echo "Error platform not supported: $KERNEL"
        print_install_results_and_exit 1
        ;;
esac

# Check machine architecture
ARCH="$(uname -m)"
case $ARCH in
    x86_64 | amd64)
        SERVER_ARCH="x64"
        ;;
    armv7l | armv8l)
        SERVER_ARCH="armhf"
        ;;
    arm64 | aarch64)
        SERVER_ARCH="arm64"
        ;;
    ppc64le)
        SERVER_ARCH="ppc64le"
        ;;
    *)
        echo "Error architecture not supported: $ARCH"
        print_install_results_and_exit 1
        ;;
esac

# https://www.freedesktop.org/software/systemd/man/os-release.html
OS_RELEASE_ID="$(grep -i '^ID=' /etc/os-release 2>/dev/null | sed 's/^ID=//gi' | sed 's/"//g')"
if [[ -z $OS_RELEASE_ID ]]; then
    OS_RELEASE_ID="$(grep -i '^ID=' /usr/lib/os-release 2>/dev/null | sed 's/^ID=//gi' | sed 's/"//g')"
    if [[ -z $OS_RELEASE_ID ]]; then
        OS_RELEASE_ID="unknown"
    fi
fi

# Create installation folder
if [[ ! -d $SERVER_DIR ]]; then
    mkdir -p $SERVER_DIR
    if (( $? > 0 )); then
        echo "Error creating server install directory"
        print_install_results_and_exit 1
    fi
fi

SERVER_DOWNLOAD_URL="$(echo "https://github.com/VSCodium/vscodium/releases/download/\${version}.\${release}/vscodium-reh-\${os}-\${arch}-\${version}.\${release}.tar.gz" | sed "s/\${quality}/$DISTRO_QUALITY/g" | sed "s/\${version}/$DISTRO_VERSION/g" | sed "s/\${commit}/$DISTRO_COMMIT/g" | sed "s/\${os}/$PLATFORM/g" | sed "s/\${arch}/$SERVER_ARCH/g" | sed "s/\${release}/$DISTRO_VSCODIUM_RELEASE/g")"

pushd $SERVER_DIR
    echo $SERVER_DOWNLOAD_URL
    curl -L $SERVER_DOWNLOAD_URL --output vscode-server.tar.gz
    tar zxf vscode-server.tar.gz
    rm vscode-server.tar.gz
popd # $SERVER_DIR

#https://update.code.visualstudio.com
