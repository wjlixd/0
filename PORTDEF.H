PortPL_Init     equ     0b00000000;
WDT_P60_Init	equ		0b10000000;
CONT_Init		equ		0b01000111;				; PAB=0,选择 系统时钟为TCC信号源，分频比256， 32768/256= 128HZ
;        指令周期  4M/2
;        分频比 111 = 256
;        TCC计数256
;   频率 = 4M/2/256/256= 32hz  中断时间32ms
IntMask			equ		0             ;禁止中断，TCCMask                 ;ICMask;
OpenDrain_Init	equ		0b00000000    ;             SDA,SCL 为OD输出


;*****************************************************************************************
;PCB - 2019.09.13    
    PortPH_Init		equ		0b00000011;	           P63无上拉，P64,P65带上拉 上拉电阻,SCL,SDA 带上拉

    P6_IO_Init		equ		0b00001011;
    P6_R_Init		equ		0b00000100;
    P5_IO_Init		equ		0b00000000;
    P5_R_Init		equ		0b00000000;

    F_SDAInput      equ     2         ; 记录SDA端口当前状态，方便比较
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL		equ		Bit61     ; 接I2C主设备 
    ; SlaverSDA		equ		Bit60     ; 接I2C主设备   
    ; SlaverSCL,SlaverSDA,F_SDAInput 占用0,1,2位，在Portdef.h中定义

    Tx_Port         equ     Port6
    Tx_B            equ     Bit62    


C_SlaverBusOut      equ     0b00111000  ;0b00001011;
;**********************************************************************
    I2CS_Port       equ     Port6
    SlaverSCL		equ		Bit61     ; 接I2C主设备 
    SlaverSDA		equ		Bit60     ; 接I2C主设备   

