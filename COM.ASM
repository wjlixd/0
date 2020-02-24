
;*****************************************************************************
    ; M_RF24L01
;*******************************************************************
; main 循环中增加以上，当中断产生时，读接收数据，并清除缓冲区，中断标志
;  JBS     P_IRQ,B_IRQ          
;  CALL    nRF24L01_RxPacket
;*******************************************************************
;*******************************************************************
; ;RF24L01 发送端，接收端地址，此表格要放在开始位置
;   CALL    init_NRF24L01     ; 程序复位要初始化RF24L01
; 
; TX_ADDRESS:                 ; 本地地址
; RX_ADDRESS:                 ; 接收端地址
;     RETL    @0x34
;     RETL    @0x43
;     RETL    @0x10
;     RETL    @0x10
;     RETL    @0x01
;*******************************************************************
; 以下是端口定义，要在PORTDEF.H中定义
; P_CE            equ     Port6       ; 输出至RF， RX/TX模式选择
; B_CE            equ     1
                                
; P_CSN           equ     Port6
; B_CSN           equ     2           ; 输出至RF, SPI EN信号
                                
; P_SCK           equ     Port6
; B_SCK           equ     0           ; 输出至RF, SPI CLK信号
                                
; PO_MOSI         equ     Port5
; BO_MOSI         equ     3           ; 输出至RF，向24L01输出数据
                                
; PI_MISO         equ     Port5
; BI_MISO         equ     2           ; 从RF读数据，
                                
; P_IRQ           equ     Port5       ; RF数据完成，产生中断
; B_IRQ           equ     1           


;//MARK: 常数

    PLOAD_WIDTH_SET    ==  7                ; 传输收发参数，长度 = 7
    PLOAD_WIDTH_DATA   ==  PLOAD_WIDTH_SET  ; 传输收发数据，长度 = 1

    TX_ADR_WIDTH   ==  3    ; 发送地址宽度
    RX_ADR_WIDTH   ==  TX_ADR_WIDTH

;//MARK: nRF24L01-操作命令
; nRF24L01 收发数据部分
    READ_REG        ==  0x00
    WRITE_REG       ==  0x20
    RD_RX_PLOAD     ==  0x61    ; 读取接收数据指令
    WR_TX_PLOAD     ==  0xA0    ; 写待发数据指令
    FLUSH_TX        ==  0xE1    ; 冲洗发送 FIFO
    FLUSH_RX        ==  0xE2    ;     接收
    REUSE_TX_PL     ==  0xE3    ; 重复装载数据
    C_Nop           ==  0xFF
;//MARK: nRF24L01-寄存器
    CONFIG          ==  0x00    ; 配置收发状态，CRC,收发状态响应方式
    EN_AA           ==  0x01    ; 自动应答功能设置
    EN_RXADDR       ==  0x02    ; 可用信道
    SETUP_AW        ==  0x03    ; 地址宽度
    SETUP_RETR      ==  0x04    ; 自动重发
    RF_CH           ==  0x05    ; 工作频率
    RF_SETUP        ==  0x06    ; 发射速率，功耗
    STATUS          ==  0x07    ; 状态字
        RX_DR           ==  6
            ;接收数据中断。当接收到有效数据后置一。写‘1’清除中断。
        TX_DS           ==  5
            ;数据发送完成中断。当数据发送完成后产生中断。如果工作在自动应答模式下，只有当接收到应答信号后此位置一。写‘1’清除中断。
        MAX_RT          ==  4       
            ;达到最多次重发中断。写‘1’清除中断。如果MAX_RT 中断产生则必须清除后系统才能进行通讯。
    OBSERVE_TX      ==  0x08    ; 发送检测
    CD              ==  0x09    ; 地址检测
    RX_ADDR_P0      ==  0x0A    ; 频道0接收数据地址
    RX_ADDR_P1      ==  0x0B    ; 频道1接收数据地址
    RX_ADDR_P2      ==  0x0C    ; 频道2接收数据地址
    RX_ADDR_P3      ==  0x0D    ; 频道3接收数据地址
    RX_ADDR_P4      ==  0x0E    ; 频道4接收数据地址
    RX_ADDR_P5      ==  0x0F    ; 频道5接收数据地址
    TX_ADDR         ==  0x10    ; 发送地址寄存器
    RX_PW_P0        ==  0x11    ; 接收频道0接收数据长度
    RX_PW_P1        ==  0x12    ; 接收频道0接收数据长度
    RX_PW_P2        ==  0x13    ; 接收频道0接收数据长度
    RX_PW_P3        ==  0x14    ; 接收频道0接收数据长度
    RX_PW_P4        ==  0x15    ; 接收频道0接收数据长度
    RX_PW_P5        ==  0x16    ; 接收频道0接收数据长度
    FIFO_STATUS     ==  0x17    ; 
