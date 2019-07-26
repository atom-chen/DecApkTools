@echo off
setlocal enabledelayedexpansion
for  %%x in (%1%\*) do (
    java -jar unluac.jar %%x  > %%x.dua
)
pause