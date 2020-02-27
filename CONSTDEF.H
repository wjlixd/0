;****************************************************
;标志位定义
;SysFlag
    ;SlaverSCL	equ		Bit61
    ;SlaverSDA	equ		Bit62
    ;F_SDAInput  equ     0       ; SDA 输入端口 标志,用于检测START,STOP
    ;F_AddrMarried equ   3
    ; SlaverSCL,SlaverSDA,F_SDAInput,F_AddrMarried 占用0,1,2,3位，在Portdef.h中定义
    
    F_WDevAddr  equ     4   
	F_DataValid equ     6  
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