
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
   chksum:    

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
    RETL    @0xF0             ; 12位
    RETL    @0xB0
    ; RETL    @0xF0   + (1<<1)    ; 10位地址格式， 高2位
    ; RETL    @0x38               ; 10位地址格式， 低8位
 

_KeyBitMask:
    MOV     A,PrgTmp1
    ADD     PC,A
    RETL    @1<<B_Key1
    RETL    @1<<B_Key2
    RETL    @1<<B_Key3
    RETL    @1<<B_Key4
    RETL    @1<<B_Key5

_TurnOnRelay:
    BC      StatusReg,CarryFlag         ; 关闭继电器
    RLCA    PrgTmp1
    ADD     PC,A
    BS      P_RLY1,B_RLY1
    RET
    BS      P_RLY2,B_RLY2
    RET    
    BS      P_RLY3,B_RLY3
    RET
    BS      P_RLY4,B_RLY4
    RET        
    BS      P_RLY5,B_RLY5
    RET    

; 关闭某个继电器
_TurnOffRelay:
    BC      StatusReg,CarryFlag         ; 关闭继电器
    RLCA    PrgTmp1
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



;**********************************************************
;    M_I2CSlaver202003           ; I2C 主控程序
;**********************************************************
;  2020.03.01 更新，I2C Slaver , Master,支持7bit,10bit地址格式
;    将I2C地址设定为范围  C_RelayNum
;
;     06-写设备地址， 07-读设备地址
;*****************************************
;使用 I2C Slaver 且注意：
;   由于存在 列表，需要将 宏放在程序开始位置
;   将 IntPortEnd 放在 main开始
;*****************************************
    I2CSMask		equ     (1<<SlaverSCL) + (1<<SlaverSDA) 

C_Slaver_SCLi_SDAo  equ     C_SlaverBusOut  + (1<<SlaverSCL)
C_Slaver_SCLo_SDAi  equ     C_SlaverBusOut  + (1<<SlaverSDA)
C_Slaver_BusIn      equ     C_SlaverBusOut  + I2CSMask

            C_ChkDevAddr               ==   1      
            C_GetBroad1Byte            ==   C_ChkDevAddr         +  1      
            C_ChkAddrByte2             ==   C_GetBroad1Byte      +  1      
            C_GetByteAddr              ==   C_ChkAddrByte2       +  1      
            C_WriteByte                ==   C_GetByteAddr        +  1      
            C_PreTxByte                ==   C_WriteByte          +  1      
            C_TxByte                   ==   C_PreTxByte          +  1      
            C_ReadAck                  ==   C_TxByte             +  1      
            C_TxAckRcvByte             ==   C_ReadAck            +  1      
            C_RcvByte                  ==   C_TxAckRcvByte       +  1      
            C_TxACK                    ==   C_RcvByte            +  1      


;//todo: IntPort                               ;此为查询方式处理。I2C 协议，避免 maskter设备速度过快有些中断漏掉
IntPort:
	MOV		A,I2CS_Port
	XOR		A,SystemFlag
	AND		A,@I2CSMask
	MOV		IntTemp,A                        ; IntTemp为 端口当前检测到的变化位
	XOR		SystemFlag,A                     ; SystemFlag 为端口当前值
 
    JBS     SystemFlag,F_SDAInput
    JMP     ChkStartEnd 

    JBS     SystemFlag,SlaverSCL            ; 在 SCL 高电平时
    JMP     ChkStartEnd    

	JBS		IntTemp,SlaverSDA               ; SDA 变化了
	JMP		ChkStartEnd
	
	JBS		SystemFlag,SlaverSDA
    JMP     _Step_RcvDevAddr                ; SDA 由高变低为 START,  GetStart:
    JMP     _Step_GetStop

ChkStartEnd:
NextOpration:
;//mark: 命令表
    MOV     A,I2CStep
    ADD     PC,A
    JMP     IntPortEnd                      ; 等待接收 START ，或 STOP 空闲操作，只用于接收 START,STOP
    JMP     Step_ChkDevAddr                 ;  
    JMP     Step_GetBroad1Byte              ; 广播地址后第一字节， 01
    JMP     Step_ChkAddrByte2               ; 10B 地址，第2字节
    JMP     Step_GetByteAddr                ;  
    JMP     Step_WriteByte                  ;  
    JMP     Step_PreTxByte                  ;  
    JMP     Step_TxByte                     ;  
    JMP     Step_ReadAck                    ;    
    JMP     Step_TxAckRcvByte               ;  
    JMP     Step_RcvByte                    ;  
    JMP     Step_TxACK                      ;  



