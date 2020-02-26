;   I2C ���豸��ַ  F6FE
;   �������ݣ�ת����UART TX ������UART���գ� ���Ϻ���˾���ĵ�����ݲɼ�
;   2020��02.27   CHKSUM: EC7C
; 
; 
include "defmcu.h"
include	"option.h"
include "public.h"
include	"PortDef.h"
include "macro.h"
include	"RamDef.h"
include	"ConstDef.h"
include	"Mini4X8LED.H"
;****************************************************************

/*       

	OTP ѡ�
	Target Power    	:    Using ICE
	RCOUT				:    P64
	Setup Time  		:    18ms
	OSC  				:    IRC
	CLKS   				:    2Clocks
	ENWDT				:    EN 
	ResetEN  			:    Disable 
*/


;//todo: ��ʼ
	ORG  	0x00
	JMP 	McuRst  ; 0
	NOP
	NOP
	NOP                                                                                                                                                    
	NOP
	NOP
	NOP
	NOP


	ORG     0x08
    PUSHStack
    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,TxStep
    ADD     PC,A         
    JMP     _IntTx_Start        ;0
    JMP     _IntTx_Bit          ;1
    JMP     _IntTx_Bit          ;2
    JMP     _IntTx_Bit          ;3
    JMP     _IntTx_Bit          ;4
    JMP     _IntTx_Bit          ;5
    JMP     _IntTx_Bit          ;6
    JMP     _IntTx_Bit          ;7
    JMP     _IntTx_Bit          ;8
    JMP     _IntTx_Stop         ;9
    JMP     _IntTx_StopEnd      ;10

DefaultContrast:
	RETL	@3
DefaultDevAddr:
    RETL    @0xF6               ; 
    RETL    @0xFE


    M_I2CSlaver201911

;*****************************************
;//todo: main
IntPortEnd:
main:
	WDTC

    JBC     SystemFlag,F_TxD
    JMP     ChkTxEnd

	JBS		SystemFlag,F_DataValid
	JMP		IntPort
	
	BC		SystemFlag,F_DataValid               ; I2C���߽��յ� �̵���״̬�ı����������
    JBC     SystemFlag,F_WDevAddr
    CALL    UpdatDevAddr
  
	MOV     A,CtrlByte
    JBC     StatusReg,ZeroFlag
    JMP     main

    MOV     A,@DataBufEnd-CtrlByte+1
    SUB     A,CtrlByte
    JBC     StatusReg,CarryFlag
    JMP     Tx2I2CInit

_InitUartTx:
    DISI
    BS      SystemFlag,F_TxD
    MOV     A,@CtrlByte+1
    MOV     TxBufPtr,A

    MOV     A,@CtrlByte
    ADD     A,CtrlByte
    MOV     TxBufEndPtr,A

    MOV     A,@C_UartCont           ;�����ж�ʱ��
    CONTW
    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,@TccMask              ; ����TCC�ж�����
    IOW     IOCF
    CLRA                            ; ����жϱ�־
    MOV     IntFlag,A   

    CLR     TxStep                  ; ��ʼ����

    BC      SystemFlag,F_TxEnd
    ENI
    JMP     main





;//todo: McuRst
McuRst:
	DISI
	ClrRam

	InitPort20181204
    DISI

	MOV     A,I2CS_Port
	AND		A,@I2CSMask
	MOV		SystemFlag,A            			;�𶯺����ȶ� I2C �˿����ݣ���ʼ��
    BS      SystemFlag,F_SDAInput

    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    MOV     CtrlByte+1,A                        ; ��λ����ʾ  30H

    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A
    MOV     CtrlByte+2,A                        ; ��λ����ʾ  30H

    MOV     A,@02
    MOV     CtrlByte,A

    JMP     _InitUartTx

;***************************************** 
; ���豸ͨ��06,07��ַ�޸����豸��ַ����Ҫ������EPROM��
UpdatDevAddr:
    RET
;***************************************** 


_IntTx_Start:
    MOV     A,TxBufPtr
    SUB     A,TxBufEndPtr
    JBS     StatusReg,CarryFlag
    JMP     _IntTx_Over

    BC      Tx_Port,Tx_B

    MOV     A,TxBufPtr
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     TxData,A
    INC     TxBufPtr

    JMP     _IntNextStep

_IntTx_Bit:
    RRC     TxData
    JBS     StatusReg,CarryFlag
    BC      Tx_Port,Tx_B
    JBC     StatusReg,CarryFlag
    BS      Tx_Port,Tx_B
    JMP     _IntNextStep

_IntTx_Stop:
    BS      Tx_Port,Tx_B
    JMP     _IntNextStep

_IntTx_StopEnd:
    CLR     TxStep
    JMP     _IntTccEnd

_IntTx_Over:
    BS      SystemFlag,F_TxEnd
    CLRA
    IOW    IOCF                     ; �ر��ж�

_IntNextStep:
    INC     TxStep
_IntTccEnd:
    BCTCIF                          ; ����жϱ�־   
    POPStack
    reti

;**********************************************************************
ChkTxEnd:
    JBS     SystemFlag,F_TxEnd
    JMP     main    
Tx2I2CInit:
    BC      SystemFlag,F_TxD        ; תΪ��I2C����
    BC      SystemFlag,F_DataValid  ; ���������Чλ
    MOV     A,@~( 1<<F_TxD | 1<< F_DataValid | 1<<F_AddrMarried   )
    AND     SystemFlag,A
    CLR     I2CStep
    JMP     main
    ; JMP     Error_DevAddrDiff       ; STEP= 0,���ö˿ڣ�10λ��ַƥ�����

;**********************************************************************
