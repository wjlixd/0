; UART ת I2C ����

include "defmcu.h"
include	"option.h"
include "macro.h"
include "public2018.h"
include	"PortDef.h"
include	"ConstDef.h"
include	"RamDef.h"
include	"Mini4X8LED.H"

/*     

	OTP ѡ�
	Target Power    	:    Using ICE
	RCOUT				:    OSC
	Setup Time  		:    288ms
	OSC  				:    12M����
	CLKS   				:    2Clocks
	ENWDT				:    Enable 
	ResetEN  			:    Disable 
    PCB�ļ�����          ��   2019.02.05

    UART ���ֽڶ�д�Ѿ����,I2C����Э������·���

    �ϵ�������£�
       
    1��I2C �豸��ַ  ��   08  A0
    2��I2C ʱ��     ��   07  30US
    3��SDA,SCL  �����������
    4��SDA,SCL  Ϊ����˿�
    5��UARTͨ�Ų����� ��9600 B/S,   ֧�ֶ��������ٲã� ֧�ִ��豸����ʱ��

*/

m_test  macro
    MOV     A,@0xF
    XOR     PORT5,A
endm

M_EnCTS  macro

endm

M_DisCTS macro

endm
	
    C_DefaultTcc    == 0x70

;//NOTE: ��ʼ
	ORG  	0x00
	JMP 	Reset  ; 0
DefaultClock:
    RETL    (C_DefaultTcc  + PortPH_Init<<2)        ; ��������ѡ��
Tx_PackStartErr: 
    MOV     A,@0x21             ;��ͷ����
	JMP     Tx_ReturnValue

Tx_PackEndErr:                  ;��β����
    MOV     A,@0x22
	JMP     Tx_ReturnValue

Tx_PackSizeErr:  
    MOV     A,@0x23             ;���յ� ���ݰ���С����
	JMP     Tx_ReturnValue
	
	ORG     0x08
	JMP 	Intext    ;�жϵ�ַ


LShiftBits:
    ADD     PC,A
    RETL    @1<<0
    RETL    @1<<7
    RETL    @1<<6
    RETL    @1<<5
    RETL    @1<<4
    RETL    @1<<3
    RETL    @1<<2
    RETL    @1<<1

;**********************************

;**********************************
I2CClockTable:           ;������ʾֵ
    ADD     PC,A

    RETL    @0x00        ; 0  
    RETL    @0x01        ;   
                               
    RETL    @0x00        ; 1  
    RETL    @0x02        ;   
                               
    RETL    @0x00        ; 2  
    RETL    @0x03        ;   
                               
    RETL    @0x00        ; 3  
    RETL    @0x04        ;   
                               
    RETL    @0x00        ; 4  
    RETL    @0x05        ;   
                               
    RETL    @0x00        ; 5  
    RETL    @0x20        ;   
                               
    RETL    @0x00        ; 6  
    RETL    @0x25        ;   
                               
    RETL    @0x00        ; 7  
    RETL    @0x30        ;   

    RETL    @0x00        ; 8
    RETL    @0x50        ; 
     
    RETL    @0x00        ; 9
    RETL    @0x60        ; 
 
    RETL    @0x01        ; 10
    RETL    @0x00        ; 
 
    RETL    @0x02        ; 11
    RETL    @0x00        ; 
 
    RETL    @0x05        ; 12
    RETL    @0x00        ; 
 
    RETL    @0x07        ; 13
    RETL    @0x00        ; 
 
    RETL    @0x10        ; 14
    RETL    @0x00        ; 
 
    RETL    @0x70        ; 15
    RETL    @0x00        ; 



I2C_CONT_table:
    ADD     PC,A
    RETL    @0b01000000;    ; 0
    RETL    @0b01000000;    ; 1
    RETL    @0b01000001;    ; 2
    RETL    @0b01000010;    ; 3
    RETL    @0b01000011;    ; 4
    RETL    @0b01000100;    ; 5
    RETL    @0b01000101;    ; 6
    RETL    @0b01000111;    ; 7

I2C_TCC_Table:
    ADD     PC,A
    RETL    @50       ; 0   20US
    RETL    @140      ; 1   50US
    RETL    @145      ; 2   0.1MS
    RETL    @148      ; 3   0.2MS
    RETL    @186      ; 4   0.5MS
    RETL    @186      ; 5   1MS
    RETL    @186      ; 6   2MS
    RETL    @255;117      ; 7   5MS
I2CWaitTable:         ; 
    ADD     PC,A      ;  ( 3*A+7 )/6 US     ; A = 1,   4US
    RETL    @1        ; 0   2   US
    RETL    @2        ; 1   2.5   US
    RETL    @3        ; 2   3   US
    RETL    @5        ; 3   4.5    US
    RETL    @8        ; 4   5    US
    RETL    @37       ; 5   20   US
    RETL    @47       ; 6   25   US
    RETL    @57       ; 7   30   US
    
;//NOTE: UartTxMode
UartTxMode:
    JBS     SysFlag,F_TxEnd
    JMP     main

    MOV     A,TxCmd
    ADD     PC,A
    JMP     ResetUartRx         ; ���� OK����ɽ���UART����
    JMP     I2CReadNextData     ; ��I2C����һ����ɣ�����һ��
    JMP     $                   ; ���λ��WDT ��λ    
    JMP     ProbeI2CAddrNext    ; PROBE addr 
    JMP     ProbeNextWait       ; �ȴ�
    JMP     I2CWriteNextGroup   ; I2Cд��һ������


