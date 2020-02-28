;****************************************************
;标志位定义
;SystemFlag
    ;SlaverSCL	equ		Bit61
    ;SlaverSDA	equ		Bit62
    ;F_SDAInput  equ     0       ; SDA 输入端口 标志,用于检测START,STOP
    ;F_AddrMarried equ   3
    ; SlaverSCL,SlaverSDA,F_SDAInput,F_AddrMarried 占用0,1,2,3位，在Portdef.h中定义
    
    F_WDevAddr  equ     4       ; 修改 设备地址
    F_I2CRead   equ     5       ; 0 - 写I2C， 1 - 读I2C
	F_DataValid equ     6       ; 正常读写结束STOP
;RelayStatus
	F_RlyOn		equ		0		; 继电器状态
    F_RlyOn1    equ     1
    F_RlyOn2    equ     2
    F_RlyOn3    equ     3


	C_DevBufSize	  ==	2
	C_E2Addr_DevAddr  ==    0	
	
	C_DefaultAddrBits ==    10
	C_MinAddrBits     ==    2
	C_MaxAddrBits     ==    40

;TRFlagReg         
    F_16ms          equ      7      ; 
    F_Config        equ      6      ; 继电器当前状态
    F_I2CSlow       equ      5      ; 1 - 写指令加入等待
    F_QuitTime32ms  equ      4      ; 0 - QuitTime每500ms减1， 1-QuitTime 每32ms减1
    F_500ms         equ      3      ; 1 - 500ms 时间到，
    F_250ms         equ      2      ; 1 - 250ms 时间到
    F_EpTRData      equ      1      ; 0 - 不保存收发数据， 1 - 保存收发数据
    F_FindSame      equ      0

    C_RelayNum      equ      5      ; 5个继电器
;KeyCodeCurrent
    B_Key1          equ      0
    B_Key2          equ      1
    B_Key3          equ      2
    B_Key4          equ      3
    B_Key5          equ      4