;//TODO: SPI_WRITEBYTE - 写一个字节
SPI_WRITEBYTE:
    MOV     PrgTmp3,A
    MOV     A,@8
    MOV     PrgTmp4,A           ; 8个时钟
;LOOP
    RLC     PrgTmp3             ; 数据高位在前

    JBC     StatusReg,CarryFlag             ; 数据建立
    BS      PO_MOSI,BO_MOSI
    JBS     StatusReg,CarryFlag
    BC      PO_MOSI,BO_MOSI

    BS      P_SCK,B_SCK
    BC      P_SCK,B_SCK
    DJZ     PrgTmp4
    JMP     $-8
    RET
;//TODO: SPI_READBYTE - 读一个字节
SPI_READBYTE:
    MOV     A,@8
    MOV     PrgTmp4,A           ; 8个时钟
;LOOP
    BS      P_SCK,B_SCK

    BC      StatusReg,CarryFlag             ; 数据建立
    JBC     PI_MISO,BI_MISO
    BS      StatusReg,CarryFlag             ; 数据建立
    RLC     PrgTmp3

    BC      P_SCK,B_SCK

    DJZ     PrgTmp4
    JMP     $-7
    MOV     A,PrgTmp3
    RET
;//TODO: SPI_READSTATUS - SPI读的第一个字节是状态字
SPI_READSTATUS:
    BS      PO_MOSI,BO_MOSI                  ; 指令为 FF = NULL 空指令
    BC      P_CSN,B_CSN
    CALL    SPI_READBYTE
    BS      P_CSN,B_CSN
    RET

;******************************************
;//TODO: SPI_RW_Reg
; 将数据写到寄存器中
;   PrgTmp1 - [value]
;   [A] - [reg]
SPI_RW_Reg:
    BC      P_CSN,B_CSN
    CALL    SPI_WRITEBYTE

    MOV     A,PrgTmp1
    CALL    SPI_WRITEBYTE
    BS      P_CSN,B_CSN
    RET
;******************************************
;//TODO: ReadSpiData - ; 从SPI缓冲区读数据 
ReadSpiData:
    BC      P_CE,B_CE               ; 读数据
    CALL    SetSPIDataParam

    MOV     A,@RD_RX_PLOAD
;//NOTE: SPI_Read_Buf
;   RamSelReg  -  读出数据存储地址  
;   PrgTmp1 - 读数据个数
;   [A] - 要读寄存器地址
;
SPI_Read_Buf:
    BC      P_CSN,B_CSN

    CALL    SPI_WRITEBYTE

    CALL    SPI_READBYTE
    MOV     R0,A
    INC     RamSelReg
    DJZ     PrgTmp1
    JMP     $-4

    BS      P_CSN,B_CSN

    RET
;******************************************
;//NOTE:  SPI_Write_Buf
;   RamSelReg  -  写数据地址  
;   PrgTmp1 - 读数据个数
;   [A] - 要读寄存器地址
;
SPI_Write_Buf:
    BC      P_CSN,B_CSN

    CALL    SPI_WRITEBYTE

    MOV     A,R0
    CALL    SPI_WRITEBYTE
    INC     RamSelReg
    DJZ     PrgTmp1
    JMP     $-4

    BS      P_CSN,B_CSN

    RET
;******************************************
SetSPI_RETR:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+SETUP_RETR      ; 频道0自动 ACK 应答允许
    JMP     SPI_RW_Reg
SetSPI_ENAA:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+EN_AA      ; 频道0自动 ACK 应答允许
    JMP     SPI_RW_Reg
SetSPI_SETUP_AW:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+SETUP_AW  ; 允许接收地址只有频道0，如果需要多频道可以参考page21    
    JMP     SPI_RW_Reg
