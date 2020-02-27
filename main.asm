
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
	reti
DefaultContrast:
	RETL	@3
DefaultDevAddr:
GroupID:                        ; 默认 OPT3 初始值
    RETL    @0xB0             ; 12位
    RETL    @0xFF
    ; RETL    @0xF0   + (1<<1)    ; 10位地址格式， 高2位
    ; RETL    @0x38               ; 10位地址格式， 低8位
 

_KeyBitMask:
    ADD     PC,A
    RETL    @1<<B_Key1
    RETL    @1<<B_Key2
    RETL    @1<<B_Key3
    RETL    @1<<B_Key4
    RETL    @1<<B_Key5

; 关闭某个继电器
_TurnOffRelayTable:
    ADD     PC,A
    BC      P_RLY1,B_RLY1
    RET
    BC      P_RLY2,B_RLY2
    RET    
    BC      P_RLY3,B_RLY3
    RET
    BC      P_RLY4,B_RLY4
    RET        
    BC      P_RLY5,B_RLY5
    RET    

_KeyScanTable:
    ADD     PC,A
    JMP     _KeyScanStep1
    JMP     _KeyScanStep2
    JMP     _KeyScanStep3
    JMP     _KeyScanStep4
    JMP     _KeyScanStep5
    JMP     _KeyConfirmStep1
    JMP     _KeyConfirmStep2
    JMP     _KeyConfirmStep3
    JMP     _KeyConfirmStep4
    JMP     _KeyConfirmStep5

;*****************************************
;//todo: main
IntPortEnd:
main:
	WDTC
    CALL    SoftTimer
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


    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@C_E2Addr_DevAddr
    MOV     PrgTmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    CALL    I2C_ReadPageData                      ; 检查EPROM是否有数据，如果EPROM地址正确，使用EPROM，否则读OPT端口

    CALL    ChkDevAddrError
    JBS     StatusReg,CarryFlag
    JMP     $+5
_EpromError:
    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A

;EPROM 读完成，设置电机端口状态
    MOV     A,@MachineIO_Init
    IOW     Port6
    MOV     A,@MachineR_Init
    MOV     Port6,A

    JMP     main


RelayAction:
; 	JBC		RelayStatus,F_RlyOn
; 	BS		Relay1Port,Relay_B1
; 	JBS		RelayStatus,F_RlyOn
; 	BC		Relay1Port,Relay_B1
; if (Relay4Board==1) ||(Relay4Board==2)
; 	JBC		RelayStatus,F_RlyOn1
; 	BS		Relay2Port,Relay_B2
; 	JBS		RelayStatus,F_RlyOn1
; 	BC		Relay2Port,Relay_B2

; 	JBC		RelayStatus,F_RlyOn2
; 	BS		Relay3Port,Relay_B3
; 	JBS		RelayStatus,F_RlyOn2
; 	BC		Relay3Port,Relay_B3

; 	JBC		RelayStatus,F_RlyOn3
; 	BS		Relay4Port,Relay_B4
; 	JBS		RelayStatus,F_RlyOn3
; 	BC		Relay4Port,Relay_B4
; endif
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



;//TODO: SoftTimer
SoftTimer:
    MOV     A,TCC
    XOR     A,TRFlagReg
    AND     A,@1<<F_16ms
    JBC     StatusReg,ZeroFlag
    RET
    XOR     TRFlagReg,A

    INC     Cnt16ms

    MOV     A,Cnt16ms
    XOR     A,Cnt16msBak
    AND     A,@1<<(IRC8M+1)
    JBS     StatusReg,ZeroFlag
    JMP     _Timer32ms

    MOV     A,Cnt16ms
    XOR     A,Cnt16msBak
    AND     A,@1<<(IRC8M+3)
    JBS     StatusReg,ZeroFlag
    JMP     _Timer250ms

    MOV     A,Cnt16ms
    XOR     A,Cnt16msBak
    AND     A,@1<<(IRC8M+5)
    JBC     StatusReg,ZeroFlag
    RET
_Timer500ms:
    XOR     Cnt16msBak,A

    BS      TRFlagReg,F_500ms
    JBC     TRFlagReg,F_QuitTime32ms
    RET

    DJZA    QuitTime                    ; QuitTime =1 时停止减
    MOV     QuitTime,A
    RET

_Timer250ms:
    XOR     Cnt16msBak,A
    BS      TRFlagReg,F_250ms
    RET

_Timer32ms:
    XOR     Cnt16msBak,A

    JBS     TRFlagReg,F_QuitTime32ms
    JMP     $+3
    DJZA    QuitTime                    ; QuitTime =1 时停止减
    MOV     QuitTime,A

    ; M_SingleKeyNoCont20190821
