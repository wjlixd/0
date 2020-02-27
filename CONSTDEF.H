;****************************************************
;标志位定义
;SysFlag
	F_WaitTime		==  0		; I2C 时钟中断标志
    F_SDA_SancFail  ==  1       ; SDA 仲裁失败，退出总线竞争
	F_StartCnt      ==  4       ; UART接收开始计时，接收一个字节后开始计时，超时则退出
    F_RxByte        ==  5		; UART 接收到一个字节
    F_TxEnd         ==  6       ; UART 数据包发送完成
    F_BaudTimer     ==  7       ; 接收UART时，进行超时计时标志，超时无数据，则帧出错

    F_CmdReset      ==  F_SDA_SancFail
;****************************************************
    C_DevAddrBytes    ==    5
	
    C_PackStartErr      ==  01
    C_PackEndErr        ==  C_PackStartErr
    C_PackSizeErr       ==  C_PackStartErr
    C_ReturnOk          ==  C_PackStartErr   +   1
    C_I2CErr            ==  C_ReturnOk       +   1
    C_I2COk             ==  C_I2CErr         +   1
    C_I2CReturnData     ==  C_I2COk          +   1
    C_ReturnConfigData  ==  C_I2CReturnData  +   1

    C_RxBufSize     ==  11

    C_PackFlag      ==  0x7E
    C_I2CNoAckFlag  ==  0xEF

;I2CClock
      ; 1 - 用I2C,  1 -  TX/RX 波特率   
    C_BaudMask  ==      0B00000011  ; 4种波特率  B1-B0
    C_I2CPHMask    ==   0B00001100  ; 上拉电阻
    C_I2CTimerMask ==   0B01110000  ; 用于定时器中断，只取低3位， 0-7
    C_I2CDispMask  ==   0B11110000  ; 显示返回值，0 -15
    F_Timer        ==   7           ; B7-0 Wait3us使用指令循环来等待。   B7-1 Wait3us使用定时器中断来等待

; TimerCnt  ==    OpMode
; OpMode 使用B6,B7
; TimerCnt 使用 B0-B6
    C_TimerMask    ==   0x3F
    C_CTSWait      ==   15

    C_ReadBufSize   ==      8
    C_CTSBufSize    ==      C_ReadBufSize
    
    
    C_TxCmd_Data         ==    0
    C_TxCmd_I2CRead      ==    1
    C_TxCmd_Reset        ==    2
    C_TxCmd_ProbeAddr    ==    3
    C_TxCmd_Wait         ==    4
    C_TxCmd_WriteI2C     ==    5


    C_TxStartStep   ==  10
    C_I2cWait       ==  21    

        Crystal   ==   12

if Crystal == 12                ; 晶体选用12M晶振，设置参数
    C_UartTcc      == 77
    C_UartTcc1P5   == 115
    C_UartCont == 0b01000010;  
endif

if Crystal == 8                 ; 晶体选用8.192M晶振，设置参数
    C_UartTcc      == 102
    C_UartTcc1P5   == 150
    C_UartCont == 0b01000001;  
endif

if Crystal == 16                 ; 晶体选用8.192M晶振，设置参数
    C_UartTcc      == 102        ;102,-[96-106]  
    C_UartTcc1P5   == 153
    C_UartCont == 0b01000010;  
endif