;//NOTE: I2CCmdTable
I2CCmdTable:    
    ADD     PC,A
    JMP     Cmd_Reset           ;  0      WDT ��ʱ���ָ�Ĭ������
    JMP     I2CReadData         ;  1  
    JMP     I2CWriteData        ;  2    
    JMP     ReadI2cDevAddr      ;  3   
    JMP     SetI2CDevAddr       ;  4   
    JMP     ReadI2cClock        ;  5      
    JMP     SetI2CClock         ;  6  
    JMP     ReadI2cUpperRes     ;  7   
    JMP     SetI2CUpperRes      ;  8   
    JMP     ProbeI2CAddr        ;  9

    C_MaxCmd    ==  $- I2CCmdTable -1   ; ���������

;//NOTE: main
main:
	WDTC

    C_RxMode    ==  0
    C_TxMode    ==  1
    C_RxData    ==  2

    MOV     A,OpMode
    ADD     PC,A
    JMP     UartRxMode
    JMP     UartTxMode
    JMP     UartRxData
    JMP     $                    ;������ WDT OUT

;********************************************


;;*******************************************************
;//NOTE: Intext                             ; ��ʱ���жϣ�32MSһ�Σ���ʱ��ʱ
Intext:
    PUSHStack

    JBS     IntFlag,ICIF
    JMP     _IntIfTcif
 
	JBC     Rx_Port,Rx_B
	JMP     _IntRxOver

    MOV     A,@TccMask
    IOW     IOCF

    CLRA
    MOV     RF,A                    ; ����жϱ�־
    CLR     RxStep
    INC     RxStep                  ; ��ʼ����λ
   
    JMP     _IntRxResetTcc

_IntRxOver:							; RX ���ǵ�һ����
    CLRA
    MOV     RF,A
	MOV     A,Rx_Port
	JMP     _IntEnd

_IntIfTcif:
    JBS     IntFlag,TCIF
    JMP     _IntEnd

    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,RxStep
    ADD     PC,A            
    JMP     _IntRxWait          ;00
    JMP     _IntRxBit           ;01
    JMP     _IntRxBit           ;02
    JMP     _IntRxBit           ;03
    JMP     _IntRxBit           ;04
    JMP     _IntRxBit           ;05
    JMP     _IntRxBit           ;06
    JMP     _IntRxBit           ;07
    JMP     _IntRxBit           ;08
    JMP     _IntRxStopBit       ;09
                                ;
    JMP     _IntTx_Start        ;10
    JMP     _IntTx_Bit          ;11
    JMP     _IntTx_Bit          ;12
    JMP     _IntTx_Bit          ;13
    JMP     _IntTx_Bit          ;14
    JMP     _IntTx_Bit          ;15
    JMP     _IntTx_Bit          ;16
    JMP     _IntTx_Bit          ;17
    JMP     _IntTx_Bit          ;18
    JMP     _IntTx_Stop         ;19
    JMP     _IntTx_StopEnd      ;20
    JMP     _IntI2C             ;21

_IntRxStopBit:
    JBS     Rx_Port,Rx_B
    JMP     _IntRxNextFrame     ; ֡�������ݲ����棬���յڶ�������

    MOV     A,RxBufPtr          ; ֡��ȷ����������
    MOV     RamSelReg,A
    MOV     A,RxData
    MOV     R0,A

    MOV     A,@RxBuf+C_RxBufSize
    SUB     A,RxBufPtr
    JBS     StatusReg,CarryFlag
    INC     RxBufPtr
_IntRxNextFrame:
    MOV     A,@ICMask + TccMask
    IOW     IOCF
    CLR     RxStep                          ; IC�ж����ڽ���RX�źţ� TCC�ж����ڼ�ʱ��������ʱ��������Ϊ�������ݰ�����
    BS      SysFlag,F_RxByte

_IntRxResetTcc:
    MOV     A,@~C_UartTcc1P5
    MOV     TCC,A
    MOV     A,@C_UartCont
    CONTW
    JMP     _IntTccEnd

_IntRxBit:
    BC      StatusReg,CarryFlag
    JBC     Rx_Port,Rx_B
    BS      StatusReg,CarryFlag
    JBS     Rx_Port,Rx_B
    BC      StatusReg,CarryFlag
    RRC     RxData
    INC     RxStep
    JMP     _IntTccEnd

;*************************************************
_IntTx_Start:
    MOV     A,TxBufPtr
    SUB     A,TxBufEndPtr
    JBC     StatusReg,CarryFlag
    JMP     $+4

    BS      SysFlag,F_TxEnd
    CLR     TxStep
    JMP     _IntTccEnd

    BC      Tx_Port,Tx_B

    MOV     A,TxBufPtr
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     TxData,A
    INC     TxBufPtr

    INC     TxStep
    JMP     _IntTccEnd

_IntTx_Bit:
    JBC     TxData,0
    BS      Tx_Port,Tx_B
    JBS     TxData,0
    BC      Tx_Port,Tx_B
    RRC     TxData
    INC     TxStep
    JMP     _IntTccEnd

_IntTx_Stop:
    BS      Tx_Port,Tx_B
    INC     TxStep
    JMP     _IntTccEnd

_IntTx_StopEnd:
    MOV     A,@C_TxStartStep
    MOV     TxStep,A
    JMP     _IntTccEnd

_IntRxWait:
    MOV     A,TimerCnt
    JBC     StatusReg,ZeroFlag
    JMP     _IntTccEnd

    DJZA    TimerCnt                ;  ��N ����1
    MOV     TimerCnt,A
    JMP     _IntTccEnd
