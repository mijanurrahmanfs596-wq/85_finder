@echo off
setlocal EnableDelayedExpansion

:: -------------------------------------------------------------
:: Close any running processes related to Hotspot Shield & Surfshark
:: -------------------------------------------------------------
taskkill /F /IM hsscp.exe >nul 2>&1
taskkill /F /IM hotspotshield.exe >nul 2>&1
taskkill /F /IM hsssrv.exe >nul 2>&1
taskkill /F /IM cmupd.exe >nul 2>&1
taskkill /F /IM af_proxy_cmd.exe >nul 2>&1
taskkill /F /IM Surfshark.exe >nul 2>&1
taskkill /F /IM Surfshark.Service.exe >nul 2>&1
taskkill /F /IM SurfsharkDiagnostics.exe >nul 2>&1

net stop "HssSrv" >nul 2>&1
net stop "Surfshark Service" >nul 2>&1

:: -------------------------------------------------------------
:: Uninstall via Windows Registry (32-bit, 64-bit, and User scopes)
:: -------------------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$vpnPatterns = @('Hotspot Shield', 'Surfshark');" ^
    "$regPaths = @(" ^
    "    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'," ^
    "    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'," ^
    "    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'" ^
    ");" ^
    "foreach ($path in $regPaths) {" ^
    "    $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {" ^
    "        $name = $_.DisplayName;" ^
    "        if ($name) {" ^
    "            foreach ($p in $vpnPatterns) { if ($name -like ('*' + $p + '*')) { return $true } }" ^
    "        }" ^
    "        return $false" ^
    "    };" ^
    "    foreach ($app in $apps) {" ^
    "        $un = if ($app.QuietUninstallString) { $app.QuietUninstallString } else { $app.UninstallString };" ^
    "        if ($un) {" ^
    "            if ($un -match '^\"([^\"]+)\"\s*(.*)$') {" ^
    "                $exe = $matches[1]; $args = $matches[2];" ^
    "            } elseif ($un -match '^(\S+)\s*(.*)$') {" ^
    "                $exe = $matches[1]; $args = $matches[2];" ^
    "            } else {" ^
    "                $exe = $un; $args = '';" ^
    "            }" ^
    "            if ($exe -match 'msiexec') {" ^
    "                if ($args -notmatch '/qn') { $args += ' /qn /norestart' }" ^
    "            } else {" ^
    "                if ($args -notmatch '(?i)/verysilent|/silent|/quiet|/qn|/S') {" ^
    "                    $args += ' /VERYSILENT /SUPPRESSMSGBOXES /SILENT /S /NORESTART /qn'" ^
    "                }" ^
    "            }" ^
    "            try {" ^
    "                Start-Process -FilePath $exe -ArgumentList $args -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue" ^
    "            } catch {}" ^
    "        }" ^
    "    }" ^
    "}"

:: -------------------------------------------------------------
:: Fallback direct uninstaller execution if files still exist
:: -------------------------------------------------------------
:: Hotspot Shield fallbacks
if exist "C:\Program Files (x86)\Hotspot Shield\HSSUninstall.exe" (
    start /wait "" "C:\Program Files (x86)\Hotspot Shield\HSSUninstall.exe" /S /VERYSILENT /NORESTART >nul 2>&1
)
if exist "C:\Program Files\Hotspot Shield\HSSUninstall.exe" (
    start /wait "" "C:\Program Files\Hotspot Shield\HSSUninstall.exe" /S /VERYSILENT /NORESTART >nul 2>&1
)
if exist "C:\Program Files (x86)\Hotspot Shield\uninstall.exe" (
    start /wait "" "C:\Program Files (x86)\Hotspot Shield\uninstall.exe" /S /VERYSILENT /NORESTART >nul 2>&1
)
if exist "%LOCALAPPDATA%\Hotspot Shield\HSSUninstall.exe" (
    start /wait "" "%LOCALAPPDATA%\Hotspot Shield\HSSUninstall.exe" /S /VERYSILENT /NORESTART >nul 2>&1
)

:: Surfshark fallbacks
if exist "C:\Program Files\Surfshark\unins000.exe" (
    start /wait "" "C:\Program Files\Surfshark\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART >nul 2>&1
)
if exist "C:\Program Files (x86)\Surfshark\unins000.exe" (
    start /wait "" "C:\Program Files (x86)\Surfshark\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART >nul 2>&1
)
if exist "C:\Program Files\Surfshark\Uninstall.exe" (
    start /wait "" "C:\Program Files\Surfshark\Uninstall.exe" /S /VERYSILENT /NORESTART >nul 2>&1
)
if exist "%LOCALAPPDATA%\Programs\Surfshark\unins000.exe" (
    start /wait "" "%LOCALAPPDATA%\Programs\Surfshark\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART >nul 2>&1
)

:: -------------------------------------------------------------
:: Remove leftover shortcuts and exit
:: -------------------------------------------------------------
del /f /q "%USERPROFILE%\Desktop\*Hotspot Shield*.lnk" >nul 2>&1
del /f /q "%PUBLIC%\Desktop\*Hotspot Shield*.lnk" >nul 2>&1
del /f /q "%USERPROFILE%\Desktop\*Surfshark*.lnk" >nul 2>&1
del /f /q "%PUBLIC%\Desktop\*Surfshark*.lnk" >nul 2>&1

exit
