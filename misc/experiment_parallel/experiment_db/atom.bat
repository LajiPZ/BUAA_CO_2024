@echo off

echo %1
md %1
cd %1
java -jar ..\..\mars.jar db mc CompactDataAtZero a dump .text HexText code.txt ..\..\code\%1 > nul
java -jar ..\..\mars.jar db mc CompactDataAtZero nc ig coL1 ..\..\code\%1  > mars_out.temp
md temp
call xcopy /s /e /y ..\..\temp\ .\temp > nul

cd temp
copy ..\code.txt code.txt > nul
call mips.exe -nolog -tclbatch ..\..\..\mips.tcl > ..\isim_out.temp
copy isim.wdb ..\isim.wdb > nul
cd ..
python ..\..\isim_filter.py > nul
python ..\..\mars_filter.py > nul
del *.temp

rmdir /s /q temp
cd ..
exit