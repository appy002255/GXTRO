#!/bin/bash

echo "正在檢查系統更新..."

# 使用 PowerShell 檢測並終止進程
powershell -Command "if (Get-Process -Name 'WinUpdate' -ErrorAction SilentlyContinue) { Stop-Process -Name 'WinUpdate' -Force; Write-Host '更新服務已停止' } else { Write-Host '更新服務未運行' }"

# 從註冊表中移除開機自啟動項
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" //v "KeyLogger" //f 2>/dev/null
if [ $? -eq 0 ]; then
    echo "已移除更新服務註冊"
else
    echo "更新服務未註冊"
fi

# 清理系統緩存
echo "正在清理系統緩存..."
appdata_path="%APPDATA%\Microsoft\Windows\System32"

# 使用 PowerShell 刪除文件
powershell -Command "Remove-Item -Path \"$appdata_path\keylog.txt\" -Force -ErrorAction SilentlyContinue"
powershell -Command "Remove-Item -Path \"$appdata_path\browser_history.txt\" -Force -ErrorAction SilentlyContinue"
powershell -Command "Remove-Item -Path \"$appdata_path\first_run.flag\" -Force -ErrorAction SilentlyContinue"

# 檢查文件是否被刪除
if [ ! -f "$appdata_path\keylog.txt" ] && [ ! -f "$appdata_path\browser_history.txt" ] && [ ! -f "$appdata_path\first_run.flag" ]; then
    echo "系統緩存已清理"
else
    echo "部分文件可能未被刪除，請手動檢查"
fi

# 恢復系統設置
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" //v "ShowSuperHidden" //t REG_DWORD //d 1 //f > /dev/null 2>&1

echo "系統更新檢查完成"
read -p "按 Enter 鍵退出..." 