;*************************************************
_IntI2C:
    BS      SysFlag,F_WaitTime
_IntTccEnd:
    BCTCIF                          ; ����жϱ�־
_IntEnd:    
    POPStack
    reti
;*************************************************

;*****************************************
;//NOTE: Reset
Reset:
	DISI
	ClrRam

	InitPort20181204
    CALL    DefaultClock
    MOV     I2CCLOCK,A

    MOV     A,@0xA0
    MOV     I2CDevAddr,A
    MOV     A,@0xFF
    MOV     I2CDevAddr+1,A
    MOV     A,@0X20
    JMP     Tx_ReturnValue          ; ��λ����ʾ 0X20

;******************************************************************
;//NOTE: ResetUartRx
;****************************************************************
ResetUartRx:
    DISI

    MOV     A,@RxBuf
    MOV     RxBufPtr,A          ; �ָ�����ָ��

    MOV     A,@RxBuf            ; ���������
    MOV     RamSelReg,A
    MOV     A,@C_RxBufSize
    MOV     Prgtmp1,A

    CLR     R0
    INC     RamSelReg
    DJZ     Prgtmp1
    JMP     $-3

    CALL    SetUart_TCC
    ENI
    M_EnCTS

    CLR     OpMode              ; ����Ϊ UART RX MODE
    CLR     TimerCnt            ;  = 0,����ʱ, =1 ��ʱ
    JMP     main
;****************************************************************
I2CReadNextData:
    DISI
    MOV     A,TxBuf+2
    SUB     A,@C_ReadBufSize
    JBC     StatusReg,CarryFlag
    JMP     ResetUartRx

    MOV     A,@C_ReadBufSize
    ADD     TxBuf+1,A
    SUB     TxBuf+2,A

    JMP     _I2CReadDataNext

;*****************************************
;   7E 02 03 7E
;       |  |  |  
;       |  |  +------------------------ ����
;       |  +--------------------------- UART ת I2C Э����� 3 - WDT��ʱ���ָ�Ĭ������
;       +------------------------------ ���ݰ��ֽ���                                                               
Cmd_Reset:
    MOV     A,@1
    MOV     TxBuf+1,A
    MOV     A,@TxBuf+1
    MOV     TxBufPtr,A
    MOV     TxBufEndPtr,A

    MOV     A,@C_TxCmd_Reset
    JMP     _TxCmdSetUart          
;******************************************************************
;//NOTE:  ���ر�
Tx_ReturnOk:     
Tx_I2COk:
	MOV     A,@01
	JMP     Tx_ReturnValue


Tx_PackError:
    MOV     A,@0x24             ;I2C �����ֲ���ȷ
	JMP     Tx_ReturnValue

_RxPackErr:
    MOV     A,@0x25             ; дI2C�ֽ���Ϊ0
	JMP     Tx_ReturnValue

Tx_DevAddrSizeErr:
    MOV     A,@0x26
	JMP     Tx_ReturnValue

_RxPackEndErr:
    MOV     A,@2                ; ���ݰ�������
    JMP     Tx_ReturnValue

Tx_I2C_SancFail:
    BC      SysFlag,F_SDA_SancFail      ;�� F_CmdReset ���ã��������
    MOV     A,@4
    JMP     Tx_ReturnValue

Tx_I2CErr:       
    MOV     A,@03

Tx_ReturnValue:    
    DISI
    MOV     TxBuf+1,A
    MOV     A,@1
    JMP     _SetReturnConfigData
;*****************************************
_SetReturnConfigData2:
    MOV     A,@2
    JMP     _SetReturnConfigData
_SetReturnConfigData3:
    MOV     A,@3

_SetReturnConfigData:
    ADD     A,@TxBuf
    MOV     TxBufEndPtr,A

    MOV     A,@TxBuf+1
    MOV     TxBufPtr,A
    
    MOV     A,@C_TxCmd_Data
;**************************************************************************
;//NOTE: Tx_SetUartInt

_TxCmdSetUart:
    MOV     TxCmd,A

Tx_SetUartInt:
    MOV     A,@C_TxMode             ; ���� UART ����ģʽ
    MOV     OpMode,A

    MOV     A,@C_UartCont           ;�����ж�ʱ��
    CONTW
    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,@TccMask              ; ����TCC�ж�����
    IOW     IOCF
    CLRA                            ; ����жϱ�־
    MOV     IntFlag,A   

    MOV     A,@C_TxStartStep        ; �´��ж�ʱ�䵽��ʼ��������
    MOV     TxStep,A

    BC      SysFlag,F_TxEnd
    ENI

    JMP     main
;***********************************************************************
_SetI2cTccIntOff:
    DISI
    RET

SetI2C_Tcc:
    CLRA
    IOW     IOCC                            ; �رտ�·�����  SDA,SCL ���0�������л�
    IOR     P_SDA
    OR      A,@(1<<B_SDA)+(1<<B_SCL)
    IOW     P_SDA

    JBS     I2CCLOCK,F_Timer
    JMP     _SetI2cTccIntOff

    DISI
    SWAPA   I2CCLOCK
    AND     A,@C_I2CTimerMask>>4
    CALL    I2C_CONT_table
    CONTW

    SWAPA   I2CCLOCK
    AND     A,@C_I2CTimerMask>>4
    CALL    I2C_TCC_Table
    MOV     TCCbak,A

    MOV     A,@TccMask
    IOW     IOCF

    CLRA
    MOV     IntFlag,A
    MOV     A,@C_I2cWait
    MOV     RxStep,A
    ENI
    RET

