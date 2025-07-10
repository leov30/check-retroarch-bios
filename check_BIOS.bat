@echo off
REM setlocal EnableDelayedExpansion


rem // set retroarch folder location
set "_main=C:\RetroArch-Win64"

type nul>error.txt
for %%g in ("%_main%\cores\*.dll") do (
	
	rem //get bios info from .info file
	if exist "%_main%\info\%%~ng.info" (
		echo %%~ng.dll
		for /f "tokens=1* delims== " %%h in ('findstr /rb /c:"firmware[0-9]_path" /c:"firmware[0-9][0-9]_path" "%_main%\info\%%~ng.info"') do (
			if exist "%_main%\system\%%~i" (
				rem //if bios file already exist, get md5 info
				call :get_info "%%~i" "%%~ng"
				
			)else (
				rem //bios file dosen't exist, download it
				echo 	  %%~i -------------- NOT FOUND
				echo %%i ----- NOT_FOUND>>error.txt
				
			)
		)
		
	)else (
		echo %%~ng.info -------------- INFO FILE WAS NOT FOUND
	)
	
)


pause&exit


:get_info

set "_hash="
set "_found="

findstr /l /c:"(!) %~1 (md5)" "%_main%\info\%~2.info" >nul
if %errorlevel% equ 0 (
	set "_found=*"
	for /f "skip=1 delims=" %%g in ('certutil -hashfile "%_main%\system\%~1" MD5') do set "_hash=%%g"&goto :next_1
)
findstr /l /c:"(!) %~1 (sha1)" "%_main%\info\%~2.info" >nul
if %errorlevel% equ 0 (
	set "_found=*"
	for /f "skip=1 delims=" %%g in ('certutil -hashfile "%_main%\system\%~1" SHA1') do set "_hash=%%g"&goto :next_1
)

rem //no md5/sha1 found
echo 	 %_found% %~1

exit /b
:next_1

rem //just check if it matches
set "_verify=-------------- BAD CHECKSUM"
findstr /il /c:"%_hash%" "%_main%\info\%~2.info" >nul
if %errorlevel% equ 0 (set "_verify=")else (echo %1 --------- BAD_CHECKSUM) >>error.txt

echo 	%_found% %~1 %_verify%

exit /b
