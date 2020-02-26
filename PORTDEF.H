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
;PCB - 2019.05.10 , 
;   与PCB2019.09.13不同之同在于  SlaverSCL, SlaverSDA脚位不同    
if Relay4Board == 5                   ; 使用单继电器模块板， OTP 使用 SOP8, HF49FD小继电器
    PortPH_Init		equ		0b00110000;	           P63无上拉，P64,P65带上拉 上拉电阻,SCL,SDA 带上拉

    P6_IO_Init		equ		0b00111011;
    P6_R_Init		equ		0b00000000;
    P5_IO_Init		equ		0b00000000;
    P5_R_Init		equ		0b00000000;

    F_SDAInput      equ     2         ; 记录SDA端口当前状态，方便比较
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL		equ		Bit61     ; 接I2C主设备 
    ; SlaverSDA		equ		Bit60     ; 接I2C主设备   
    ; SlaverSCL,SlaverSDA,F_SDAInput 占用0,1,2位，在Portdef.h中定义

    Relay1Port      equ     Port6
    Relay_B1        equ     Bit62    

C_I2CBusOut         equ     0b00001011;     B_SDA,B_SCL为输出时，其它端口的状态
    B_SDA			equ		Bit64     ; 接 24C02接口
    B_SCL			equ     Bit65     ; 接 24C02接口

    P_SDA			equ     Port6     ; 接 24C02接口
    P_SCL			equ     Port6     ; 接 24C02接口

C_SlaverBusOut      equ     0b00111000  ;0b00001011;
;**********************************************************************
    I2CS_Port       equ     Port6
    SlaverSCL		equ		Bit60     ; 接I2C主设备 
    SlaverSDA		equ		Bit61     ; 接I2C主设备   

endif

;*****************************************************************************************
;PCB - 2019.09.13    
if Relay4Board == 0                   ; 使用单继电器模块板， OTP 使用 SOP8, HF49FD小继电器
    PortPH_Init		equ		0b00110000;	           P63无上拉，P64,P65带上拉 上拉电阻,SCL,SDA 带上拉

    P6_IO_Init		equ		0b00111011;
    P6_R_Init		equ		0b00000000;
    P5_IO_Init		equ		0b00000000;
    P5_R_Init		equ		0b00000000;

    F_SDAInput      equ     2         ; 记录SDA端口当前状态，方便比较
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL		equ		Bit61     ; 接I2C主设备 
    ; SlaverSDA		equ		Bit60     ; 接I2C主设备   
    ; SlaverSCL,SlaverSDA,F_SDAInput 占用0,1,2位，在Portdef.h中定义

    Relay1Port      equ     Port6
    Relay_B1        equ     Bit62    

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

endif
;*****************************************************************************************
;*****************************************************************************************
if  Relay4Board == 1                  ; 使用4继电器模块板，老版本4继电器，带晶体
    PortPH_Init		equ		0b11000000;	           P63无上拉，P64,P65带上拉 上拉电阻,SCL,SDA 带上拉

    P6_IO_Init		equ		0b11001110;
    P6_R_Init		equ		0b00000000;
    P5_IO_Init		equ		0b00000000;
    P5_R_Init		equ		0b00000000;

    F_SDAInput      equ     0         ;
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL		equ		Bit61
    ; SlaverSDA		equ		Bit62
    ; SlaverSCL,SlaverSDA,F_SDAInput,F_AddrMarried 占用0,1,2,3位，在Portdef.h中定义


    Relay1Port      equ     Port5
    Relay2Port      equ     Port5
    Relay3Port      equ     Port5
    Relay4Port      equ     Port5

    Relay_B1        equ     Bit51
    Relay_B2        equ     Bit52
    Relay_B3        equ     Bit53
    Relay_B4        equ     Bit50
;******************************************************************************
;  定义I2C master接口，使用 24C02
C_I2CBusOut         equ     0b00001110;     B_SDA,B_SCL为输出时，其它端口的状态
    B_SDA			equ		Bit66     ; 接 24C02接口
    B_SCL			equ     Bit67     ; 接 24C02接口

    P_SDA			equ     Port6     ; 接 24C02接口
    P_SCL			equ     Port6     ; 接 24C02接口