;//TODO: SetUart_TCC 
;  �������жϲ�������Ҫ�������²���
;    1���ⲿ����� DISI
;    2�� M_EnCTS
;    3�����ú� , RxBufPtr
; ����Ҫע�⣬ֻ���� RXΪ����ڣ������仯�жϣ������˿�Ҫ�رգ�����򿪣���Ӱ��UART��������  
SetUart_TCC:
;**********************************************************
; �ر� SDA,SCL �� ����UARTӰ��, ֻ�� RX-B ��״̬�жϣ�P63Ϊ�ߵ�ƽ����
    MOV     A,@I2CPortMask
    IOW     IOCC                            ; ��·���

    MOV     A,@1<<Rx_B                      ; RX Ϊ���룬����Ϊ���
    IOW     Rx_Port                         ; ����Ҫע�⣬ֻ���� RXΪ����ڣ������仯�жϣ������˿�Ҫ�رգ�����򿪣���Ӱ��UART��������
    MOV     A,@( I2CPortMask + 1<<Tx_B )    ; SDA,SCL������裬 TX����ߵ�ƽ
    MOV     Rx_Port,A
;**********************************************************
    MOV     A,@ICMask                       ; + TccMask
    IOW     IOCF

    CLRA
    MOV     IntFlag,A

    CLR     RxStep
    BC      SysFlag,F_StartCnt
    MOV     A,Rx_Port
    RET
   
;*************************  mode 0  ************************************
;//NOTE: UartRxMode
UartRxMode:
    MOV     A,TimerCnt
    JBC     StatusReg,ZeroFlag
    JMP     _ChkByte

    DJZA    TimerCnt
    JMP     _ChkByte
    JMP     _RxPackEndErr                   ; ��ʱ����

_ChkByte:
    JBS     SysFlag,F_RxByte
    JMP     main

    BC      SysFlag,F_RxByte
    DEC     TimerCnt                        ; ��ʱ����0���� 1����

    MOV     A,RxPackStart
    XOR     A,@C_PackFlag
    JBS     StatusReg,ZeroFlag
    JMP     Tx_PackStartErr                             ;

    MOV     A,RxPackSize
    JBC     StatusReg,ZeroFlag
    JMP     main                            ; ��û�н��յ�����
    SUB     A,@C_RxBufSize-2
    JBS     StatusReg,CarryFlag
    JMP     Tx_PackSizeErr

    MOV     A,@RxBuf+2
    ADD     A,RxPackSize
    SUB     A,RxBufPtr
    JBS     StatusReg,CarryFlag
    JMP     main                            ; ��û�н������

    MOV     A,@RxPackSize
    ADD     A,RxPackSize
    MOV     RamSelReg,A
    MOV     A,R0
    XOR     A,@C_PackFlag
    JBS     StatusReg,ZeroFlag
    JMP     Tx_PackEndErr

; ���յ����ݣ��ر��жϣ���������
;7E 05 A0 FF 01 05 7E
    DISI
    MOV     A,I2CCmd
    SUB     A,@C_MaxCmd
    JBS     StatusReg,CarryFlag
    JMP     Tx_PackError

    MOV     A,I2CCmd
    JMP     I2CCmdTable


;*****************************************
;//TODO: GetDevAddrBytes , ʹ�� TMP4
;   0A F1 C0  - 2
;   10 F1 C0  - 2
;   15 F1 C0 A0 - 3
GetDevAddrBytes:
    RRCA    I2CDevAddr
    MOV     Prgtmp4,A
    RRC     Prgtmp4
    RRC     Prgtmp4
    MOV     A,@7
    AND     Prgtmp4,A

    MOV     A,I2CDevAddr
    AND     A,@7
    JBS     StatusReg,ZeroFlag
    INC     Prgtmp4
    MOV     A,PrgTmp4
    RET
;*****************************************
;   7E 02 01 7E
;       |  |  |  
;       |  |  +------------------------ ����
;       |  +--------------------------- UART ת I2C Э����� 1 - �� I2C �豸��ַ
;       +------------------------------ ���ݰ��ֽ���                                                               
ReadI2cDevAddr:
    MOV     A,@C_TxCmd_Data
    MOV     TxCmd,A
    
    DISI
    MOV     A,@I2CDevAddr
    MOV     TxBufPtr,A

    INCA    TxBufPtr
    MOV     TxBufEndPtr,A

    JMP     Tx_SetUartInt
;*****************************************
;   7E 02 02 7E
;       |  |  |  
;       |  |  +------------------------ ����
;       |  +--------------------------- UART ת I2C Э����� 2 - �� I2C CLOCK
;       +------------------------------ ���ݰ��ֽ���                                                               
ReadI2cClock:
    SWAPA   I2CCLOCK
    AND     A,@C_I2CDispMask>>4
    MOV     Prgtmp1,A
    MOV     TxBuf+1,A

    BC      StatusReg,CarryFlag
    RLC     PrgTmp1

    MOV     A,PrgTmp1
    CALL    I2CClockTable
    MOV     TxBuf+2,A

    INCA    Prgtmp1
    CALL    I2CClockTable
    MOV     TxBuf+3,A

    JMP     _SetReturnConfigData3   

;********************************************************
;   7E 03 04 01 7E
;       |  |  |  | 
;       |  |  |  +--------------------- ����
;       |  |  +------------------------ 01  - 30US
;       |  +--------------------------- UART ת I2C Э����� 4 - ����I2C CLOCK
;       +------------------------------ ���ݰ��ֽ���                                                               
SetI2CClock:
    MOV     A,@~C_I2CDispMask
    AND     I2CCLOCK,A

    MOV     A,@C_I2CDispMask>>4
    AND     I2CCmd+1,A
    SWAPA   I2CCmd+1
    OR      I2CClock,A

    JMP     Tx_ReturnOk
