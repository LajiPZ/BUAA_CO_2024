@echo off
for /f %%i in ('dir /b src') do echo verilog work "./src/%%i" >> mips.prj 
%xilinx%\bin\nt64\fuse.exe -nodebug -prj mips.prj -o mips.exe mips_tb >nul
IF ERRORLEVEL 1 (
    echo An error occurred when compiling.
    pause
    .\clear.bat
    exit
)
mips.exe -nolog -tclbatch mips.tcl > isim_out.temp
findstr /b "^@" isim_out.temp > isim_out.txt
type isim_out.txt
pause
%xilinx%\bin\nt64\isimgui.exe -view isim.wdb
.\clear.bat
