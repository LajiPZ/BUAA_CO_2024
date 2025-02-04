@echo off

echo %1
md %1

copy ..\code\%1 .\%1\testCode.asm > nul

cd %1

call python ..\..\split.py > nul

call java -jar ..\..\mars.jar db mc CompactDataAtZero a dump .text HexText code_text.txt .\text.asm > nul

call java -jar ..\..\mars.jar db mc CompactDataAtZero a dump .text HexText code_ktext.txt .\ktext.asm > nul

call python ..\..\fillTo0x4180.py > nul

call python ..\..\cat_ktext.py > nul

java -jar ..\..\mars.jar db mc CompactDataAtZero nc ex .\testCode.asm  > mars_out.temp

md temp
call xcopy /s /e /y ..\..\temp\ .\temp > nul

cd temp
copy ..\code.txt code.txt > nul
call mips.exe -nolog -tclbatch ..\..\..\mips.tcl > ..\isim_out.temp
copy isim.wdb ..\isim.wdb > nul
cd ..
python ..\..\isim_filter.py
python ..\..\mars_filter.py
del *.temp

rmdir /s /q temp
cd ..
exit