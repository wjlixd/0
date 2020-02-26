;以下是系统定义
;PrgTmp1			equ		0x10
;PrgTmp2			equ		0x11
;PrgTmp3			equ		0x12
;PrgTmp4			equ		0x13
IntTemp             equ     PrgTmp3             ; 端口变化量，可与 PrgTmp 共用

SystemFlag          equ     Inttmp3             ; 保存当前端口状态值

PrgTmp5             equ     0x18
PrgTmp6             equ     PrgTmp5      +   1
I2CStep             equ     PrgTmp6      +   1  ;
StepBak             equ     I2CStep      +   1  ;
DataPtr             equ     StepBak      +   1  ;
CLKS                equ     DataPtr      +   1  ;
Data                equ     CLKS         +   1  ;
DevAddrByte         equ     Data         +   1  ; 从EPROM 读到的设备地址个数和地址共6个
DataBuf             equ     DevAddrByte  +   2  ;


CtrlByte            equ     DataBuf
RelayStatus         equ     CtrlByte     +   1
ReadID              equ     DevAddrByte  +   1

DataBufEnd          equ     0x2F


TxStep              ==      I2CStep
TxBufPtr            ==      StepBak
TxBufEndPtr         ==      DataPtr
TxData              ==      Data