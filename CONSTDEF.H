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
    F_Relay         equ      7      ; 继电器当前状态

    F_QuitTime32ms  equ      4      ; 0 - QuitTime每500ms减1， 1-QuitTime 每32ms减1
    F_500ms         equ      3      ; 1 - 500ms 时间到，
    F_250ms         equ      2      ; 1 - 250ms 时间到

    F_NumsInc       equ      0
    F_FindSame      equ      0
;****************************************************
    C_DevAddrBytes    ==    2

	C_QuitTime		==		30
	C_ChannelSize   ==      4
    C_SWChannelSize ==      2
	C_Time2s        ==      64
	C_StartChannelNumber==  2
	C_MaxChannelNumber   == 125

;*******************************************************
; eprom 地址分配
    C_E2Addr_DevAddr            ==   0x00           ; 基本参数
                                ; 0x00   7位地址
                                ; 0x01   10位地址

    C_E2Addr_Config             ==   0x03

    C_EpAddr_RxChannel          ==   0x20           ; 接收信道参数
                                ; 0x20    RX addr1
                                ; 0x21    RX addr2
                                ; 0x22    RX addr3
    C_E2Addr_MyNode             ==   0x23   ;    我的节点号, 接收信道 CH
    C_E2Addr_RxChannelNums      ==   0x24   ;    接收信道数
    C_E2Addr_TxChannelNums      ==   0x25   ;    发送信道数
    C_E2Addr_SwNodeNums         ==   0x26


    C_EpAddr_TxChannel          ==  0x30   ; 30,40,50,60,70      向下游发送信道
                                ; 0x30   信道码1
                                ; 0x31   信道码2
                                ; 0x32   信道码3
                                ; 0x33   CH
                                ; 0x34   
                                ; 0x35   
                                ; 0x36   

    C_EpAddr_SWNodeKey         ==  0x38

    C_MaxTxChannelNum          ==   10  ; 最大发送信道数
    C_MaxSWNum                 ==   10

;IntKeyValue
;   B_Key           ==      6
	B_KeyDown		==		4			; 按键按下100ms后置1
	B_KeyUp			==		5			; 按键弹起100ms后置1
	B_KeyDown3s		==		7			; 按键按下3秒后置1

    C_KeyFlagMask   ==      (1<<B_KeyDown)  | (1<<B_KeyDown3s)    

    C_RFType        ==     01
    C_RFReturn      ==     02
    C_NodeType      ==     03
    C_NodeReturn    ==     04    
    C_SWType        ==     05
    C_SWTypeReturn  ==     06
    C_KeyNodeType   ==     07

;设置数据类型，由SetMode确定 存储EP地址
    C_ConfigNode    ==     0
    C_ConfigSWInfo  ==     1
    C_ConfigTxCode  ==     2