SetSPI_EN_RXADDR:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+EN_RXADDR  ; 允许接收地址只有频道0，如果需要多频道可以参考page21    
    JMP     SPI_RW_Reg
SetSPI_RF_CH:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+RF_CH      ; 设置信道工作为2.4Ghz,收发必须一致
    JMP     SPI_RW_Reg
SetSPI_RX_PW_P0:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+RX_PW_P0   ; 设置接收数据长度，本次设置32字节
    JMP     SPI_RW_Reg
SetSPI_RF_SETUP:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+RF_SETUP   ; 设置发射速率为1MHZ，发射功率为最大0dB
    JMP     SPI_RW_Reg
SetSPI_CLRIRQ:
    MOV     A,@(1<<MAX_RT) | (1<<RX_DR) | (1<<TX_DS)
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+STATUS     ; 接收到数据后，RX_DR,TX_DS,MAX_PT都置1，通过写1清除中断标志
    JMP     SPI_RW_Reg
SetSPI_CONFIG:
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+CONFIG     ; IRQ收发完成中断响应，16位CRC,主接收   设置为接收模式
    JMP     SPI_RW_Reg
SetSPI_FLUSH_TX:
    MOV     A,@FLUSH_TX
    JMP     $+2
SetSPI_FLUSH_RX:
    MOV     A,@FLUSH_RX
    BC      P_CSN,B_CSN
    CALL    SPI_WRITEBYTE           ; 清除接收缓冲区
    BS      P_CSN,B_CSN
    RET

;******************************************************** 
BufferInitTx:
    BC      P_CE,B_CE               ; 进入待机模式，传输数据设置

    CALL    SetSPI_CLRIRQ

    MOV     A,@0x01
    CALL    SetSPI_SETUP_AW         ; 地址宽度为3字节

    CALL    SetTRAddrParam
    MOV     A,@WRITE_REG+TX_ADDR    ; TX ADDR  3个字节
    CALL    SPI_Write_Buf           ; 写TX地址

    CALL    SetTRAddrParam
    MOV     A,@WRITE_REG+RX_ADDR_P0
    CALL    SPI_Write_Buf           ; 写RX地址

    MOV     A,@0x01
    CALL    SetSPI_ENAA

    MOV     A,@0x01
    CALL    SetSPI_EN_RXADDR

    MOV     A,@0x3E                 ; 重发延时 1ms , 重发次数=14
    CALL    SetSPI_RETR

    MOV     A,RF_Data+3             ; 信道号
    CALL    SetSPI_RF_CH

    MOV     A,@PLOAD_WIDTH_SET
    CALL    SetSPI_RX_PW_P0

    MOV     A,@0x07
    CALL    SetSPI_RF_SETUP
    RET

;*************************************
WaitTxTime_Mode:
    MOV     TRMode,A
    MOV     A,@C_WaitEpTime         ; 5*30= 150MS
    MOV     QuitTime,A
    BS      TRFlagReg,F_QuitTime32ms
    RET
; 用于3秒快闪，  15秒等待按键输入
SetQuitTime_500ms:
    MOV     QuitTime,A
    BC      TRFlagReg,F_QuitTime32ms
    RET

;*************************************
FLed_SlowBlink:
    MOV     A,@1<<B_LED
    JBC     TRFlagReg,F_500ms   ; 慢闪
    XOR     P_LED,A
    BC      TRFlagReg,F_500ms
    RET


ChkKeyDown:
    BC      StatusReg,CarryFlag
    JBS     IntKeyValue,B_KeyUp
    RET

    JBS     IntKeyValue,B_KeyDown
    RET
    BC      IntKeyValue,B_KeyDown           ; 单按键发送 TX 信道码
    BS      StatusReg,CarryFlag
    RET


ResetQuitTime_Mode:
    MOV     TRMode,A

    MOV     A,@C_WaitKeyTime
    CALL    SetQuitTime_500ms
ClearKeyFlag:                       ; 按键标志2个，B_KeyDown，B_KeyDown3s可清除
    MOV     A,@~C_KeyFlagMask
    AND     IntKeyValue,A
    RET

;************************************************
;  接收转为发送模式，因为发送即时完成，需要等待接收端准备好才可以发送，
;  所以需要加入等待时间
;      发送转接收不需要等待时间
PresetRx2Tx:
    MOV     A,@C_WaitRx2TxEnd
    CALL    WaitTxTime_Mode
