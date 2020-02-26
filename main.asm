
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
    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,RxStep
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
    RETL    @0xB0             ; 12位
    RETL    @0xFF
    ; RETL    @0xF0   + (1<<1)    ; 10位地址格式， 高2位
    ; RETL    @0x38               ; 10位地址格式， 低8位
 


;*****************************************
;//todo: main
IntPortEnd:
main:
	WDTC

	JBS		SystemFlag,F_DataValid
	JMP		IntPort
	
	BC		SystemFlag,F_DataValid               ; I2C总线接收到 继电器状态改变后，做出动作
    JBC     SystemFlag,F_WDevAddr
    CALL    UpdatDevAddr

    C_CtrlMask    ==   0x01
    
	MOV     A,CtrlByte
    CLR     CtrlByte
    AND     A,@C_CtrlMask
    ADD     PC,A
    JMP     main                                ; 0
    JMP     RelayAction                         ; 1
    
    M_I2CSlaver201911

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

if  0
    I2CWaitTime ==  0x20

    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A

    MOV     A,@0xF2
    MOV     PrgTmp5,A
    MOV     A,@0x39
    MOV     PrgTmp6,A

    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@1
    MOV     Prgtmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    CALL    I2C_WritePageData

 
    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@1
    MOV     Prgtmp2,A
    MOV     A,@0x20
    MOV     RamSelReg,A
    CALL    I2C_ReadPageData
    JMP     $
endif

if  Relay4Board<3
    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@C_E2Addr_DevAddr
    MOV     PrgTmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    CALL    I2C_ReadPageData                      ; 检查EPROM是否有数据，如果EPROM地址正确，使用EPROM，否则读OPT端口

    CALL    ChkDevAddrError
    JBS     StatusReg,CarryFlag
    JMP     main
_EpromError:
    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A
endif

if Relay4Board == 3                                          ; 153B  SOP14 封装
    CLR     DevAddrByte
    JBC     Port6,2
    BS      DevAddrByte,1

    JBC     Port6,3
    BS      DevAddrByte,2

    JBC     Port6,4
    BS      DevAddrByte,3

    JBC     Port6,5
    BS      DevAddrByte,4

    JBC     Port6,6
    BS      DevAddrByte,5

    JBC     Port6,7
    BS      DevAddrByte,6

    JBC     Port5,0
    BS      DevAddrByte,7

endif

if Relay4Board == 4                        
	CALL	GroupID
	MOV	    DevAddrByte,A

    JBC     Port6,2
    BS      DevAddrByte,1

    JBC     Port6,3
    BS      DevAddrByte,2

    JBC     Port6,4
    BS      DevAddrByte,3   
endif
    JMP     main


RelayAction:
	JBC		RelayStatus,F_RlyOn
	BS		Relay1Port,Relay_B1
	JBS		RelayStatus,F_RlyOn
	BC		Relay1Port,Relay_B1
if (Relay4Board==1) ||(Relay4Board==2)
	JBC		RelayStatus,F_RlyOn1
	BS		Relay2Port,Relay_B2
	JBS		RelayStatus,F_RlyOn1
	BC		Relay2Port,Relay_B2

	JBC		RelayStatus,F_RlyOn2
	BS		Relay3Port,Relay_B3
	JBS		RelayStatus,F_RlyOn2
	BC		Relay3Port,Relay_B3

	JBC		RelayStatus,F_RlyOn3
	BS		Relay4Port,Relay_B4
	JBS		RelayStatus,F_RlyOn3
	BC		Relay4Port,Relay_B4
endif
    JMP     main


;***************************************** 
; 主设备通过06,07地址修改了设备地址，需要保存在EPROM中
UpdatDevAddr:
if  Relay4Board<3
    BC      SystemFlag,F_WDevAddr
    CLR     CtrlByte
    MOV     A,@DevAddrByte+1
    SUB     A,DataPtr
    JBS     StatusReg,CarryFlag
    RET

    MOV     A,@0xA0
    MOV     PrgTmp5,A
    MOV     A,@0xFF
    MOV     PrgTmp6,A

    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@C_E2Addr_DevAddr
    MOV     PrgTmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    JMP     I2C_WritePageData      ; 保存
else
    RET
endif
;***************************************** 

    M_I2CMaster201911



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
    CLR     TxStep
    JMP     _IntTccEnd

_IntTx_Over:
    BS      SysFlag,F_TxEnd
    CLRA
    IOW    IOCF                     ; 关闭中断

_IntTccEnd:
    BCTCIF                          ; 清除中断标志
_IntEnd:    
    POPStack
    reti


Tx_SetUartInt:
    MOV     A,@C_TxMode             ; 设置 UART 发送模式
    MOV     OpMode,A

    MOV     A,@C_UartCont           ;设置中断时间
    CONTW
    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,@TccMask              ; 设置TCC中断允许
    IOW     IOCF
    CLRA                            ; 清除中断标志
    MOV     IntFlag,A   

    CLR     TxStep

    BC      SysFlag,F_TxEnd
    ENI

    JMP     main    