;********************************************************
; ����RAM����[tmp1] -->��[tmp2] , ��[A]��
; Prgtmp1 - Դ��ַ
; Prgtmp2 - Ŀ���ַ
; [A] - ���Ƹ���
; ʹ��RAM  ,   tmp3,tmp4
CopyRam:
    MOV     Prgtmp3,A

    MOV     A,Prgtmp1
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     Prgtmp4,A

    MOV     A,Prgtmp2
    MOV     RamSelReg,A
    MOV     A,Prgtmp4
    MOV     R0,A

    INC     Prgtmp1
    INC     Prgtmp2
    DJZ     Prgtmp3
    JMP     $-11
    RET
;********************************************************
;   7E 04 05 A0 FF 7E
;       |  |  |  |  |  
;       |  |  |  |  +------------ ����
;       |  |  +--+
;       |  |   +---------------------- I2C �豸��ַ ռ2���ֽ�
;       |  +--------------------------- UART ת I2C Э����� 6 - ����I2C �豸��ַ
;       +------------------------------ ���ݰ��ֽ���                      
;//NOTE: SetI2CDevAddr                                         
SetI2CDevAddr:
    MOV     A,RxBuf+3
    MOV     I2CDevAddr,A
    MOV     A,RxBuf+4
    MOV     I2CDevAddr+1,A

    JMP     Tx_ReturnOk
;********************************************************
;   7E 08 06 00 05 41 9D 5D 53 7E
;      7E 05 A0 FF 01 05 7E
;       |  |  |  |  |  |
;       |  |  |  |  |  +-----------+--- ����Զ�ת��
;       |  |  |  |  |    
;       |  |  |  |  +------------------ �������
;       |  |  |  +--------------------- I2C ��ַ2
;       |  |  +------------------------ I2C ��ַ1
;       |  +--------------------------- ���ݰ��ֽ���
;       +------------------------------ ���ݰ��ֽ���          
;//NOTE: д����                                                     
I2CWriteData:
    MOV     A,RxBuf+4
    JBC     StatusReg,ZeroFlag
    JMP     _RxPackErr
    
    MOV     A,RxBuf+3
    MOV     RxBuf+1,A                   ;  ���ݵ�ַ
    MOV     A,RxBuf+4
    MOV     RxBuf+2,A                   ;  ���ݸ���

I2CWriteNextData: 
    DISI
    MOV     A,@RxBuf+3
    MOV     RxBufPtr,A                  ;  ����ָ��
    ENI
  
    BC      SysFlag,F_StartCnt
    M_EnCTS

    MOV     A,@C_RxData                 ; ���� UART����ʣ������ģʽ
    MOV     OpMode,A
    JMP     main
;***********************************************
I2CWriteNextGroup:
    DISI
    CALL    SetUart_TCC
    JMP     I2CWriteNextData

;***********************************
;  00 0A 11 22 33 44 55 66 77 88 99 AA
;//NOTE:  д���������
UartRxData:
    MOV     A,TimerCnt
    JBC     StatusReg,ZeroFlag
    JMP     _ChkByte1
    DJZA    TimerCnt
    JMP     _ChkByte1
    JMP     _CTSEnd

_ChkByte1:
    JBS     SysFlag,F_RxByte
    JMP     main

    BC      SysFlag,F_RxByte
    DEC     TimerCnt                 ; ��ʱ����0���� 1����
;*******************************************
    CALL    GetReadSize
    ADD     A,@RxBuf+3
    SUB     A,RxBufPtr
    JBS     StatusReg,CarryFlag
    JMP     main
;****************************************************************
_CTSEnd:                                ; CTS �رպ󣬽������ݽ���
;����һ�����ݣ�׼��д��
    MOV     A,RxBuf+3
    XOR     A,@C_PackFlag
    JBS     StatusReg,ZeroFlag
    JMP     _CTSWriteI2cData

    MOV     A,RxBuf+4
    XOR     A,@01
    JBS     StatusReg,ZeroFlag
    JMP     _CTSWriteI2cData

    MOV     A,RxBuf+5
    XOR     A,@C_PackFlag
    JBS     StatusReg,ZeroFlag
    JMP     _CTSWriteI2cData

    MOV     A,@RxBuf+6
    XOR     A,RxBufPtr
    JBC     StatusReg,ZeroFlag
    JMP     Tx_ReturnOk                 ; ���յ� 7E 01 7E ��ֹͣд����

_CTSWriteI2cData:
    M_DisCTS
    CALL    SetI2C_Tcc

    MOV     A,@RxBuf+3
    SUB     A,RxBufPtr
    MOV     Prgtmp1,A                   ; Ҫд�����ݸ���

    MOV     A,RxBuf+1                   ; Ŀ��I2C RAM ��ַ
    MOV     Prgtmp2,A
    MOV     A,@RxBuf+3                  ; Դ����RAM ��ַ
    MOV     RamSelReg,A
    CALL    I2C_WritePageData 
    JBC     SysFlag,F_SDA_SancFail
    JMP     Tx_I2C_SancFail

    XOR     A,@C_I2CNoAckFlag
    JBC     StatusReg,ZeroFlag
    JMP     Tx_I2CErr

    MOV     A,RxBuf+2
    SUB     A,@C_ReadBufSize
    JBC     StatusReg,CarryFlag
    JMP     Tx_I2COk

    MOV     A,@RxBuf+3
    SUB     A,RxBufPtr
    ADD     RxBuf+1,A
    SUB     RxBuf+2,A                  ; �޸� EPROM ��ַ�����ĸ���

    DISI
    MOV     A,@TxBuf+1
    MOV     TxBufPtr,A
    MOV     A,@TxBuf+2
    MOV     TxBufEndPtr,A
    MOV     A,@C_TxCmd_WriteI2C
    JMP     _TxCmdSetUart