WaitRx2TxEnd:
    DJZA    QuitTime
    JMP     main      
    JMP     _TxCode4B+1
;*************************************************
IdlePress5Key:
PresetTxData:
    SWAPA   ChannelNums             ; 根据 ChannelNums -- 转为 TxCh 地址，设置发送信道 
    ADD     A,@C_EpAddr_TxChannel-0x10
    JBC     TRFlagReg,F_Config
    MOV     A,@C_E2Addr_Config      ; Config地址

    CALL    SetEpParamCh0
    MOV     A,@C_ReadEp_TxCode4B
    JMP     PresetReadEp
_TxCode4B:
    CALL    BufferInitTx            ; 设置信道数据

    BC      P_CE,B_CE               ; Standby 模式
    CALL    SetSPI_CLRIRQ
    MOV     A,@0x4E                 ; 发送/溢出中断，发送模式
    CALL    SetSPI_CONFIG
    CALL    SetSPI_FLUSH_TX         ; 清除SPI缓冲区

    JMP     _SetTxDataTable         ; 去设置打包数据包

_SetTxDataEnd:
    CALL    SetSPIDataParam
    MOV     A,@WR_TX_PLOAD    
    CALL    SPI_Write_Buf           ; 装载数据

    BS      P_CE,B_CE               ; 激励发射

    MOV     A,@C_WaitTxDataEnd      ; 
    CALL    WaitTxTime_Mode         ; 设置发送等待时间
    CALL    ClrFailFlag
;************************************************
;// WaitTxDataEnd 等待发送信道码完成，变为接收模式
WaitTxDataEnd:
    JBC     P_IRQ,B_IRQ
    JMP     $+5

    CALL    SPI_READSTATUS
    JBC     PrgTmp3,TX_DS
    JMP     _SaveTestTData
    JMP     $+3

    DJZA    QuitTime
    JMP     main
    BS      EpNum,F_TFail           ; 发送失败
_SaveTestTData:
    CALL    SetEp_TData
    MOV     A,@C_SaveEp_TData       ;保存测试数据
    JBC     TRFlagReg,F_EpTRData
    JMP     PresetSaveEp

_SetTxData_SaveTData:
    JBS    EpNum,F_TFail
    JMP     _TxDataEndTable         ; 数据发送成功
    JMP     _TxFailTable			; 超次数重发
;************************************************
;//MARK: 接收数据进程
PresetRxData:
    MOV     A,@C_EpAddr_RxChannel
    JBC     TRFlagReg,F_Config
    MOV     A,@C_E2Addr_Config
    CALL    SetEpParamCh0
    MOV     A,@C_ReadEp_RxCode4B
    JMP     PresetReadEp            ; 读接收信道码 4B

_RxCode4B:
    CALL    BufferInitTx            ; 设置接收参数
_Tx2Rx:
PresetTx2Rx:                        ; 发射转为接收模式
    BC      P_CE,B_CE
    CALL    SetSPI_CLRIRQ           ; 清除IRQ中断
    MOV     A,@0x3F                 ; 接收中断，接收模式
    CALL    SetSPI_CONFIG

    CALL    SetSPI_FLUSH_RX         ; 清除SPI接收缓冲区
    BS      P_CE,B_CE      

    JBS     TRFlagReg,F_Config
    JMP     ResetKeyCnt

    MOV     A,@C_WaitRxDataReturn
    CALL    ResetQuitTime_Mode
    CALL    ClrFailFlag
;************************************************
WaitRxDataReturn:                   ; 等待接收端返回节点数据
    CALL    FLed_SlowBlink
    DJZA    QuitTime
    JMP     $+3
    BS      EpNum,F_RFail
    JMP     _SaveTestRData
CheckRxIRQ:
    JBC     P_IRQ,B_IRQ
    JMP     main

    BC      EpNum,F_RFail
    CALL    ReadSpiData             ; 从SPI缓冲区读数据
_SaveTestRData:    
    CALL    SetEp_RData
    MOV     A,@C_SaveEp_RData       ;保存测试数据
    JBC     TRFlagReg,F_EpTRData
    JMP     PresetSaveEp            ; 转到数据处理列表
    
_SetRxData_SaveRData:
    JBS     EpNum,F_RFail
    JMP     _RxDataEndTable         ; 接收到数据处理列表
    JMP     _RxTimeOverTable
