;以下是系统定义
; PrgTmp1			equ		0x10
; PrgTmp2			equ		0x11
; PrgTmp3			equ		0x12
; PrgTmp4			equ		0x13
; Inttmp1			equ		0x14
; Inttmp2			equ		0x15
; Inttmp3			equ		0x16
; Inttmp4			equ		0x17
; SysFlag			equ		0x18		;与时间有关的标志
; OpMode			   equ		0x19

TccBak              equ    IntTmp3

TimerCnt            equ    0x1A
RxStep              equ    TimerCnt  + 1                              ;1A   
RxData              equ    RxStep    + 1                     ;1B 1个RAM
RxBufPtr            equ    RxData    + 1                     ;1C 1个RAM
RxStatus            equ    RxBufPtr  + 1                     ;1D 1个RAM
I2CClock            equ    RxStatus  + 1                     ;1E 1个RAM
I2CDevAddr          equ    I2CClock  + 1                     ;1F,20 , 2个RAM
RxBuf               equ    (I2CDevAddr+ 2)                   ;25-2F,共11个RAM
;**************************************
   RxPackStart  ==  RxBuf
   RxPackSize   ==  RxBuf   +  1

   I2CCmd       ==  RxBuf   +  2

;  对I2C进行处理时，无UART 中断
   PrgTmp5      ==  I2CDevAddr
   PrgTmp6      ==  I2CDevAddr + 1

;*********************************************************
;  接收发送不同时进行，可共用RAM
TxStep      ==    RxStep                     ;  1A
TxData	   ==    RxData                     ;  1B
TxBufPtr    ==    RxBufPtr                   ;  1C 
TxBufEndPtr ==    RxStatus                   ;  1D 

TxBuf       ==    RxBuf                      ;  25 

; TimerCnt    ==    OpMode     ; TimerCnt改为单独使用RAM， OPMODE相同
; OpMode 使用B6,B7
; TimerCnt 使用 B0-B6

TxCmd       ==    TxBuf