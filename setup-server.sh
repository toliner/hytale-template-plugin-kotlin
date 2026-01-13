#!/bin/bash

# Hytale サーバーのセットアップスクリプト (Bash版)
# Setup script for Hytale server (Bash version)

# 言語設定の取得
case "$LANG" in
    ja*) IS_JAPANESE=true ;;
    *)   IS_JAPANESE=false ;;
esac

# メッセージ定義
if [ "$IS_JAPANESE" = true ]; then
    MSG_HELP="使い方: ./setup-server.sh [オプション]

説明:
    このスクリプトは Hytale サーバーの実行環境をセットアップします。
    Hytale のインストールフォルダから必要なサーバーファイルを 'run' ディレクトリにコピーします。

オプション:
    --help, -h    このヘルプメッセージを表示します。"
    MSG_NOT_FOUND="デフォルトの場所で Hytale のインストールが見つかりませんでした: %s\n"
    MSG_PROMPT="Hytale のインストールフォルダのパスを入力してください: "
    MSG_INVALID_PATH="指定されたパスが存在しません。"
    MSG_CREATING_RUN="'run' ディレクトリを作成しています..."
    MSG_COPYING="%s を %s にコピーしています...\n"
    MSG_DONE="セットアップが正常に完了しました！"
    MSG_FILE_NOT_FOUND="エラー: ファイルまたはフォルダが見つかりません: %s\n"
else
    MSG_HELP="Usage: ./setup-server.sh [options]

Description:
    This script sets up the Hytale server execution environment.
    It copies the required server files from your Hytale installation to the 'run' directory.

Options:
    --help, -h    Show this help message."
    MSG_NOT_FOUND="Hytale installation not found at default location: %s\n"
    MSG_PROMPT="Please enter the path to your Hytale installation folder: "
    MSG_INVALID_PATH="The specified path does not exist."
    MSG_CREATING_RUN="Creating 'run' directory..."
    MSG_COPYING="Copying %s to %s...\n"
    MSG_DONE="Setup completed successfully!"
    MSG_FILE_NOT_FOUND="Error: File or folder not found: %s\n"
fi

# ヘルプの表示
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "$MSG_HELP"
    exit 0
fi

# 1. Hytale インストールフォルダの存在チェック
# Linux/Mac の場合のデフォルトパス (AppData/Roaming に相当する場所を推測)
# Hytale は現在 Windows メインですが、Wine や将来の対応を考慮
DEFAULT_HYTALE_PATH="$HOME/.hytale"
if [[ "$OSTYPE" == "darwin"* ]]; then
    DEFAULT_HYTALE_PATH="$HOME/Library/Application Support/Hytale"
fi

HYTALE_PATH="$DEFAULT_HYTALE_PATH"

if [ ! -d "$HYTALE_PATH" ]; then
    printf "$MSG_NOT_FOUND" "$HYTALE_PATH"
    read -p "$MSG_PROMPT" HYTALE_PATH
    
    # チルダ展開
    HYTALE_PATH="${HYTALE_PATH/#\~/$HOME}"

    if [ ! -d "$HYTALE_PATH" ]; then
        echo "$MSG_INVALID_PATH"
        exit 1
    fi
fi

# 2. `run` フォルダの存在確認・作成
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUN_DIR="$SCRIPT_DIR/run"

if [ ! -d "$RUN_DIR" ]; then
    echo "$MSG_CREATING_RUN"
    mkdir -p "$RUN_DIR"
fi

# 3. ファイルのコピー
FILES_TO_COPY=(
    "install/release/package/game/latest/Server/HytaleServer.jar"
    "install/release/package/game/latest/Assets.zip"
    "install/release/package/jre/latest"
)

for RELATIVE_PATH in "${FILES_TO_COPY[@]}"; do
    SOURCE_PATH="$HYTALE_PATH/$RELATIVE_PATH"
    DEST_NAME=$(basename "$RELATIVE_PATH")

    # install/release/package/jre/latest の場合はフォルダ名を jre に変更
    if [[ "$RELATIVE_PATH" == "install/release/package/jre/latest" ]]; then
        DEST_NAME="jre"
    fi

    DESTINATION_PATH="$RUN_DIR/$DEST_NAME"

    if [ -e "$SOURCE_PATH" ]; then
        printf "$MSG_COPYING" "$RELATIVE_PATH" "run/$DEST_NAME"
        cp -rf "$SOURCE_PATH" "$DESTINATION_PATH"
    else
        printf "$MSG_FILE_NOT_FOUND" "$SOURCE_PATH"
    fi
done

echo "$MSG_DONE"
