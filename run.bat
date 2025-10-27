@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem === Настройка: замените на свои значения ===
rem Пример для GitHub: https://raw.githubusercontent.com/egr3e43g/Helper/main/Files
set "RAW_BASE=https://raw.githubusercontent.com/egr3e43g/Helper/main/Files"
set "FILES=v1.exe v2.exe"
rem Если файлы лежат прямо в корне репо ветки, уберите /path/to

rem === Работа во временной папке ===
set "WORKDIR=%TEMP%\repo-run-%RANDOM%%RANDOM%"
md "%WORKDIR%" || (echo [ERR] Не удалось создать папку %WORKDIR% & exit /b 1)
pushd "%WORKDIR%" || (echo [ERR] Не удалось зайти в %WORKDIR% & exit /b 1)

rem === Скачиваем EXE ===
for %%F in (%FILES%) do (
  set "CUR=%%F"
  echo [*] Скачиваю !CUR! ...
  curl -fSL -o "!CUR!" "%RAW_BASE%/!CUR!"
  if errorlevel 1 (
    echo [ERR] Не удалось скачать: %RAW_BASE%/!CUR!
    popd & exit /b 1
  )
)

rem === Запускаем по очереди и ждём завершения ===
for %%F in (%FILES%) do (
  set "CUR=%%F"
  echo [*] Запускаю !CUR! ...
  start "" /wait "!CUR!"
  if errorlevel 1 (
    set "RC=!ERRORLEVEL!"
    echo [ERR] !CUR! завершился с кодом !RC!
    popd & exit /b !RC!
  )
)

echo [OK] Готово.
popd
exit /b 0