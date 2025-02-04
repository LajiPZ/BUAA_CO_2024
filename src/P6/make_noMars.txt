@echo off
for /f %%i in ('dir /b src') do echo verilog work "./src/%%i" >> mips.prj 
call %xilinx%\bin\nt64\fuse.exe -nodebug -prj mips.prj -o mips.exe mips_tb >nul
IF ERRORLEVEL 1 (
    echo An error occurred when compiling.
    pause
    .\clear.bat
    exit
)
call mips.exe -nolog -tclbatch mips.tcl > isim_out.temp
call findstr "@" isim_out.temp > isim_out.txt
call type isim_out.txt
call pause
call .\clear.bat
