;以下是系统定义
;PrgTmp1			equ		0x10
;PrgTmp2			equ		0x11
;PrgTmp3			equ		0x12
;PrgTmp4			equ		0x13
IntTemp             equ     PrgTmp3             ; 端口变化量，可与 PrgTmp 共用

PrgTmp5             equ     0x14
PrgTmp6             equ     PrgTmp5      +   1
SystemFlag          equ     PrgTmp6      +   1  ; 保存当前端口状态值
I2CStep             equ     SystemFlag   +   1  ;
StepBak             equ     I2CStep      +   1  ;
DataPtr             equ     StepBak      +   1  ;
CLKS                equ     DataPtr      +   1  ;
Data                equ     CLKS         +   1  ;
DevAddrByte         equ     Data         +   1  ; 从EPROM 读到的设备地址个数和地址共6个
TRFlagReg           equ     DevAddrByte  +   2  ;
Cnt16ms             equ     TRFlagReg    +   1
Cnt16msBak          equ     Cnt16ms      +   1
QuitTime            equ     Cnt16msBak   +   1
KeyStep             equ     QuitTime     +   1
KeyCodeLast         equ     KeyStep      +   1  ; 5个开关，5个标志位
KeyCodeCurrent      equ     KeyCodeLast  +   1  ; 5个开关，5个标志位
TxUartFlag          equ     KeyCodeCurrent  +   1 ; 发送标志位
EnKeyReg            equ     TxUartFlag   +   1
UartBuf             equ     EnKeyReg     +   1

;RelayStatus         equ     CtrlByte     +   1
;ReadID              equ     DevAddrByte  +   1

DataBufEnd          equ     0x2F
DataBuf             equ     DataBufEnd - C_RelayNum +1

CtrlByte            equ     DataBuf
Key1Cnt             equ     DataBuf        ; 转数寄存器地址共5字节
