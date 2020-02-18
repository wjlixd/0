@echo off
cls
time/T
echo  在所有文件中查找【 %1 】完成 ,注意不包含 macro.h 
echo **********************************************************************
findstr /I /N /F:Findlist.txt %1