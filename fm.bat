@echo off
cls
time/T
echo  在main.asm 查找 %1 完成 
echo **********************************************************************
findstr /I /N %1 main.asm