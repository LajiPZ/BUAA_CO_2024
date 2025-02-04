@echo off

echo This is designed for P7 verification. Before continuing, ensure that your code has .ktext field.
pause

rmdir /s /q result 2> nul
rmdir /s /q temp 2> nul

md temp
cd temp

for /f %%i in ('dir /b ..\src') do echo verilog work "..\src\%%i" >> mips.prj 

%xilinx%\bin\nt64\fuse.exe -nodebug -prj mips.prj -o mips.exe mips_tb >nul
IF ERRORLEVEL 1 (
    echo An error occurred when compiling.
    pause
    exit
)


cd ..

md result
cd result

for /f %%i in ('dir /b ..\code') do ( 

start ..\atom.bat %%i

)

cd ..

echo Please continue only when EVERY TEST IS DONE.
pause






echo Performing comparison...

cd result

for /f %%i in ('dir /b ..\code') do ( 

echo %%i

cd %%i
fc /3 isim_out.txt mars_out.txt
cd..

)

cd ..

pause

clear.bat



