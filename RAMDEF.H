
;以下是系统定义
;PrgTmp1			equ		0x10
;PrgTmp2			equ		0x11
;PrgTmp3			equ		0x12
;PrgTmp4			equ		0x13
IntTemp             equ     PrgTmp3             ; 端口变化量，可与 PrgTmp 共用

PrgTmp5             equ     0x14
PrgTmp6             equ     PrgTmp5      +   1
PrgTmp7             equ     PrgTmp6      +   1  ; 保存当前端口状态值
TRFlagReg           equ     PrgTmp7      +   1  ; 保存当前端口状态值
;************************************************************   i2c slaver 使用RAM
; SystemFlag          equ     TRFlagReg    +   1
; I2CStep             equ     SystemFlag   +   1  ;
; DevAddrByte         equ     I2CStep      +   1  ;
; StepBak             equ     DevAddrByte  +   2  ;       ;  1B
; DataPtr             equ     StepBak      +   1  ;       ;  1C
; CLKS                equ     DataPtr      +   1  ;       ;  1D    
; Data                equ     CLKS         +   1  ;       ;  1E
;************************************************************
Cnt16ms             equ     0x1F
KeyTime             equ     Cnt16ms         +1  ; 1D
Cnt16msBak          equ     KeyTime         +1
KeyDownCounter	    equ     Cnt16msBak      +1  ; 1E
KeyCounter	        equ     KeyDownCounter	+1  ; 1F
TRMode              equ     KeyCounter	    +1  ; 
IntKeyValue	    	equ     TRMode          +1
QuitTime            equ     IntKeyValue	    +1  ; 
ChannelNums         equ     QuitTime        +1
EpNum               equ     ChannelNums     +1
;************************************************************
DataBuf             equ     EpNum           +1
DataBufEnd          equ     0x2F

RF_Data             equ     DataBuf
;************************************************************
; SWInfo 定义
SW_InfoNum          ==      RF_Data             ; 信息序号
SW_KeyValue         ==      RF_Data      +   1
SW_Node             ==      RF_Data      +   2
SW_Bit              ==      RF_Data      +   3
;************************************************************
; 设置节点定义
RF_MaxNode          ==      RF_Data
RF_InfoType         ==      RF_Data      +   6
;************************************************************
KeyValue            ==      RF_Data      +   5

;************************************************************
; channelnums    ; 我的接收信道号
RF_InfoSN           ==      RF_Data     +   2
RF_MyNode           ==      RF_Data     +   3
RF_SWNode           ==      RF_Data     +   4
RF_SWKey            ==      RF_Data     +   5


Buf_RamAddr         ==      PrgTmp5
Buf_RamSize         ==      PrgTmp6
Buf_EpAddr          ==      PrgTmp7

SPI_Mode            ==      TRFlagReg    +   1
Ep_Mode             ==      TRFlagReg    +   2
InfoSN              ==      TRFlagReg    +   3

; idle 接收使用RAM     SetMode -- 记录按键次数, SPI_Mode -- SPI收发参数
SetMode             ==      TRFlagReg    +   4
MyNode              ==      TRFlagReg    +   4
RelayStatus         ==      TRFlagReg    +   5
I2CAddr             ==      TRFlagReg    +   6