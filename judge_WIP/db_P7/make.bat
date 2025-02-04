@echo off
for /f %%i in ('dir /b src') do echo verilog work "./src/%%i" >> mips.prj 

call python split.py > nul

call java -jar .\mars\mars.jar db mc CompactDataAtZero a dump .text HexText code_text.txt .\mars\text.asm > nul

call java -jar .\mars\mars.jar db mc CompactDataAtZero a dump .text HexText code_ktext.txt .\mars\ktext.asm > nul

call python fillTo0x4180.py > nul

call python cat_ktext.py > nul

call java -jar .\mars\mars.jar db mc CompactDataAtZero nc ex ./mars/testCode.asm > mars_out.temp 

%xilinx%\bin\nt64\fuse.exe -nodebug -prj mips.prj -o mips.exe mips_tb >nul
IF ERRORLEVEL 1 (
    echo An error occurred when compiling.
    pause
    .\clear.bat
    exit
)
mips.exe -nolog -tclbatch mips.tcl > isim_out.temp
python t.py
python t1.py
fc /3 isim_out.txt mars_out.txt
pause
.\clear.bat

