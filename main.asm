
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
0、 5A0B  - 0  - 使用单继电器模块，EPROM选地址，无晶振 ,小继电器，HF49FD，大继电器, SRD-05VDC-SL-C
1、 73D2  - 1    使用4继电器模块， EPROM选地址，带晶振 , 老版本PCB -2018
2、 73D4  - 2  - 使用4继电器模块， EPROM选地址，带晶振 ，新版本PCB -2019
3、 C113  - 3  - 使用单继电器模块，IO端口选地址，无晶振, SOP14 
4、 4D52  - 4  - 使用单继电器模块，IO端口选地址，无晶振, SOP8  

5、 588A  - 0    使用单继电器模块，EPROM选地址，无晶振 ,大继电器,    PCB版本 2019.05.10 SlaverSDA/SlaverSCL脚位调换    

	OTP 选项：
	Target Power    	:    Using ICE
	RCOUT				:    P64
	Setup Time  		:    18ms
	OSC  				:    IRC
	CLKS   				:    2Clocks
	ENWDT				:    Disable 
	ResetEN  			:    Disable 
*/


;//todo: 开始
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
GroupID:                        ; 默认 OPT3 初始值
    RETL    @0xF6               ; 12位
    RETL    @0xFE
    ; RETL    @0xF0   + (1<<1)    ; 10位地址格式， 高2位
    ; RETL    @0x38               ; 10位地址格式， 低8位
 


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
	
	BC		SystemFlag,F_DataValid               ; I2C总线接收到 继电器状态改变后，做出动作
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

    MOV     A,@C_UartCont           ;设置中断时间
    CONTW
    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,@TccMask              ; 设置TCC中断允许
    IOW     IOCF
    CLRA                            ; 清除中断标志
    MOV     IntFlag,A   

    CLR     TxStep                  ; 开始发送

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
	MOV		SystemFlag,A            			;起动后首先读 I2C 端口数据，初始化
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
; 主设备通过06,07地址修改了设备地址，需要保存在EPROM中
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
    IOW    IOCF                     ; 关闭中断

_IntNextStep:
    INC     TxStep
_IntTccEnd:
    BCTCIF                          ; 清除中断标志   
    POPStack
    reti

;**********************************************************************
ChkTxEnd:
    JBS     SystemFlag,F_TxEnd
    JMP     main    

    BC      SystemFlag,F_TxD        ; 转为读I2C总线
    BC      SystemFlag,F_DataValid  ; 清除数据有效位
    JMP     Error_DevAddrDiff       ; STEP= 0,设置端口，10位地址匹配清除

;**********************************************************************
