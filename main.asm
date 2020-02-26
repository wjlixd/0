
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
   chksum:    Relay4Board
0�� 5A0B  - 0  - ʹ�õ��̵���ģ�飬EPROMѡ��ַ���޾��� ,С�̵�����HF49FD����̵���, SRD-05VDC-SL-C
1�� 73D2  - 1    ʹ��4�̵���ģ�飬 EPROMѡ��ַ�������� , �ϰ汾PCB -2018
2�� 73D4  - 2  - ʹ��4�̵���ģ�飬 EPROMѡ��ַ�������� ���°汾PCB -2019
3�� C113  - 3  - ʹ�õ��̵���ģ�飬IO�˿�ѡ��ַ���޾���, SOP14 
4�� 4D52  - 4  - ʹ�õ��̵���ģ�飬IO�˿�ѡ��ַ���޾���, SOP8  

5�� 588A  - 0    ʹ�õ��̵���ģ�飬EPROMѡ��ַ���޾��� ,��̵���,    PCB�汾 2019.05.10 SlaverSDA/SlaverSCL��λ����    

	OTP ѡ�
	Target Power    	:    Using ICE
	RCOUT				:    P64
	Setup Time  		:    18ms
	OSC  				:    IRC
	CLKS   				:    2Clocks
	ENWDT				:    Disable 
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
GroupID:                        ; Ĭ�� OPT3 ��ʼֵ
    RETL    @0xF6               ; 12λ
    RETL    @0xFE
    ; RETL    @0xF0   + (1<<1)    ; 10λ��ַ��ʽ�� ��2λ
    ; RETL    @0x38               ; 10λ��ַ��ʽ�� ��8λ
 


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
    JBS     StatusReg,CarryFlag
    JMP     _InitUartTx
    CLR     CtrlByte
    JMP     main

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
    MOV     A,@0xA0
    MOV     PrgTmp5,A
    MOV     A,@0xFF
    MOV     PrgTmp6,A

    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A
    JMP     main

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
    JBC     TxData,0
    BS      Tx_Port,Tx_B
    JBS     TxData,0
    BC      Tx_Port,Tx_B
    RRC     TxData
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

    BC      SystemFlag,F_TxD        ; תΪ��I2C����
    BC      SystemFlag,F_DataValid  ; ���������Чλ
    JMP     Error_DevAddrDiff       ; STEP= 0,���ö˿ڣ�10λ��ַƥ�����

;**********************************************************************