;**********32ms中断，键盘扫描*****************
;  32ms 中断一次，键盘扫描   256/16384= 1/64	
; IntKeyValue    B7 6 5 4 3 2 1 0
;                   |       |____KeyPin
;                   +____________KeyLast
;*******************************************
;**********25ms中断，键盘扫描*****************
;  25ms 中断一次，键盘扫描   256/16384= 1/64	
;*******************************************
;  单按键程序使用 3个RAM 

; 低电平检测  5* 320 = 1.5 秒
	Key0Vibrate		==		5     ; 1单位=320ms,   5 = 1.5秒
; 高电平检测  8*320 = 1.8 秒
	Key1Vibrate		==		8     ; 1单位=320ms,   8 = 1.8秒

    C_VibMask       ==      0xF0
    C_TurnsMask     ==      0x0F    
;//TODO: KeyScan
    MOV     A,@C_RelayNum
    SUB     A,KeyStep
    JBS     StatusReg,CarryFlag
    MOV     A,KeyStep
    MOV     PrgTmp1,A                   ; Prgtmp1 = 第N个电机
    ADD     A,@Key1Cnt
    MOV     RamSelReg,A                 ; RamSelReg = 寄存器地址

    MOV     A,PrgTmp1
    CALL    _KeyBitMask
    MOV     PrgTmp2,A                   ; Prgtmp2 = 位标志
    AND     A,EnKeyReg
    JBC     StatusReg,ZeroFlag
    JMP     $+3

    MOV     A,KeyStep
    JMP     _KeyScanTable
NextKeyStep:
    INC     KeyStep
    MOV     A,@2*C_RelayNum
    SUB     A,KeyStep
    JBC     StatusReg,CarryFlag
    CLR     KeyStep
    RET


_KeyScanStep1:
    BC      KeyCodeCurrent,B_Key1
    JBC     P_IN1,B_IN1
    BS      KeyCodeCurrent,B_Key1
    JMP     _ChkKeyChange
_KeyScanStep2:
    BC      KeyCodeCurrent,B_Key2
    JBC     P_IN2,B_IN2
    BS      KeyCodeCurrent,B_Key2
    JMP     _ChkKeyChange
_KeyScanStep3:
    BC      KeyCodeCurrent,B_Key3
    JBC     P_IN3,B_IN3
    BS      KeyCodeCurrent,B_Key3
    JMP     _ChkKeyChange
_KeyScanStep4:
    BC      KeyCodeCurrent,B_Key4
    JBC     P_IN4,B_IN4
    BS      KeyCodeCurrent,B_Key4
    JMP     _ChkKeyChange
_KeyScanStep5:
    BC      KeyCodeCurrent,B_Key5
    JBC     P_IN5,B_IN5
    BS      KeyCodeCurrent,B_Key5
_ChkKeyChange:

    CALL    NextKeyStep

    MOV     A,KeyCodeCurrent
    XOR     A,KeyCodeLast
    AND     A,PrgTmp2
    JBC     StatusReg,ZeroFlag
    RET
    XOR     KeyCodeLast,A

    MOV     A,@~C_VibMask
    AND     R0,A

    MOV     A,KeyCodeLast
    AND     A,PrgTmp2
    JBS     StatusReg,ZeroFlag
    JMP     $+4

    MOV     A,@Key0Vibrate<<4
    OR      R0,A
    RET

    MOV     A,@Key1Vibrate<<4
    OR      R0,A
    RET

_KeyConfirmStep1:
_KeyConfirmStep2:
_KeyConfirmStep3:
_KeyConfirmStep4:
_KeyConfirmStep5:

    CALL    NextKeyStep

    MOV     A,R0
    AND     A,@C_VibMask
    JBC     StatusReg,ZeroFlag
    RET

    MOV     A,R0
    SUB     A,@0x10                     ; 检测抖动， 减1
    MOV     R0,A
    AND     A,@C_VibMask
    JBS     StatusReg,ZeroFlag
    RET

    MOV     A,KeyCodeLast
    AND     A,PrgTmp2
    JBS     StatusReg,ZeroFlag          ; 端口由高变低电平时，计数
    RET

    DEC     R0
    MOV     A,R0
    AND     A,@C_TurnsMask
    JBS     StatusReg,ZeroFlag          ; 电机转数减到 0
    RET 

    MOV     A,PrgTmp2
    OR      TxUartFlag,A                ; 设置发送UART标志

    BC      StatusReg,CarryFlag         ; 关闭继电器
    RLCA    PrgTmp1
    JMP     _TurnOffRelayTable

