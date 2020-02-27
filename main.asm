; UART 转 I2C 总线

include "defmcu.h"
include	"option.h"
include "macro.h"
include "public2018.h"
include	"PortDef.h"
include	"ConstDef.h"
include	"RamDef.h"
include	"Mini4X8LED.H"

/*     

	OTP 选项：
	Target Power    	:    Using ICE
	RCOUT				:    OSC
	Setup Time  		:    288ms
	OSC  				:    12M晶体
	CLKS   				:    2Clocks
	ENWDT				:    Enable 
	ResetEN  			:    Disable 
    PCB文件日期          ：   2019.02.05

    UART 多字节读写已经完成,I2C总线协议采用新方法

    上电参数如下：
       
    1、I2C 设备地址  ：   08  A0
    2、I2C 时钟     ：   07  30US
    3、SDA,SCL  外接上拉电阻
    4、SDA,SCL  为输入端口
    5、UART通信波特率 ：9600 B/S,   支持多主总线仲裁， 支持从设备降低时钟

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

;//NOTE: 开始
	ORG  	0x00
	JMP 	Reset  ; 0
DefaultClock:
    RETL    (C_DefaultTcc  + PortPH_Init<<2)        ; 上拉电阻选项
Tx_PackStartErr: 
    MOV     A,@0x21             ;包头出错
	JMP     Tx_ReturnValue

Tx_PackEndErr:                  ;包尾错误
    MOV     A,@0x22
	JMP     Tx_ReturnValue

Tx_PackSizeErr:  
    MOV     A,@0x23             ;接收到 数据包大小过大
	JMP     Tx_ReturnValue
	
	ORG     0x08
	JMP 	Intext    ;中断地址


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
I2CClockTable:           ;返回显示值
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
    JMP     ResetUartRx         ; 发送 OK，完成进入UART接收
    JMP     I2CReadNextData     ; 读I2C数据一组完成，再下一组
    JMP     $                   ; 命令复位，WDT 复位    
    JMP     ProbeI2CAddrNext    ; PROBE addr 
    JMP     ProbeNextWait       ; 等待
    JMP     I2CWriteNextGroup   ; I2C写下一组数据


;//NOTE: I2CCmdTable
I2CCmdTable:    
    ADD     PC,A
    JMP     Cmd_Reset           ;  0      WDT 超时，恢复默认设置
    JMP     I2CReadData         ;  1  
    JMP     I2CWriteData        ;  2    
    JMP     ReadI2cDevAddr      ;  3   
    JMP     SetI2CDevAddr       ;  4   
    JMP     ReadI2cClock        ;  5      
    JMP     SetI2CClock         ;  6  
    JMP     ReadI2cUpperRes     ;  7   
    JMP     SetI2CUpperRes      ;  8   
    JMP     ProbeI2CAddr        ;  9

    C_MaxCmd    ==  $- I2CCmdTable -1   ; 最大命令字

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
    JMP     $                    ;出错了 WDT OUT

;********************************************


;;*******************************************************
;//NOTE: Intext                             ; 定时器中断，32MS一次，超时计时
Intext:
    PUSHStack

    JBS     IntFlag,ICIF
    JMP     _IntIfTcif
 
	JBC     Rx_Port,Rx_B
	JMP     _IntRxOver

    MOV     A,@TccMask
    IOW     IOCF

    CLRA
    MOV     RF,A                    ; 清除中断标志
    CLR     RxStep
    INC     RxStep                  ; 开始接收位
   
    JMP     _IntRxResetTcc

_IntRxOver:							; RX 不是第一个沿
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
    JMP     _IntRxNextFrame     ; 帧出错，数据不保存，接收第二个数据

    MOV     A,RxBufPtr          ; 帧正确，保存数据
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
    CLR     RxStep                          ; IC中断用于接收RX信号， TCC中断用于计时，超出计时主程序将设为接收数据包结束
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

    DJZA    TimerCnt                ;  从N 减到1
    MOV     TimerCnt,A
    JMP     _IntTccEnd
;*************************************************
_IntI2C:
    BS      SysFlag,F_WaitTime
_IntTccEnd:
    BCTCIF                          ; 清除中断标志
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
    JMP     Tx_ReturnValue          ; 复位后显示 0X20

;******************************************************************
;//NOTE: ResetUartRx
;****************************************************************
ResetUartRx:
    DISI

    MOV     A,@RxBuf
    MOV     RxBufPtr,A          ; 恢复接收指针

    MOV     A,@RxBuf            ; 清除缓冲区
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

    CLR     OpMode              ; 设置为 UART RX MODE
    CLR     TimerCnt            ;  = 0,不计时, =1 超时
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
;       |  |  +------------------------ 结束
;       |  +--------------------------- UART 转 I2C 协议命令， 3 - WDT超时，恢复默认设置
;       +------------------------------ 数据包字节数                                                               
Cmd_Reset:
    MOV     A,@1
    MOV     TxBuf+1,A
    MOV     A,@TxBuf+1
    MOV     TxBufPtr,A
    MOV     TxBufEndPtr,A

    MOV     A,@C_TxCmd_Reset
    JMP     _TxCmdSetUart          
;******************************************************************
;//NOTE:  返回表
Tx_ReturnOk:     
Tx_I2COk:
	MOV     A,@01
	JMP     Tx_ReturnValue


Tx_PackError:
    MOV     A,@0x24             ;I2C 命令字不正确
	JMP     Tx_ReturnValue

_RxPackErr:
    MOV     A,@0x25             ; 写I2C字节数为0
	JMP     Tx_ReturnValue

Tx_DevAddrSizeErr:
    MOV     A,@0x26
	JMP     Tx_ReturnValue

_RxPackEndErr:
    MOV     A,@2                ; 数据包不完整
    JMP     Tx_ReturnValue

Tx_I2C_SancFail:
    BC      SysFlag,F_SDA_SancFail      ;与 F_CmdReset 共用，这里清除
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

    MOV     A,@C_TxStartStep        ; 下次中断时间到开始发送数据
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
    IOW     IOCC                            ; 关闭开路输出，  SDA,SCL 输出0，输入切换
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
;  不包含中断操作，需要进行以下操作
;    1、外部需进行 DISI
;    2、 M_EnCTS
;    3、设置好 , RxBufPtr
; 这里要注意，只设置 RX为输入口，产生变化中断，其它端口要关闭，如果打开，会影响UART接收数据  
SetUart_TCC:
;**********************************************************
; 关闭 SDA,SCL 对 接收UART影响, 只有 RX-B ，状态中断，P63为高电平输入
    MOV     A,@I2CPortMask
    IOW     IOCC                            ; 开路输出

    MOV     A,@1<<Rx_B                      ; RX 为输入，其它为输出
    IOW     Rx_Port                         ; 这里要注意，只设置 RX为输入口，产生变化中断，其它端口要关闭，如果打开，会影响UART接收数据
    MOV     A,@( I2CPortMask + 1<<Tx_B )    ; SDA,SCL输出高阻， TX输出高电平
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
    JMP     _RxPackEndErr                   ; 超时出错

_ChkByte:
    JBS     SysFlag,F_RxByte
    JMP     main

    BC      SysFlag,F_RxByte
    DEC     TimerCnt                        ; 计时器从0减到 1结束

    MOV     A,RxPackStart
    XOR     A,@C_PackFlag
    JBS     StatusReg,ZeroFlag
    JMP     Tx_PackStartErr                             ;

    MOV     A,RxPackSize
    JBC     StatusReg,ZeroFlag
    JMP     main                            ; 还没有接收到数据
    SUB     A,@C_RxBufSize-2
    JBS     StatusReg,CarryFlag
    JMP     Tx_PackSizeErr

    MOV     A,@RxBuf+2
    ADD     A,RxPackSize
    SUB     A,RxBufPtr
    JBS     StatusReg,CarryFlag
    JMP     main                            ; 还没有接收完成

    MOV     A,@RxPackSize
    ADD     A,RxPackSize
    MOV     RamSelReg,A
    MOV     A,R0
    XOR     A,@C_PackFlag
    JBS     StatusReg,ZeroFlag
    JMP     Tx_PackEndErr

; 接收到数据，关闭中断，处理数据
;7E 05 A0 FF 01 05 7E
    DISI
    MOV     A,I2CCmd
    SUB     A,@C_MaxCmd
    JBS     StatusReg,CarryFlag
    JMP     Tx_PackError

    MOV     A,I2CCmd
    JMP     I2CCmdTable


;*****************************************
;//TODO: GetDevAddrBytes , 使用 TMP4
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
;       |  |  +------------------------ 结束
;       |  +--------------------------- UART 转 I2C 协议命令， 1 - 读 I2C 设备地址
;       +------------------------------ 数据包字节数                                                               
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
;       |  |  +------------------------ 结束
;       |  +--------------------------- UART 转 I2C 协议命令， 2 - 读 I2C CLOCK
;       +------------------------------ 数据包字节数                                                               
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
;       |  |  |  +--------------------- 结束
;       |  |  +------------------------ 01  - 30US
;       |  +--------------------------- UART 转 I2C 协议命令， 4 - 设置I2C CLOCK
;       +------------------------------ 数据包字节数                                                               
SetI2CClock:
    MOV     A,@~C_I2CDispMask
    AND     I2CCLOCK,A

    MOV     A,@C_I2CDispMask>>4
    AND     I2CCmd+1,A
    SWAPA   I2CCmd+1
    OR      I2CClock,A

    JMP     Tx_ReturnOk
;********************************************************
; 复制RAM，从[tmp1] -->到[tmp2] , 共[A]个
; Prgtmp1 - 源地址
; Prgtmp2 - 目标地址
; [A] - 复制个数
; 使用RAM  ,   tmp3,tmp4
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
;       |  |  |  |  +------------ 结束
;       |  |  +--+
;       |  |   +---------------------- I2C 设备地址 占2个字节
;       |  +--------------------------- UART 转 I2C 协议命令， 6 - 设置I2C 设备地址
;       +------------------------------ 数据包字节数                      
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
;       |  |  |  |  |  +-----------+--- 电机自动转数
;       |  |  |  |  |    
;       |  |  |  |  +------------------ 电机命令
;       |  |  |  +--------------------- I2C 地址2
;       |  |  +------------------------ I2C 地址1
;       |  +--------------------------- 数据包字节数
;       +------------------------------ 数据包字节数          
;//NOTE: 写命令                                                     
I2CWriteData:
    MOV     A,RxBuf+4
    JBC     StatusReg,ZeroFlag
    JMP     _RxPackErr
    
    MOV     A,RxBuf+3
    MOV     RxBuf+1,A                   ;  数据地址
    MOV     A,RxBuf+4
    MOV     RxBuf+2,A                   ;  数据个数

I2CWriteNextData: 
    DISI
    MOV     A,@RxBuf+3
    MOV     RxBufPtr,A                  ;  接收指针
    ENI
  
    BC      SysFlag,F_StartCnt
    M_EnCTS

    MOV     A,@C_RxData                 ; 设置 UART接收剩余数据模式
    MOV     OpMode,A
    JMP     main
;***********************************************
I2CWriteNextGroup:
    DISI
    CALL    SetUart_TCC
    JMP     I2CWriteNextData

;***********************************
;  00 0A 11 22 33 44 55 66 77 88 99 AA
;//NOTE:  写命令读数据
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
    DEC     TimerCnt                 ; 计时器从0减到 1结束
;*******************************************
    CALL    GetReadSize
    ADD     A,@RxBuf+3
    SUB     A,RxBufPtr
    JBS     StatusReg,CarryFlag
    JMP     main
;****************************************************************
_CTSEnd:                                ; CTS 关闭后，接收数据结束
;接收一组数据，准备写入
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
    JMP     Tx_ReturnOk                 ; 接收到 7E 01 7E 则停止写数据

_CTSWriteI2cData:
    M_DisCTS
    CALL    SetI2C_Tcc

    MOV     A,@RxBuf+3
    SUB     A,RxBufPtr
    MOV     Prgtmp1,A                   ; 要写的数据个数

    MOV     A,RxBuf+1                   ; 目标I2C RAM 地址
    MOV     Prgtmp2,A
    MOV     A,@RxBuf+3                  ; 源数据RAM 地址
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
    SUB     RxBuf+2,A                  ; 修改 EPROM 地址，读的个数

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
;       |  |  |  |  +------ 结束
;       |  |  |  |  
;       |  |  |  +--------------------- I2C 读多少个字节
;       |  |  +------------------------ I2C 设备地址0开始读数据， 0 -命令字
;       |  +--------------------------- UART 转 I2C 协议命令， 7-读数据
;       +------------------------------ 数据包字节数        
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
    MOV     Prgtmp2,A                   ; 源i2c ram 地址
    
    MOV     A,@RxBuf+3                  ; 目标 RAM 地址
    MOV     RamSelReg,A

    CALL    I2C_ReadPageData
    JBC     SysFlag,F_SDA_SancFail
    JMP     Tx_I2C_SancFail

    XOR     A,@C_I2CNoAckFlag
    JBC     StatusReg,ZeroFlag
    JMP     Tx_I2CErr

    DISI
    MOV     A,@RxBuf+3                  ; 目标 RAM 地址
    MOV     TxBufPtr,A
    CALL    GetReadSize
    ADD     A,@RxBuf+2
    MOV     TxBufEndPtr,A

    MOV     A,@C_TxCmd_I2CRead
    JMP     _TxCmdSetUart
;********************************************************
;   7E 04 08 01 01 7E
;       |  |  |  |  |
;       |  |  |  |  +--------------------- 结束
;       |  |  |  +-----------SCL上拉
;       |  |  +--------------[SDA]-1，带上拉  ||  B1[SCL]-1带上拉
;       |  +--------------------------- UART 转 I2C 协议命令， 8 - 设置I2C 上拉电阻
;       +------------------------------ 数据包字节数                                                               
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
    MOV     I2CCLOCK,A              ; 2位保存在I2CCLOCK中

    BC      StatusReg,CarryFlag
    RRC     PrgTmp1
    RRC     PrgTmp1
    MOV     A,@I2CPortMask
    XOR     Prgtmp1,A               ;0-使能上拉，1-禁止上拉。要取反

    IOR     IOCD
    AND     A,@~I2CPortMask
    OR      A,Prgtmp1
    IOW     IOCD

    JMP     Tx_ReturnOk

;********************************************************
;   7E 02 09 7E
;    |  |  |  | 
;    |  |  |  +--------------------- 结束
;    |  |  +--------------------------- UART 转 I2C 协议命令， 9 - 读I2C 上拉电阻
;    |  +------------------------------ 数据包字节数                                                               
;    +-------------------------------开始
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
;    |  |  |  +--------------------- 结束
;    |  |  +--------------------------- UART 转 I2C 协议命令， A - 读I2C 端口状态
;    |  +------------------------------ 数据包字节数                                                               
;    +-------------------------------开始
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
;    |  |  |  |  |  +--------------------- 结束
;    |  |  |  +--+--------------探索地址个数,最大FFFF次
;    |  |  +--------------------------- UART 转 I2C 协议命令， C -  探索I2C设备地址
;    |  +------------------------------ 数据包字节数                                                               
;    +-------------------------------开始

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

;       是7 位地址，前一字节加2
    MOV     A,@2
    ADD     PrgTmp5,A 
    MOV     A,PrgTmp5
    XOR     A,@0xF0
    JBC     StatusReg,ZeroFlag     
    CLR     PrgTmp6
    JMP     _ProbeI2CStart

;       是10位地址，第二字节加1
    INC     PrgTmp6
    JBS     StatusReg,ZeroFlag
    JMP     _ProbeI2CStart

    MOV     A,@2                    ; PrgTmp6=0, PrgTmp5 +2
    ADD     PrgTmp5,A
    JBC     PrgTmp5,3
    JMP     Tx_I2COk                ; 扫描结束
    JMP     _ProbeI2CStart


;//NOTE: ProbeI2CAddr
ProbeI2CAddr:
    MOV     A,@0x10
    MOV     PrgTmp5,A               ; 地址从 10开始
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

; 以下部分从 macro.h   M_I2CMaster201911 复制过来，进行修改
;
C_I2CSclIn_SdaOut   equ     C_I2CBusOut    +  (1<<B_SCL)
C_I2CSclOut_SdaIn   equ     C_I2CBusOut    +  (1<<B_SDA) 
C_I2CBusIn          equ     C_I2CBusOut    +  (1<<B_SCL) + (1<<B_SDA)



_E2ErrorNoAck:
_ErrorBusBusy:
	MOV		A,@0xEF
	RET

;//NOTE: I2C_BUSo0
I2C_BUSo0:                              ; SCL 输出0， SDA 输出0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy
	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	BC      P_SCL,B_SCL
	BC      P_SDA,B_SDA
    RET
;//NOTE: I2C_BUSo
I2C_BUSo:                               ; SCL 输出端口，SDA输出端口
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy

	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	RET
;**************************修改代码**2018.07.12*******************************
; 开始前， SCL,SDA 总线释放状态
;//NOTE:   I2C_Start   
;              SDA,SCL要有上拉电阻
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
I2C_SCLo_SDAo:                          ; SCL 只能输出为0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy   
	MOV     A,@C_I2CBusOut              ; 占用总线输出数据
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
; 命令字放在A中  , EPROM 传输一个命令字
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
;//NOTE:  I2C_WriteCommand
I2C_WriteCommand:
	MOV		Prgtmp3,A			; 保存数据
	MOV		A,@8
	MOV		Prgtmp4,A

_I2CWriteCommandLoop:
	CALL    I2C_SCLo_SDAo

	JBS		Prgtmp3,7           ; 设置 SDA
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
;读一个字节,  
;//TODO:  I2C_ReadByte
I2C_ReadByte:					; 退出时， SCL = 0
	CLR   	Prgtmp3
	MOV		A,@8
	MOV		Prgtmp4,A
_I2C_ReadByteLoop:				; 循环中，SCL 周期 = 11 ， 约 11*0.56= 6.2us = 160K 速度
    CALL    I2C_Get1Bit

	BC		StatusReg,CarryFlag
	JBC		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RLC		Prgtmp3

	DJZ		Prgtmp4
	JMP		_I2C_ReadByteLoop

	MOV		A,Prgtmp3			; 读出的数据放在A中	
	RET

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   PrgTmp5   设备地址      ，  B0 - 0 写数据， B0-1 读数据
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:    I2C_ReadPageData
I2C_ReadPageData:
    BC      PrgTmp5,0               ; 如果设备地址未位为1，则校正为0

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

	MOV		A,PrgTmp6               ; 10位地址 后面一个字节
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_ReadPage_ByteAddr:
	MOV		A,Prgtmp2
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck
;********************************************************************    
    CALL    I2C_GetAck                  ; 占用总线，释放总线
; 此处必须增加一个时钟，前一个读ACK结束时，从设备输出0，表示收到，增加这一个时钟
; 通知从设备已经读到了ACK，可以释放总线了。如果从设备不释放总线，下面一个开始
; 将会出错
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
;  发送完成 NOACK 接着发送 STOP 指令
    CALL    I2C_SendNoAck
;//mark:   I2C_Stop
I2C_Stop:
    CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    CALL    Wait3us
    CALL    I2C_SCLi_SDAo               ; SCL=1, SDA=0
    CALL    Wait3us
    JMP     I2C_BusIn                   ; SCL=1, SDA=1

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   PrgTmp5，PrgTmp6   设备地址  7位，10位    ，  B0 - 0 写数据， B0-1 读数据
;   Prgtmp1,  写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:I2C_WritePageData
I2C_WritePageData:
    BC      PrgTmp5,0               ; 如果设备地址未位为1，则校正为0

	CALL	I2C_Start
	MOV		A,PrgTmp5               ; 写EPROM 设备地址
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag
    JMP     _I2C_WritePage_ByteAddr

	MOV		A,PrgTmp6               ; 10位地址 后面一个字节
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
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

	JMP		I2C_Stop                ; 优化代码


;*************************************************	
LDevAddr_E2ChkBusy:
	CALL	I2C_Start
	MOV		A,PrgTmp5               ; 写EPROM 设备地址
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag
    JMP     I2C_Stop                ; 7 位地址有应答

	MOV		A,PrgTmp6               ; 10位地址 后面一个字节
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    JMP     I2C_Stop                ; 10位地址有应答