;******************************************************************************
;  定义I2C 从设备 Slaver 接口，其它主设备访问端口 ，2个必须在同一个PORT上
C_SlaverBusOut      equ     0b11001000;     SlaverSDA , SlaverSCL 为out状态
    I2CS_Port       equ     Port6
    SlaverSCL		equ		Bit61
    SlaverSDA		equ		Bit62
;******************************************************************************
endif
;*****************************************************************************************
if  Relay4Board == 2                  ; 使用4继电器模块板，HF49FD，带晶体
    PortPH_Init		equ		0b11000000;	           P63无上拉，P64,P65带上拉 上拉电阻,SCL,SDA 带上拉

    P6_IO_Init		equ		0b11001110;
    P6_R_Init		equ		0b00000000;
    P5_IO_Init		equ		0b00000000;
    P5_R_Init		equ		0b00000000;

    F_SDAInput      equ     0         ;
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL		equ		Bit61
    ; SlaverSDA		equ		Bit62
    ; SlaverSCL,SlaverSDA,F_SDAInput,F_AddrMarried 占用0,1,2,3位，在Portdef.h中定义


    Relay1Port      equ     Port5
    Relay2Port      equ     Port5
    Relay3Port      equ     Port5
    Relay4Port      equ     Port6

    Relay_B1        equ     Bit51
    Relay_B2        equ     Bit52
    Relay_B3        equ     Bit53
    Relay_B4        equ     Bit60
;******************************************************************************
;  定义I2C master接口，使用 24C02
C_I2CBusOut         equ     0b00001110;     B_SDA,B_SCL为输出时，其它端口的状态
    B_SDA			equ		Bit66     ; 接 24C02接口
    B_SCL			equ     Bit67     ; 接 24C02接口

    P_SDA			equ     Port6     ; 接 24C02接口
    P_SCL			equ     Port6     ; 接 24C02接口
;******************************************************************************
;  定义I2C 从设备 Slaver 接口，其它主设备访问端口 ，2个必须在同一个PORT上
C_SlaverBusOut      equ     0b11001000;     SlaverSDA , SlaverSCL 为out状态
    I2CS_Port       equ     Port6
    SlaverSCL		equ		Bit61
    SlaverSDA		equ		Bit62
;******************************************************************************


endif
;*****************************************************************************************
if  Relay4Board == 3                  ; 使用单继电器模块板，OTP 使用端口选择，无EPROM,SOP14
    PortPH_Init		equ		0b11110100;	           P63无上拉，P64,P65带上拉 上拉电阻

    P6_IO_Init		equ		0b11111111;
    P6_R_Init		equ		0b00000000;
    P5_IO_Init		equ		0b00000001;
    P5_R_Init		equ		0b00000000;

    F_SDAInput      equ     2         ;
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL		equ		Bit60
    ; SlaverSDA		equ		Bit61
    ; SlaverSCL,SlaverSDA,F_SDAInput 占用0,1,2位，在Portdef.h中定义
  
    Relay1Port       equ    Port5
    Relay_B1         equ    Bit53    

C_SlaverBusOut      equ    0b11111100;
    I2CS_Port       equ     Port6
    SlaverSCL		equ		Bit60
    SlaverSDA		equ		Bit61
endif
;*****************************************************************************************
if  Relay4Board == 4                  ; 使用单继电器模块板，OTP 使用端口选择，无EPROM,SOP8
    PortPH_Init		equ		0b00010100;	           P63无上拉，P64,P65带上拉 上拉电阻

    P6_IO_Init		equ		0b00011111;
    P6_R_Init		equ		0b00000000;
    P5_IO_Init		equ		0b00000000;
    P5_R_Init		equ		0b00000000;

    F_SDAInput      equ     2         ;
    F_AddrMarried   equ     3         ; 10位地址匹配成功
    ; SlaverSCL,SlaverSDA,F_SDAInput 占用0,1,2位，在Portdef.h中定义
    

    Relay1Port      equ     Port6
    Relay_B1        equ     Bit65    

C_SlaverBusOut      equ     0b00011100;
    I2CS_Port       equ     Port6
    SlaverSCL		equ		Bit60
    SlaverSDA		equ		Bit61
endif
;*****************************************************************************************

