#!/bin/bash
#上传fir.com
uploadFirm(){
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>firm"
    # 从环境变量中获取 API Token
    API_TOKEN="6c28a0303d09b9a6eccdcde4115cb90b" #6c28a0303d09b9a6eccdcde4115cb90b//9d95a7baadebae1050a3dd719ab1a9c8

    # 打印 API Token，确保它被正确读取（注意：这会暴露你的 API Token，请小心使用）
    echo "Using API Token: $API_TOKEN"

    # Android 文件路径
    ANDROID_FILE_PATH=$1

    # 检查 fir 命令是否可用
    if ! command -v fir &> /dev/null
    then
        echo "fir-cli is not installed. Please install it by running 'gem install fir-cli'."
        exit 1
    fi

    # 上传 Android 文件
    if [ -f "$ANDROID_FILE_PATH" ]; then
        echo "Uploading Android app..."
        fir publish "$ANDROID_FILE_PATH" -T "$API_TOKEN" --verbose
        echo "Android app uploaded successfully."
    else
        echo "Android file not found: $ANDROID_FILE_PATH"
    fi
}

uploadFirm "$1"