;************************************************
;//MARK:    保存EPROM进程
PresetSaveEp:
    MOV     Ep_Mode,A
    MOV     A,@C_SaveEpromData
    CALL    WaitTxTime_Mode
SaveEpromData:
    MOV     A,Buf_EpAddr
    MOV     PrgTmp2,A
    MOV     A,Buf_RamAddr
    MOV     RamSelReg,A
    MOV     A,Buf_RamSize
    MOV     PrgTmp1,A
    CALL    I2C_WritePageData
    JBS     StatusReg,CarryFlag
    JMP     _SaveSucessTable        ; EPROM 正常

    DJZA    QuitTime
    JMP     main   
    JMP     _SaveFailTable
;*************************************************
;//MARK: 读EPROM进程
PresetReadEp:
    MOV     Ep_Mode,A
    MOV     A,@C_ReadEpromData
    CALL    WaitTxTime_Mode
ReadEpromData:
    MOV     A,Buf_EpAddr
    MOV     PrgTmp2,A
    MOV     A,Buf_RamAddr
    MOV     RamSelReg,A
    MOV     A,Buf_RamSize
    MOV     PrgTmp1,A
    CALL    I2C_ReadPageData
    JBS     StatusReg,CarryFlag
    JMP     _ReadSucessTable                    ; EPROM 正常，灯不闪

    DJZA    QuitTime
    JMP     main   
    JMP     _ReadFailTable
;***************************************************
ClrFailFlag:
    BC      EpNum,F_TFail
    BC      EpNum,F_RFail
    RET
;************************************************
Wait3us:
    JBS     TRFlagReg,F_I2CSlow     ; I2C 速度慢，需要等待
    RET
    MOV     A,@60
    ADD     A,@0xFF                     ; 3*A+5
    JBS     StatusReg,ZeroFlag
    JMP     $-2
    RET
;************************************************

;*********************************************************
C_I2CSclIn_SdaOut   equ     C_I2CBusOut    +  (1<<B_SCL)
C_I2CSclOut_SdaIn   equ     C_I2CBusOut    +  (1<<B_SDA) 
C_I2CBusIn          equ     C_I2CBusOut    +  (1<<B_SCL) + (1<<B_SDA)



_E2ErrorNoAck:
_ErrorBusBusy:
	BS      StatusReg,CarryFlag
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
    JMP     Wait3us    

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
	; RET
	JMP     Wait3us
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
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:    I2C_ReadPageData
I2C_ReadPageData:
	CALL	I2C_Start
	MOV		A,@0xA0            
	CALL	I2C_WriteCommand
	JBC     P_SDA,B_SDA		
	JMP		_E2ErrorNoAck

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
	MOV     A,@0xA1
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
_I2CReadPageEnd:
;  发送完成 NOACK 接着发送 STOP 指令
    CALL    I2C_SendNoAck
;//mark:   I2C_Stop
I2C_Stop:
    CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    CALL    Wait3us    
    CALL    I2C_SCLi_SDAo               ; SCL=1, SDA=0
    CALL    Wait3us    
    CALL    I2C_BusIn                   ; SCL=1, SDA=1
    BC      StatusReg,CarryFlag
    RET
;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,  写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:I2C_WritePageData
I2C_WritePageData:
    BC      I2CAddr,0
	CALL	I2C_Start
	MOV		A,I2CAddr           
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

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
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:    I2C_CompPageData   
;        比较缓冲区是否与EPROM地址上的数据相同, 相同 F_FindSame = 1
I2C_CompPageData:
	CALL	I2C_Start
	MOV		A,@0xA0            
	CALL	I2C_WriteCommand
	JBC     P_SDA,B_SDA		
	JMP		_E2ErrorNoAck

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
	MOV     A,@0xA1
    CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    JMP     $+2
_I2CCompPageLoop:
	CALL	I2C_SendAck

	CALL	I2C_ReadByte
    XOR     A,R0
    JBS     StatusReg,ZeroFlag
    JMP     _I2CReadPageEnd

	INC		RamSelReg

	DJZ		Prgtmp1
	JMP		_I2CCompPageLoop

    BS      TRFlagReg,F_FindSame
    JMP     _I2CReadPageEnd
;********************************************************************    
