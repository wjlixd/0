;****************************************************
;SystemFlag
;   PORTDEF.H 中已经定义 
F_I2CSlaver         equ      4       ; =1 时，检测到 I2C总线活动，不再处理按键，收发数据 ; I2C总线结束后， 自动清0
F_SDAInput          equ      5
F_AddrMarried       equ      2       ;10位地址匹配成功
F_DataValid         equ      3       ; I2C 总线正常结束
; SlaverSDA       equ     0
; SlaverSCL       equ     1
F_WDevAddr          equ      6
F_16ms              equ      7       ; 
F_32ms              equ      F_AddrMarried
;****************************************************
;TRFlagReg         
    F_QuitTime32ms  equ      4      ; 0 - QuitTime每500ms减1， 1-QuitTime 每32ms减1
    F_500ms         equ      3      ; 1 - 500ms 时间到，
    F_250ms         equ      2      ; 1 - 250ms 时间到

    F_SWInf         equ      0      ; 0 - RF信息， 1 - 开关信息 
;****************************************************
    C_DevAddrBytes    ==    2

	C_QuitTime		==		30
	C_ChannelSize   ==      7
	C_Time2s        ==      64
	C_StartChannelNumber==  2
	C_MaxChannelNumber   == 124

;*******************************************************
; eprom 地址分配
    C_E2Addr_DevAddr            ==   0x00   ; 0x00   7位地址;
                                ; 0x01   10位地址
    C_E2Addr_RxChannelNums      ==   0x02   ; 接收信道数
    C_E2Addr_TxChannelNums      ==   0x03   ; 发送信道数
    C_E2Addr_SWNums             ==   0x04   ; 设置开关数
    C_E2Addr_MyNode             ==   0x05   ; MyNode
    C_E2Addr_MaxNode            ==   0x06   ; MaxNode

    C_E2Addr_Target             ==   0x08           ; 节点参数 02 05 07 共2节点， 5,7


    C_EpAddr_DefaultChannel     ==   0x10           ; 默认信道
                                ; 0x08   设置使用的收，发信道
                                ; 0x09   数据通道0  地址1
                                ; 0x0A   数据通道0  地址2
                                ; 0x0B   数据通道0  地址3
                                ; 0x0C   数据通道0  地址4
                                ; 0x0D   数据通道0  地址5
                                ; 0x0E   检验和



    C_EpAddr_RxChannel          ==   0x20           ; 接收信道参数
                                ; 0x20    RX addr1
                                ; 0x21    RX addr2
                                ; 0x22    RX addr3
                                ; 0x23    我的节点号
    C_EPAddr_MyNode             ==   0x23
                                ; 0x24  数据通道1  地址4
                                ; 0x25  数据通道1  地址5
                                ; 0x26   检验和

    C_EpAddr_RxPipe2            ==   0x28           ; 接收补充信道
                                ; 0x28  数据通道1  地址5                
                                ; 0x29  数据通道2  地址5 
                                ; 0x2A  数据通道3  地址5 
                                ; 0x2B  数据通道4  地址5 
                                ; 0x2C  数据通道5  地址5 
                                ; 0x2D  数据通道6  地址5 
                                ; 0x2E   

    C_EpAddr_TxChannel          ==  0x30            ; 发送信道 40,50,60,70  共保存5组
                                ; 0x10   正常发射的信道
                                ; 0x11   数据通道0  地址1
                                ; 0x12   数据通道0  地址2
                                ; 0x13   数据通道0  地址3
                                ; 0x14   数据通道0  地址4
                                ; 0x15   数据通道0  地址5
                                ; 0x16   检验和


    C_EpAddr_SWInfo             ==  0x38

    C_MaxTxChannelNum           ==   5 ; 最大发送信道数



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

    C_KeyValueRF    ==      0
    C_KeyValueSW    ==      1
    C_KeyValueRst   ==      3

    C_RFType        ==     01
    C_RFReturn      ==     02
    C_NodeType      ==     03
    C_NodeReturn    ==     04    
    C_SWType        ==     05
    C_SWTypeReturn  ==     06
    C_KeyNodeType   ==     07


    C_MaxChannel    ==     6        ;  TX, RX 相同
    C_MaxCH         ==     125      ; nRF24L01,共125个信道