;*************************************************
GetReadSize:
    MOV     A,RxBuf+2
    SUB     A,@C_ReadBufSize

    JBC     StatusReg,CarryFlag
    MOV     A,RxBuf+2
    JBS     StatusReg,CarryFlag
    MOV     A,@C_ReadBufSize

    RET
;********************************************************
;   7E 04 07 00 05 7E
;       |  |  |  |  +------ ����
;       |  |  |  |  
;       |  |  |  +--------------------- I2C �����ٸ��ֽ�
;       |  |  +------------------------ I2C �豸��ַ0��ʼ�����ݣ� 0 -������
;       |  +--------------------------- UART ת I2C Э����� 7-������
;       +------------------------------ ���ݰ��ֽ���        
;//NOTE:    I2CReadData                                                    
I2CReadData:
    MOV     A,I2CCmd+1
    MOV     RxBuf+1,A
    MOV     A,I2CCmd+2
    MOV     RxBuf+2,A
_I2CReadDataNext:
    CALL    GetReadSize
    MOV     PrgTmp1,A
;***************************************
    CALL    SetI2C_Tcc

    MOV     A,RxBuf+1
    MOV     Prgtmp2,A                   ; Դi2c ram ��ַ
    
    MOV     A,@RxBuf+3                  ; Ŀ�� RAM ��ַ
    MOV     RamSelReg,A

    CALL    I2C_ReadPageData
    JBC     SysFlag,F_SDA_SancFail
    JMP     Tx_I2C_SancFail

    XOR     A,@C_I2CNoAckFlag
    JBC     StatusReg,ZeroFlag
    JMP     Tx_I2CErr

    DISI
    MOV     A,@RxBuf+3                  ; Ŀ�� RAM ��ַ
    MOV     TxBufPtr,A
    CALL    GetReadSize
    ADD     A,@RxBuf+2
    MOV     TxBufEndPtr,A

    MOV     A,@C_TxCmd_I2CRead
    JMP     _TxCmdSetUart
;********************************************************
;   7E 04 08 01 01 7E
;       |  |  |  |  |
;       |  |  |  |  +--------------------- ����
;       |  |  |  +-----------SCL����
;       |  |  +--------------[SDA]-1��������  ||  B1[SCL]-1������
;       |  +--------------------------- UART ת I2C Э����� 8 - ����I2C ��������
;       +------------------------------ ���ݰ��ֽ���                                                               
SetI2CUpperRes:
    CLR     Prgtmp1
    MOV     A,I2CCmd+1
    JBS     StatusReg,ZeroFlag
    BS      Prgtmp1,(B_SDA+2)
    MOV     A,I2CCmd+2
    JBS     StatusReg,ZeroFlag
    BS      Prgtmp1,(B_SCL+2)

    MOV     A,I2CCLOCK
    AND     A,@~C_I2CPHMask
    OR      A,Prgtmp1
    MOV     I2CCLOCK,A              ; 2λ������I2CCLOCK��

    BC      StatusReg,CarryFlag
    RRC     PrgTmp1
    RRC     PrgTmp1
    MOV     A,@I2CPortMask
    XOR     Prgtmp1,A               ;0-ʹ��������1-��ֹ������Ҫȡ��

    IOR     IOCD
    AND     A,@~I2CPortMask
    OR      A,Prgtmp1
    IOW     IOCD

    JMP     Tx_ReturnOk

;********************************************************
;   7E 02 09 7E
;    |  |  |  | 
;    |  |  |  +--------------------- ����
;    |  |  +--------------------------- UART ת I2C Э����� 9 - ��I2C ��������
;    |  +------------------------------ ���ݰ��ֽ���                                                               
;    +-------------------------------��ʼ
ReadI2cUpperRes:
    CLR     TxBuf+1
    CLR     TxBuf+2
    JBC     I2CCLOCK,(B_SDA+2)
    INC     TxBuf+1

    JBC     I2CCLOCK,(B_SCL+2)
    INC     TxBuf+2
    JMP     _SetReturnConfigData2

;********************************************************
;   7E 02 0A 7E
;    |  |  |  | 
;    |  |  |  +--------------------- ����
;    |  |  +--------------------------- UART ת I2C Э����� A - ��I2C �˿�״̬
;    |  +------------------------------ ���ݰ��ֽ���                                                               
;    +-------------------------------��ʼ
ReadI2cPort:
    CALL    SetI2C_Tcc
    IOR     P_SDA
    OR      A,@I2CPortMask
    IOW     P_SDA

    CALL    Wait3us
    
    CLR     TxBuf+1
    MOV     A,P_SDA
    AND     A,@1<<B_SDA
    JBS     StatusReg,ZeroFlag
    INC     TxBuf+1

    CLR     TxBuf+2
    MOV     A,P_SCL
    AND     A,@1<<B_SCL
    JBS     StatusReg,ZeroFlag
    INC     TxBuf+2

    JMP     _SetReturnConfigData2
;********************************************************

