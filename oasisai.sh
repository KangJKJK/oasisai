#!/bin/bash

# 필요한 패키지 확인 및 설치
check_and_install_packages() {
    if ! command -v wget &> /dev/null; then
        echo "wget이 설치되어 있지 않습니다. 설치를 시작합니다..."
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y wget
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wget
        elif command -v yum &> /dev/null; then
            sudo yum install -y wget
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wget
        else
            echo "패키지 관리자를 찾을 수 없습니다. wget을 수동으로 설치해주세요."
            exit 1
        fi
    fi

    # AppImage 실행에 필요한 추가 패키지 설치
    echo "AppImage 실행에 필요한 패키지들을 설치합니다..."
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y libfuse2 fuse \
            libc6 libglib2.0-0 libcairo2 \
            libgl1-mesa-glx libnss3 libxcb1 \
            libx11-6 libxcomposite1 libxcursor1 \
            libxdamage1 libxext6 libxfixes3 \
            libxi6 libxrandr2 libxrender1 \
            libxss1 libxtst6 libasound2
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y fuse-libs fuse \
            glib2 cairo mesa-libGL nss \
            libxcb libX11 libXcomposite \
            libXcursor libXdamage libXext \
            libXfixes libXi libXrandr \
            libXrender libXScrnSaver \
            libXtst alsa-lib
    elif command -v yum &> /dev/null; then
        sudo yum install -y fuse-libs fuse \
            glib2 cairo mesa-libGL nss \
            libxcb libX11 libXcomposite \
            libXcursor libXdamage libXext \
            libXfixes libXi libXrandr \
            libXrender libXScrnSaver \
            libXtst alsa-lib
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm fuse2 fuse3 \
            glib2 cairo mesa nss libxcb \
            libx11 libxcomposite libxcursor \
            libxdamage libxext libxfixes \
            libxi libxrandr libxrender \
            libxss libxtst alsa-lib
    else
        echo "패키지 관리자를 찾을 수 없습니다."
        exit 1
    fi
}

# 패키지 설치 실행
echo "필요한 패키지를 확인합니다..."
check_and_install_packages

# Oasis AI AppImage URL
URL="https://s3.amazonaws.com/desktop.oasis.ai/Oasis%20AI_0.0.17_amd64.AppImage"
FILENAME="OasisAI.AppImage"

echo "Oasis AI 다운로드를 시작합니다..."

# wget으로 파일 다운로드 (URL의 공백 문자를 처리하기 위해 따옴표 사용)
if ! wget "$URL" -O "$FILENAME"; then
    echo "다운로드 실패!"
    exit 1
fi

echo "다운로드 완료!"

# 실행 권한 부여
chmod +x "$FILENAME"
echo "실행 권한을 부여했습니다."

# AppImage 실행 전 시스템 아키텍처 확인
if [ "$(uname -m)" != "x86_64" ]; then
    echo "이 애플리케이션은 64비트 시스템에서만 실행할 수 있습니다."
    exit 1
fi

# AppImage 실행 시도
echo "Oasis AI를 실행합니다..."
./"$FILENAME" --no-sandbox || {
    echo "기본 실행 방식 실패, 대체 방식으로 시도합니다..."
    ./"$FILENAME" --appimage-extract-and-run
}