;*****************************************************************************************    
_Step_RcvDevAddr:                          ; 接收到 START 后进行的操作
    MOV     A,@C_ChkDevAddr
    MOV     StepBak,A

	MOV     A,@8
	MOV     CLKS,A

    MOV     A,@C_RcvByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;*****************************************************************************************    
Step_ChkDevAddr:                          ; 当前接收到的字节为 设备地址ADDR
    MOV     A,Data
    AND     A,@0xFE
    XOR     A,@0x06
    JBS     StatusReg,ZeroFlag
    JMP     _Step_Chk10BitAddr 


; 接收到对设备地址操作，
    JBC     Data,0
    JMP     _Step_DevAddrOk
;*****************************************************************************************    
;            通过广播地址写设备地址， 00 - 01 - 【A1】【A2】
    BS      SystemFlag,F_WDevAddr           ; 相比 Slaver程序，只是这里做了 **修改2**
    MOV     A,@C_GetBroad1Byte              ; 设备地址为 00，广播地址
PreSetTxAckRcvByte:
    MOV     StepBak,A
    MOV     A,@C_TxAckRcvByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;********************************************************
Step_GetBroad1Byte:
    MOV     A,@DevAddrByte
    MOV     DataPtr,A
    JMP     _Step_PreWriteByte

;*****************************************************************************************    
_Step_Chk10BitAddr:
    MOV     A,Data                          ; 高7位地址是相 同的
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag              ; 检查高5位是不是 F0
    JMP     _Step_7BitAddr                  ; 是7位地址 ,则进入接收内部地址

    MOV     A,Data
    AND     A,@0xFE
    XOR     A,DevAddrByte                   ; 接收到第一个设备地址字节必须相同
    JBS     StatusReg,ZeroFlag
    JMP     Error_DevAddrDiff

    JBS     Data,0                          ; 第一个设备地址高5位是 F0
    JMP     $+4
    JBS     SystemFlag,F_AddrMarried        ; 第一个设备地址 是10位，且最低位是1-读
    JMP     Error_DevAddrDiff               ; 接收到10位地址，并不是自己的，
    JMP     _Step_DevAddrOk                 ; 10位地址已经校验，需要读数据

    MOV     A,@C_ChkAddrByte2               ; 进入接收10位地址 第二个字节
    JMP     PreSetTxAckRcvByte

Step_ChkAddrByte2:                        ; 检测10bit地址第2个字节
    MOV     A,DevAddrByte+1
    ADD     A,@C_RelayNum
    SUB     A,Data
    JBC     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff

    MOV     A,DevAddrByte+1
    SUB     A,Data
    JBS     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff    
    ADD     A,@DataBuf
    MOV     DataPtr,A

    BS      SystemFlag,F_AddrMarried        ; 检测到设备地址 是10位地址，相同
    JMP     _Step_WriteByteAddr

_Step_7BitAddr:                             ; 接收到地址是7bit地址
    MOV     A,DevAddrByte
    ADD     A,@C_RelayNum*2
    SUB     A,Data
    JBC     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff

    MOV     A,DevAddrByte
    SUB     A,Data
    JBS     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff

    MOV     PrgTmp1,A
    BC      StatusReg,CarryFlag
    RRCA    PrgTmp1
    ADD     A,@DataBuf
    MOV     DataPtr,A

    JBC     Data,0
    JMP     _Step_DevAddrOk                 ; 读操作 ，7bit地址，读我操作
_Step_WriteByteAddr:
    BC      SystemFlag,F_I2CRead            ; 修改*******3 设置写标志
    MOV     A,@C_GetByteAddr                ; 向我写数据
    JMP     PreSetTxAckRcvByte

;*****************************************************************************************    
Step_GetByteAddr:                           ; 接收到的是RAM地址
    MOV     A,Data 
    ADD     DataPtr,A                       ; 设定数据指针
_Step_PreWriteByte:
    MOV     A,@C_WriteByte                  ; 
	JMP     PreSetTxAckRcvByte              ; 接收到一个字节后，进入 Step06_WriteByte （向我写一个数据）
	