;**********************************************************
;   7E 04 09 00 03 7E
;    |  |  |  |  |  | 
;    |  |  |  |  |  +--------------------- ����
;    |  |  |  +--+--------------̽����ַ����,���FFFF��
;    |  |  +--------------------------- UART ת I2C Э����� C -  ̽��I2C�豸��ַ
;    |  +------------------------------ ���ݰ��ֽ���                                                               
;    +-------------------------------��ʼ

ProbeI2CAddrNext:
    MOV     A,@C_TxCmd_Wait
    MOV     TxCmd,A

    MOV     A,@2
    MOV     TxBuf+1,A
ResetTimerCnt:
    MOV     A,@0xFF
    MOV     TimerCnt,A
    JMP     main

ProbeNextWait:
    DJZA    TimerCnt
    JMP     main
    DJZ     TxBuf+1
    JMP     ResetTimerCnt

ProbeNextAddr:
    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBC     StatusReg,ZeroFlag
    JMP     $+8

;       ��7 λ��ַ��ǰһ�ֽڼ�2
    MOV     A,@2
    ADD     PrgTmp5,A 
    MOV     A,PrgTmp5
    XOR     A,@0xF0
    JBC     StatusReg,ZeroFlag     
    CLR     PrgTmp6
    JMP     _ProbeI2CStart

;       ��10λ��ַ���ڶ��ֽڼ�1
    INC     PrgTmp6
    JBS     StatusReg,ZeroFlag
    JMP     _ProbeI2CStart

    MOV     A,@2                    ; PrgTmp6=0, PrgTmp5 +2
    ADD     PrgTmp5,A
    JBC     PrgTmp5,3
    JMP     Tx_I2COk                ; ɨ�����
    JMP     _ProbeI2CStart


;//NOTE: ProbeI2CAddr
ProbeI2CAddr:
    MOV     A,@0x10
    MOV     PrgTmp5,A               ; ��ַ�� 10��ʼ
    MOV     A,@0xFF
    MOV     PrgTmp6,A

_ProbeI2CStart:
    WDTC
    CALL    SetI2C_Tcc
    CALL    LDevAddr_E2ChkBusy
    JBC     SysFlag,F_SDA_SancFail
    JMP     ProbeNextAddr

    XOR     A,@C_I2CNoAckFlag
    JBC     StatusReg,ZeroFlag
    JMP     ProbeNextAddr

    MOV     A,@C_TxCmd_ProbeAddr
    JMP     ReadI2cDevAddr+1

;***************************************************************
Wait3us:
    JBC     I2CCLOCK,F_Timer
    JMP     _Wait3usTimer

    SWAPA   I2CCLOCK
    AND     A,@C_I2CTimerMask>>4
    CALL    I2CWaitTable

    ADD     A,@0xFF                     ; 3*A+5
    JBS     StatusReg,ZeroFlag
    JMP     $-2
    RET

_Wait3usTimer:
    BC      SysFlag,F_WaitTime
    JBS     SysFlag,F_WaitTime
    JMP     $-1
	RET

; ���²��ִ� macro.h   M_I2CMaster201911 ���ƹ����������޸�
;
C_I2CSclIn_SdaOut   equ     C_I2CBusOut    +  (1<<B_SCL)
C_I2CSclOut_SdaIn   equ     C_I2CBusOut    +  (1<<B_SDA) 
C_I2CBusIn          equ     C_I2CBusOut    +  (1<<B_SCL) + (1<<B_SDA)



_E2ErrorNoAck:
_ErrorBusBusy:
	MOV		A,@0xEF
	RET

;//NOTE: I2C_BUSo0
I2C_BUSo0:                              ; SCL ���0�� SDA ���0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy
	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	BC      P_SCL,B_SCL
	BC      P_SDA,B_SDA
    RET
;//NOTE: I2C_BUSo
I2C_BUSo:                               ; SCL ����˿ڣ�SDA����˿�
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy

	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	RET
;**************************�޸Ĵ���**2018.07.12*******************************
; ��ʼǰ�� SCL,SDA �����ͷ�״̬
;//NOTE:   I2C_Start   
;              SDA,SCLҪ����������
I2C_Start:
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy
    
;//NOTE:I2C_SCLi_SDAo0
I2C_SCLi_SDAo0:
	MOV     A,@C_I2CSclIn_SdaOut        ; SCL =1 ,SDA 1->0
	IOW     P_SDA
	BC      P_SDA,B_SDA
    ; RET
    JMP     Wait3us
;//NOTE:I2C_SCLi_SDAo
I2C_SCLi_SDAo:
	MOV     A,@C_I2CSclIn_SdaOut        ; SCL =1 ,SDA 1->0
	IOW     P_SDA
	RET
;//NOTE:I2C_SCLo_SDAo
I2C_SCLo_SDAo:                          ; SCL ֻ�����Ϊ0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy   
	MOV     A,@C_I2CBusOut              ; ռ�������������
	IOW     P_SDA
    BC      P_SCL,B_SCL
	RET
	

;*************************************************
;//NOTE:  I2C_SendAck
I2C_SendAck:
	CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    CALL    Wait3us
    CALL    I2C_SCLi_SDAo               ; SCL=1, SDA=0
    CALL    Wait3us
    RET
;*************************************************	
; �����ַ���A��  , EPROM ����һ��������
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
;//NOTE:  I2C_WriteCommand
I2C_WriteCommand:
	MOV		Prgtmp3,A			; ��������
	MOV		A,@8
	MOV		Prgtmp4,A

