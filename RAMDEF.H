
;以下是系统定义
;PrgTmp1			equ		0x10
;PrgTmp2			equ		0x11
;PrgTmp3			equ		0x12
;PrgTmp4			equ		0x13
IntTemp             equ     PrgTmp3             ; 端口变化量，可与 PrgTmp 共用

PrgTmp5             equ     0x14
PrgTmp6             equ     PrgTmp5      +   1
PrgTmp7             equ     PrgTmp6      +   1  ; 保存当前端口状态值
SystemFlag          equ     PrgTmp7      +   1  ; 保存当前端口状态值
I2CStep             equ     SystemFlag   +   1  ;
DevAddrByte         equ     I2CStep      +   1  ;
TRFlagReg           equ     DevAddrByte  +   2  ; 1B
;************************************************************
StepBak             equ     TRFlagReg    +   1  ;       ;  1B
DataPtr             equ     StepBak      +   1  ;       ;  1C
CLKS                equ     DataPtr      +   1  ;       ;  1D    
Data                equ     CLKS         +   1  ;       ;  1E
;************************************************************
Cnt16ms             equ     TRFlagReg       +4  ;
KeyTime             equ     Cnt16ms         +1  ; 1D
Cnt16msBak          equ     KeyTime         +1
KeyDownCounter	    equ     Cnt16msBak      +1  ; 1E
KeyCounter	        equ     KeyDownCounter	+1  ; 1F
TRMode              equ     KeyCounter	    +1  ; 
IntKeyValue	    	equ     TRMode          +1
QuitTime            equ     IntKeyValue	    +1  ; 
ChannelNums         equ     QuitTime        +1
SetMode             equ     ChannelNums     +1  ;       ;  1F
;************************************************************
DataBuf             equ     SetMode         +1  ;       ;  1F

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

SPI_Mode            ==      DevAddrByte
Ep_Mode             ==      DevAddrByte  + 1
InfoSN              ==      I2CStep         ; 全程变量，不能共用

; idle 接收使用RAM     SetMode -- 记录按键次数, SPI_Mode -- SPI收发参数
MyNode              ==      SetMode