Step_WriteByte:                             ; 当前进入写数据操作
    MOV     A,DataPtr
    MOV     RamSelReg,A                     ; 置数据指针
                               
    MOV     A,@~C_TurnsMask      ; 修改******1这里不同
    AND     R0,A
    MOV     A,Data
    AND     A,@C_TurnsMask       ; 数据只保存低4位
    OR      R0,A                 ; 保存数据

    CALL    ChkDataPtrOverflow
    JMP     _Step_PreWriteByte
;*****************************************************************************************    
_Step_DevAddrOk:            ;设备地址正确，从我读数据
    BS      SystemFlag,F_I2CRead            ; 修改*******4 设置写标志

    MOV     A,@C_PreTxByte
    MOV     StepBak,A
    MOV     A,@C_TxAck
    MOV     I2CStep,A
    JMP     IntPortEnd

Step_PreTxByte:
	MOV     A,@8                            ; 操作为读命令，向主设备发送第一个数据
	MOV     CLKS,A
    MOV     A,DataPtr
    MOV     RamSelReg,A
    MOV     A,R0
    AND     A,@C_TurnsMask      ; 修改******2这里不同     
    MOV     Data,A                          ; 获得当前指针数据

    CALL    ChkDataPtrOverflow

    MOV     A,@C_TxByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;*****************************************
Step_TxByte:                                ; 发送一个字节过程
    JBS     IntTemp,SlaverSCL               ; SCL发生变化时
    JMP     IntPortEnd

	JBC		SystemFlag,SlaverSCL
	JMP		_Step_TxByte_DatEnd

	RLC		Data
    JBC     StatusReg,CarryFlag             ; 发送数据
    JMP     _SlaverSDA_1
    JMP     _SlaverSDA_0

_Step_TxByte_DatEnd:
	DJZ		CLKS
	JMP		IntPortEnd    
    INC     I2CStep
    JMP     IntPortEnd    
;*****************************************
Step_ReadAck:
    JBS     IntTemp,SlaverSCL
    JMP     IntPortEnd
    
	JBS		SystemFlag,SlaverSCL
	JMP		SDAInput                        ; SCL 为低电平，改变 SDA为输入
	JBC		SystemFlag,SlaverSDA            ; SCL 为高电平，
	JMP		_Step_GetNoAck                  ; SDA 为高电平，则读到为 NO_ACK
    JMP     Step_PreTxByte                  ; SDA 为低电平，则读到 RX_ACK ，准备发送下个数据

;*****************************************
Step_TxAckRcvByte:
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化时
    JMP     IntPortEnd

	JBS		SystemFlag,SlaverSCL            ; 
	JMP		_SlaverSDA_0                    ; 发送ACK

    INC     I2CStep
	MOV     A,@8
	MOV     CLKS,A
    JMP     IntPortEnd

Step_RcvByte:                               ; 接收一个字节过程
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化
    JMP     IntPortEnd
    
	JBS		SystemFlag,SlaverSCL
	JMP		FirstClkInput                   ; SCL为低电平，改变端口方向
    
	BC		StatusReg,CarryFlag             ; SCL为高电平，读入数据，保存在DATA中
	JBC		SystemFlag,SlaverSDA
	BS		StatusReg,CarryFlag             ; SCL为高电平，读入数据，保存在DATA中
	RLC		Data
	
	DJZ		CLKS
	JMP		IntPortEnd

    JMP     _ReturnStep
;*****************************************
Step_TxACK:                                 ; 发送 TX_ACK 过程
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化时
    JMP     IntPortEnd

	JBS		SystemFlag,SlaverSCL            ; 
	JMP		_SlaverSDA_0

_ReturnStep:   
    MOV     A,StepBak                       ; SCL为高电平时，返回操作
    MOV     I2CStep,A
    JMP     NextOpration
;***************************************** 
ChkDevAddrError:
    JBC     DevAddrByte,0
    BC      DevAddrByte,0

    MOV     A,DevAddrByte
    AND     A,@0xF0
    JBC     StatusReg,ZeroFlag
    JMP     _DevAddrError                   ; 高4位为0，则为保留地址，不允许

    COMA    DevAddrByte
    AND     A,@0xF8
    JBC     StatusReg,ZeroFlag
    JMP     _DevAddrError                   ; 高5位 = F8，保留地址
    BC      StatusReg,CarryFlag
    RET    

_DevAddrError:
    BS      StatusReg,CarryFlag
    RET    