_I2CWriteCommandLoop:
	CALL    I2C_SCLo_SDAo

	JBS		Prgtmp3,7           ; ���� SDA
	BC		P_SDA,B_SDA
	JBC		Prgtmp3,7
	BS		P_SDA,B_SDA	;

    CALL    Wait3us
	CALL    I2C_SCLi_SDAo	    ; SCL=1
    CALL    Wait3us

	RLC		Prgtmp3
	DJZ		Prgtmp4
	JMP		_I2CWriteCommandLoop

;	RET	
;*****************************************************
;//NOTE: I2C_GetAck
I2C_Get1Bit:
I2C_SendNoAck:
I2C_GetAck:
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy

	MOV     A,@C_I2CSclOut_SdaIn
	IOW     P_SCL
	BC      P_SCL,B_SCL

    CALL    Wait3us

;//NOTE:I2C_BusIn
I2C_BusIn:
	MOV     A,@C_I2CBusIn
	IOW     P_SCL
    CALL    Wait3us
	RET
	

;******************************************************
;��һ���ֽ�,  
;//TODO:  I2C_ReadByte
I2C_ReadByte:					; �˳�ʱ�� SCL = 0
	CLR   	Prgtmp3
	MOV		A,@8
	MOV		Prgtmp4,A
_I2C_ReadByteLoop:				; ѭ���У�SCL ���� = 11 �� Լ 11*0.56= 6.2us = 160K �ٶ�
    CALL    I2C_Get1Bit

	BC		StatusReg,CarryFlag
	JBC		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RLC		Prgtmp3

	DJZ		Prgtmp4
	JMP		_I2C_ReadByteLoop

	MOV		A,Prgtmp3			; ���������ݷ���A��	
	RET

;*************************************************	
;   RamSelReg, ��ǰд�����ݴ��λ��
;   PrgTmp5   �豸��ַ      ��  B0 - 0 д���ݣ� B0-1 ������
;   Prgtmp1,д���ֽ���
;   Prgtmp2,  EPROM ��ַ�����ֽ�
;//TODO:    I2C_ReadPageData
I2C_ReadPageData:
    BC      PrgTmp5,0               ; ����豸��ַδλΪ1����У��Ϊ0

	CALL	I2C_Start
	MOV		A,PrgTmp5
	CALL	I2C_WriteCommand
	JBC     P_SDA,B_SDA		
	JMP		_E2ErrorNoAck

    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag
    JMP     _I2C_ReadPage_ByteAddr

	MOV		A,PrgTmp6               ; 10λ��ַ ����һ���ֽ�
	CALL	I2C_WriteCommand    	; �豸��ַ,ʹ��tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_ReadPage_ByteAddr:
	MOV		A,Prgtmp2
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck
;********************************************************************    
    CALL    I2C_GetAck                  ; ռ�����ߣ��ͷ�����
; �˴���������һ��ʱ�ӣ�ǰһ����ACK����ʱ�����豸���0����ʾ�յ���������һ��ʱ��
; ֪ͨ���豸�Ѿ�������ACK�������ͷ������ˡ�������豸���ͷ����ߣ�����һ����ʼ
; �������
;********************************************************************    
	CALL	I2C_Start
	INCA    PrgTmp5
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    JMP     $+2
_I2CReadPageLoop:
	CALL	I2C_SendAck

	CALL	I2C_ReadByte
	MOV		R0,A
	INC		RamSelReg

	DJZ		Prgtmp1
	JMP		_I2CReadPageLoop

;*************************************************
;  ������� NOACK ���ŷ��� STOP ָ��
    CALL    I2C_SendNoAck
;//mark:   I2C_Stop
I2C_Stop:
    CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    CALL    Wait3us
    CALL    I2C_SCLi_SDAo               ; SCL=1, SDA=0
    CALL    Wait3us
    JMP     I2C_BusIn                   ; SCL=1, SDA=1

;*************************************************	
;   RamSelReg, ��ǰд�����ݴ��λ��
;   PrgTmp5��PrgTmp6   �豸��ַ  7λ��10λ    ��  B0 - 0 д���ݣ� B0-1 ������
;   Prgtmp1,  д���ֽ���
;   Prgtmp2,  EPROM ��ַ�����ֽ�
;//TODO:I2C_WritePageData
I2C_WritePageData:
    BC      PrgTmp5,0               ; ����豸��ַδλΪ1����У��Ϊ0

	CALL	I2C_Start
	MOV		A,PrgTmp5               ; дEPROM �豸��ַ
	CALL	I2C_WriteCommand    	; �豸��ַ,ʹ��tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag
    JMP     _I2C_WritePage_ByteAddr

	MOV		A,PrgTmp6               ; 10λ��ַ ����һ���ֽ�
	CALL	I2C_WriteCommand    	; �豸��ַ,ʹ��tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_WritePage_ByteAddr:
	MOV		A,Prgtmp2
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_WritePageLoop:
	MOV		A,R0
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		_I2C_WritePageLoop	

	JMP		I2C_Stop                ; �Ż�����


;*************************************************	
LDevAddr_E2ChkBusy:
	CALL	I2C_Start
	MOV		A,PrgTmp5               ; дEPROM �豸��ַ
	CALL	I2C_WriteCommand    	; �豸��ַ,ʹ��tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag
    JMP     I2C_Stop                ; 7 λ��ַ��Ӧ��

	MOV		A,PrgTmp6               ; 10λ��ַ ����һ���ֽ�
	CALL	I2C_WriteCommand    	; �豸��ַ,ʹ��tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    JMP     I2C_Stop                ; 10λ��ַ��Ӧ��
