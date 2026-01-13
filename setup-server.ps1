<#
.SYNOPSIS
    Hytale サーバーの実行環境をセットアップします。
    Sets up the Hytale server execution environment.

.DESCRIPTION
    Hytale のインストールフォルダから必要なファイルを `run` フォルダにコピーします。
    Copies necessary files from the Hytale installation folder to the `run` folder.

.PARAMETER Help
    ヘルプを表示します。
    Displays help information.
#>

param(
    [Alias("h")]
    [switch]$Help
)

# 言語設定の取得 (簡易的な判定)
$Culture = [System.Globalization.CultureInfo]::CurrentCulture.Name
$IsJapanese = $Culture.StartsWith("ja")

# メッセージ定義
$Messages = @{
    en = @{
        Help = @"
Usage: .\setup-server.ps1 [-help]

Description:
    This script sets up the Hytale server execution environment.
    It copies the required server files from your Hytale installation to the 'run' directory.

Options:
    -help    Show this help message.
"@
        HytaleNotFound = "Hytale installation not found at default location: {0}"
        PromptPath = "Please enter the path to your Hytale installation folder:"
        InvalidPath = "The specified path does not exist."
        CreatingRunDir = "Creating 'run' directory..."
        Copying = "Copying {0} to {1}..."
        Done = "Setup completed successfully!"
        FileNotFound = "Error: File or folder not found: {0}"
    }
    ja = @{
        Help = @"
使い方: .\setup-server.ps1 [-help]

説明:
    このスクリプトは Hytale サーバーの実行環境をセットアップします。
    Hytale のインストールフォルダから必要なサーバーファイルを 'run' ディレクトリにコピーします。

オプション:
    -help    このヘルプメッセージを表示します。
"@
        HytaleNotFound = "デフォルトの場所で Hytale のインストールが見つかりませんでした: {0}"
        PromptPath = "Hytale のインストールフォルダのパスを入力してください:"
        InvalidPath = "指定されたパスが存在しません。"
        CreatingRunDir = "'run' ディレクトリを作成しています..."
        Copying = "{0} を {1} にコピーしています..."
        Done = "セットアップが正常に完了しました！"
        FileNotFound = "エラー: ファイルまたはフォルダが見つかりません: {0}"
    }
}

$Msg = if ($IsJapanese) { $Messages.ja } else { $Messages.en }

# ヘルプ表示
if ($Help) {
    Write-Host $Msg.Help
    exit 0
}

# 1. Hytale インストールフォルダの存在チェック
$DefaultHytalePath = Join-Path $env:APPDATA "Hytale"
$HytalePath = $DefaultHytalePath

if (-not (Test-Path $HytalePath)) {
    Write-Host ($Msg.HytaleNotFound -f $HytalePath) -ForegroundColor Yellow
    $HytalePath = Read-Host $Msg.PromptPath
    
    if (-not (Test-Path $HytalePath)) {
        Write-Host $Msg.InvalidPath -ForegroundColor Red
        exit 1
    }
}

# 2. `run` フォルダの存在確認・作成
$RunDir = Join-Path $PSScriptRoot "run"
if (-not (Test-Path $RunDir)) {
    Write-Host $Msg.CreatingRunDir
    New-Item -ItemType Directory -Path $RunDir | Out-Null
    New-Item -ItemType Directory -Path "$RunDir\mods" | Out-Null
}

# 3. ファイルのコピー
$FilesToCopy = @(
    "install\release\package\game\latest\Server\HytaleServer.jar",
    "install\release\package\game\latest\Assets.zip",
    "install\release\package\jre\latest"
)

foreach ($RelativePath in $FilesToCopy) {
    $SourcePath = Join-Path $HytalePath $RelativePath
    $DestName = Split-Path $RelativePath -Leaf
    
    # install\release\package\jre\latest の場合はフォルダ名を jre に変更
    if ($RelativePath -eq "install\release\package\jre\latest") {
        $DestName = "jre"
    }
    
    $DestinationPath = Join-Path $RunDir $DestName

    if (Test-Path $SourcePath) {
        Write-Host ($Msg.Copying -f $RelativePath, "run\$DestName")
        if (Test-Path $SourcePath -PathType Container) {
            # フォルダの場合は再帰的にコピー
            Copy-Item -Path $SourcePath -Destination $DestinationPath -Recurse -Force
        } else {
            Copy-Item -Path $SourcePath -Destination $DestinationPath -Force
        }
    } else {
        Write-Host ($Msg.FileNotFound -f $SourcePath) -ForegroundColor Red
    }
}

Write-Host $Msg.Done -ForegroundColor Green
