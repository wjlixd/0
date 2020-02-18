@echo off     
cls                
echo                              选择 工具
echo               ********************************************
echo               *    1、 Windows 计算器                    *
echo               *    2、 文本计算器                        *
echo               *    3、 程序员计算器                      *
echo               *    4、 Total Commander                   *
echo               *    5、 16进制编辑器                      *
echo               *    6、 超级编辑器Ultraeidt               *
echo               *    7、 文本图形                          *
echo               *    8、 P4Merge    F1 F2                  *
echo               *    9、 BC4        F1 F2                  *
echo                              等待输入，10秒后默认选择【2】     
choice /c:123456789a /T 10  /D 2  /M  数字键选择操作种类

if errorlevel a goto CHA
if errorlevel 9 goto CH9
if errorlevel 8 goto CH8
if errorlevel 7 goto CH7
if errorlevel 6 goto CH6
if errorlevel 5 goto CH5
if errorlevel 4 goto CH4
if errorlevel 3 goto CH3
if errorlevel 2 goto CH2

:CH1
CALC
goto end

:CH2 
e:\文本计算器\tcal.exe
goto end 

:CH3 
e:\程序员计算器\程序员计算器.exe
goto end


:CH4
E:\TC90\Totalcmd.exe
goto end

:CH5
E:\16进制编辑器.exe
goto end

:CH6
E:\UltraEdit26\uedit32.exe
goto end

:CH7
E:\TextDraw.exe
goto end

:CH8
C:\Progra~1\Perforce\p4merge.exe %1 %2
goto end

:CH9
C:\Progra~1\Compareit\wincmp3.exe %1 %2
goto end

:CHA
echo 正常退出
:end