ChkDataPtrOverflow:                         ; 地址加1 ，检测地址溢出
    INC     DataPtr                         ; 数据指针向后移一个

    MOV     A,@DataBufEnd+1                 ; 153B RAM最大2F，大于2F，重置BUF
    SUB     A,DataPtr
    MOV     A,@DataBuf                      ; 数据指针大于等于0X30，重新设定数据指针
    JBC     StatusReg,CarryFlag
    MOV     DataPtr,A
    RET
;*****************************************
FirstClkInput:                              ; SCL 为变为低电平时
    JBS     CLKS,3
    JMP     IntPortEnd
SDAInput:
_SlaverSDA_1:
    MOV     A,@C_Slaver_BusIn               ; SCL, SDA 设置为输入
	IOW		I2CS_Port
    BS      SystemFlag,F_SDAInput
	JMP		IntPortEnd

_SlaverSDA_0:
    MOV     A,@C_Slaver_SCLi_SDAo           ; SCL 为输入， SDA 为输出
	IOW		I2CS_Port
	BC		I2CS_Port,SlaverSDA    
    BC      SystemFlag,F_SDAInput
    JMP     IntPortEnd
;*****************************************
_Step_GetStop:                              ; SDA 由低变高为 STOP
    BS      SystemFlag,F_DataValid          ; 接收到STOP ，处理这一组数据
_Step_GetNoAck:                             ; 读我结束
Error_DevAddrDiff:      
    CLR     I2CStep
    BC      SystemFlag,F_AddrMarried        ; 10位地址匹配取消
    JMP     _SlaverSDA_1
;*****************************************

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
    JMP     UpdatDevAddr                    ; 更新设备地址

    JBC     SystemFlag,F_I2CRead            ; 只处理写电机数据
    JMP     main                            ; 
;根据当前数据，获得当前设置电机状态 = tmp2
    MOV     A,@CtrlByte                     ; 数据处理
    MOV     RamSelReg,A
    CLR     PrgTmp1
    CLR     PrgTmp2                         ; 当前电机开关状态
_I2CSetSWLoop:
    MOV     A,R0
    AND     A,@C_TurnsMask
    JBC     StatusReg,ZeroFlag
    JMP     $+3

    CALL    _KeyBitMask
    OR      PrgTmp2,A

    INC     RamSelReg
    INC     PrgTmp1
    MOV     A,@C_RelayNum
    SUB     A,PrgTmp1
    JBS     StatusReg,CarryFlag
    JMP     _I2CSetSWLoop
;根据当前数据，获得当前设置电机状态 = tmp2
    MOV     A,PrgTmp2
    XOR     A,EnKeyReg
    XOR     EnKeyReg,A          ; 更新开关状态        1 
    MOV     PrgTmp2,A           ; 需要处理电机位
    OR      TxUartFlag,A        ; 设置电机向上位报告   2    

    CLR     PrgTmp1             ; 电机开关处理        3
_OnOffRelayLoop:
    BC      StatusReg,CarryFlag
    RRC     PrgTmp2
    JBS     StatusReg,CarryFlag
    JMP     _OnOffRelayNext

    CALL    _KeyBitMask
    AND     A,EnKeyReg
    JBC     StatusReg,ZeroFlag
    JMP     $+3

    CALL    _TurnOnRelay
    JMP     $+2

    CALL    _TurnOffRelay
_OnOffRelayNext:
    INC     PrgTmp1
    MOV     A,@C_RelayNum
    SUB     A,PrgTmp1
    JBS     StatusReg,CarryFlag
    JMP     _OnOffRelayLoop

    JMP     main

;*****************************************

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
    BC      SystemFlag,F_WDevAddr
    MOV     A,@DevAddrByte+1
    SUB     A,DataPtr
    JBS     StatusReg,CarryFlag
    JMP     main

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
    CALL    I2C_WritePageData      ; 保存
    JMP     main

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
    MOV     A,EnKeyReg
    JBC     StatusReg,ZeroFlag
    RET

    MOV     A,@C_RelayNum
    SUB     A,KeyStep
    JBS     StatusReg,CarryFlag
    MOV     A,KeyStep
    MOV     PrgTmp1,A                   ; Prgtmp1 = 第N个电机
    ADD     A,@Key1Cnt
    MOV     RamSelReg,A                 ; RamSelReg = 寄存器地址

    ; MOV     A,PrgTmp1
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

    MOV     A,@0x10                     ; 检测抖动， 减1
    SUB     A,R0
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

    JMP     _TurnOffRelay

