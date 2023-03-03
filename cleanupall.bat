@echo off
cls
echo !WARNING!
echo THIS REMOVE COPILED LIBRARIES AND HEADERS FILES FROM THIS FOLDER
echo CANCEL THIS BATCH FILE IF IT'S NOT WHAT YOU WANT TO DO
echo.
pause

echo DELETING ALL HEADERS FILES
FOR %%c in (./*.asm) DO DEL %%c
echo DELETING OTHER COMPILED FILES
FOR %%c in (./*.rel) DO DEL %%c
echo DELETING OTHER COMPILED FILES
FOR %%c in (./*.sym) DO DEL %%c
echo DELETING OTHER COMPILED FILES
FOR %%c in (./*.lst) DO DEL %%c
echo DELETING OTHER COMPILED FILES
FOR %%c in (./*.noi) DO DEL %%c
echo DELETING OTHER COMPILED FILES
FOR %%c in (./*.map) DO DEL %%c

echo DELETING OTHER COMPILED FILES
FOR %%c in (./crt0.ihx) DO DEL %%c
echo DELETING OTHER COMPILED FILES
FOR %%c in (./crt0.lk) DO DEL %%c
del crt0.ihx
del crt0.lk
echo DONE
echo.
