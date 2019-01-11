SETLOCAL EnableExtensions
set EXE=TestExecute.exe

:START
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF %%x == %EXE% goto FOUND

echo Starting TestExecute
"C:\Program Files (x86)\SmartBear\TestExecute 12\Bin\TestExecute.exe" "C:\Automation\TestComplete\Basis\Seed\DemoProject\DemoProject.mds" /run /p:DemoProject /u:Main /rt:demoTestRun /SilentMode /DoNotShowLog /exit

goto FIN
:FOUND

echo TestExecute Finished

:FIN
PING 1.1.1.1 -n 1 -w 15000 >NUL
goto START