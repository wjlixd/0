;****************************************************
;SystemFlag
;   PORTDEF.H 中已经定义 
F_I2CSlaver         equ      0       ; =1 时，检测到 I2C总线活动，不再处理按键，收发数据 ; I2C总线结束后， 自动清0
F_SDAInput          equ      1
F_AddrMarried       equ      2       ;10位地址匹配成功
F_DataValid         equ      3       ; I2C 总线正常结束
; SlaverSDA       equ     4
; SlaverSCL       equ     5
F_WDevAddr          equ      6
F_16ms              equ      7       ; 
F_32ms              equ      F_AddrMarried
;****************************************************
;TRFlagReg         
    F_QuitTime32ms  equ      4      ; 0 - QuitTime每500ms减1， 1-QuitTime 每32ms减1
    F_500ms         equ      3      ; 1 - 500ms 时间到，
    F_250ms         equ      2      ; 1 - 250ms 时间到
    F_EnSlep        equ      1      ; 0 - 允许进入睡眠，1 - 禁止睡眠
    F_EpTRData      equ      0      ; 0 - 不保存收发数据， 1 - 保存收发数据
;****************************************************
	C_QuitTime		==		30
	C_ChannelSize   ==      4
	C_Time2s        ==      64
;*******************************************************
; eprom 地址分配
    C_E2Addr_DevAddr            ==   0x00   ; 0x00   7位地址;
                                            ; 0x01   10位地址
    C_E2Addr_Sleep              ==   0x02

    C_E2Addr_Config             ==   0x03

    C_E2Addr_TData              ==   0x08   ; 发送数据保存
    C_E2Addr_RData              ==   0x17   ; 接收数据保存

    C_EpAddr_RxChannel          ==   0x20   ; 接收信道参数,开关，不接收，这个参数无用

    C_E2Addr_MyNode             ==   0x23   ; MyNode
    C_E2Addr_MaxNode            ==   0x24   ; MaxNode
    C_E2Addr_TxChannelNums      ==   0x25   ; 发送信道数
    C_E2Addr_SWNums             ==   0x26   ; 设置开关数


    C_EpAddr_TxChannel          ==  0x30            ; 发送信道 40,50,60,70  共保存5组
                                ; 0x10   正常发射的信道
                                ; 0x11   数据通道0  地址1
                                ; 0x12   数据通道0  地址2
                                ; 0x13   数据通道0  地址3
                                ; 0x14   数据通道0  地址4
                                ; 0x15   数据通道0  地址5
                                ; 0x16   检验和



;IntKeyValue
;   0B X000 XX00
;       | |   ++-------------键值
;       +-+------------------扫描码 
   	B_KeyDown		==		7			; 按键按下100ms后置1
	B_KeyUp			==		3			; 按键弹起100ms后置1
	B_KeyDown3s		==		2			; 按键按下3秒后置1

	C_ScanCodeMask  ==      0x70
    C_KeyValueMask  ==      0x03

    C_KeyFlagMask   ==      (1<<B_KeyDown)  | (1<<B_KeyDown3s)

    C_KeyValueSW    ==      1
    C_KeyValueRst   ==      3

    C_RFType        ==     01
    C_RFReturn      ==     02
    C_NodeType      ==     03
    C_NodeReturn    ==     04    
    C_SWType        ==     05
    C_SWTypeReturn  ==     06
    C_KeyNodeType   ==     07


    C_MaxChannel    ==     10            ;  TX, RX 相同
    C_MaxCH         ==     125           ; nRF24L01,共125个信道
    C_MaxSWNum      ==     20            ; SWNum 复位后，在设置时不保存，始终为 0，SW可以无限制设置
; SWNum 是一个开关，只允许设置10个控制终端
; TxChannel 是下一级


;EpNum
    F_TFail        ==      7
    F_RFail        ==      6