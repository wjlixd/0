@echo off
cls
time/T
echo  在*.H 查找 %1 完成 ,注意不包含 main.asm
echo **********************************************************************
findstr /I /N /F:FindlisH.txt %1