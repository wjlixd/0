@echo off     
cls                
echo                              ѡ�� ����
echo               ********************************************
echo               *    1�� Windows ������                    *
echo               *    2�� �ı�������                        *
echo               *    3�� ����Ա������                      *
echo               *    4�� Total Commander                   *
echo               *    5�� 16���Ʊ༭��                      *
echo               *    6�� �����༭��Ultraeidt               *
echo               *    7�� �ı�ͼ��                          *
echo               *    8�� P4Merge    F1 F2                  *
echo               *    9�� BC4        F1 F2                  *
echo                              �ȴ����룬10���Ĭ��ѡ��2��     
choice /c:123456789a /T 10  /D 2  /M  ���ּ�ѡ���������

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
e:\�ı�������\tcal.exe
goto end 

:CH3 
e:\����Ա������\����Ա������.exe
goto end


:CH4
E:\TC90\Totalcmd.exe
goto end

:CH5
E:\16���Ʊ༭��.exe
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
echo �����˳�
:end