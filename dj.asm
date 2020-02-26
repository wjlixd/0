

    C_TxStartStep       ==      1

	ORG     0x08
    MOV     A,@~C_UartTcc
    MOV     TCC,A

    MOV     A,RxStep
    ADD     PC,A         
    JMP     _IntTccEnd          ;0  
    JMP     _IntTx_Start        ;1
    JMP     _IntTx_Bit          ;2
    JMP     _IntTx_Bit          ;3
    JMP     _IntTx_Bit          ;4
    JMP     _IntTx_Bit          ;5
    JMP     _IntTx_Bit          ;6
    JMP     _IntTx_Bit          ;7
    JMP     _IntTx_Bit          ;8
    JMP     _IntTx_Bit          ;9
    JMP     _IntTx_Stop         ;10
    JMP     _IntTx_StopEnd      ;11


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
    MOV     A,@C_TxStartStep
    MOV     TxStep,A
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

    MOV     A,@C_TxStartStep        ; 下次中断时间到开始发送数据
    MOV     TxStep,A

    BC      SysFlag,F_TxEnd
    ENI

    JMP     main    
