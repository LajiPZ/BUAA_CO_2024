@echo off
for /f %%i in ('dir /b src') do echo verilog work "./src/%%i" >> mips.prj 
java -jar .\mars\mars.jar db mc CompactLargeText a dump .text HexText code.txt .\mars\testCode.asm > nul
java -jar .\mars\mars.jar db mc CompactLargeText nc coL1 ./mars/testCode.asm > mars_out.txt 
%xilinx%\bin\nt64\fuse.exe -nodebug -prj mips.prj -o mips.exe mips_tb >nul
IF ERRORLEVEL 1 (
    echo An error occurred when compiling.
    pause
    .\clear.bat
    exit
)
mips.exe -nolog -tclbatch mips.tcl > isim_out.temp
python t.py
fc isim_out.txt mars_out.txt
pause
.\clear.bat

