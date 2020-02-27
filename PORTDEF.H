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

    F_SDAInput      equ     2         ; 记录SDA端口当前状态，方便比较
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL		equ		Bit61     ; 接I2C主设备 
    ; SlaverSDA		equ		Bit60     ; 接I2C主设备   
    ; SlaverSCL,SlaverSDA,F_SDAInput 占用0,1,2位，在Portdef.h中定义


C_I2CBusOut         equ     0b00001011;     B_SDA,B_SCL为输出时，其它端口的状态
    B_SDA			equ		Bit64     ; 接 24C02接口
    B_SCL			equ     Bit65     ; 接 24C02接口

    P_SDA			equ     Port6     ; 接 24C02接口
    P_SCL			equ     Port6     ; 接 24C02接口

C_SlaverBusOut      equ     0b00111000  ;0b00001011;
;**********************************************************************
    I2CS_Port       equ     Port6
    SlaverSCL		equ		Bit61     ; 接I2C主设备 
    SlaverSDA		equ		Bit60     ; 接I2C主设备   

;*****************************************************************************************
    P_RLY1          equ     Port62
    B_RLY1          equ     Bit62
    P_IN1           equ     Port63
    B_IN1           equ     Bit63

    P_RLY2          equ     Port64
    B_RLY2          equ     Bit64
    P_IN2           equ     Port65
    B_IN2           equ     Bit65

    P_RLY3          equ     Port66
    B_RLY3          equ     Bit66
    P_IN3           equ     Port67
    B_IN3           equ     Bit67

    P_RLY4          equ     Port50
    B_RLY4          equ     Bit50
    P_IN4           equ     Port51
    B_IN4           equ     Bit51

    P_RLY5          equ     Port52
    B_RLY5          equ     Bit52
    P_IN5           equ     Port53
    B_IN5           equ     Bit53

;PCB - 2019.09.13    
    PortPH_Init		equ		(1<<B_IN2) | (1<<B_IN3)|(1<<SlaverSCL)|(1<<SlaverSDA)

    P6_IO_Init		equ		(1<<B_IN1) |(1<<B_IN2) | (1<<B_IN3)|(1<<SlaverSCL)|(1<<SlaverSDA)
    P6_R_Init		equ		0b00000000;
    P5_IO_Init		equ		(1<<B_IN4) | (1<<B_IN5)
    P5_R_Init		equ		0b00000000;