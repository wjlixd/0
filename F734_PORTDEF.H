WDT_P60_Init	equ		0b10000000;            P60 普通IO
CONT_Init		equ		0b01001111;	初始化设置 UART ，C_UartCont
;        指令周期  4M/2
;        分频比 111 = 2
;        TCC计数256
;   频率 = 4M/2/256/256= 32hz  中断时间32ms
IntMask			equ		0;
IntMask1		equ		0;    
OpenDrain_Init	equ		0b00000000;             SDA,SCL 为OD输出
P6P5PL_Init     equ     0b00000000;
Port7PL_Init    equ     0b00000000;
;  初始注意：  CSN  - 1, SCK - 0
;*********************************************************
;    RF24L01  管脚排列如下 
;---------------------------------------------------------
;   153 仿真器   ---   RF24L01    
;---------------------------------------------------------
;       P62 ------  8  -- IRQ 
;       P61 ------  7  -- MISO
;       P60 ------  6  -- MOSI
;       P53 ------  5  -- SCK
;       P52 ------  4  -- CSN
;       P51 ------  3  -- CE
;           ------  2  -- VCC
;           ------  1  -- GND
;*********************************************************
P_CE            equ     Port51       ; 输出至RF， RX/TX模式选择
B_CE            equ     Bit51
                                
P_CSN           equ     Port52
B_CSN           equ     Bit52           ; 输出至RF, SPI EN信号
                                
P_SCK           equ     Port53
B_SCK           equ     Bit53           ; 输出至RF, SPI CLK信号
                                
PO_MOSI         equ     Port60
BO_MOSI         equ     Bit60           ; 输出至RF，向24L01输出数据
                                
PI_MISO         equ     Port61
BI_MISO         equ     Bit61           ; 从RF读数据，
                                
P_IRQ           equ     Port62       ; RF数据完成，产生中断
B_IRQ           equ     Bit62           

P_SDA           equ     Port70
B_SDA           equ     Bit70

P_SCL           equ     Port71
B_SCL           equ     Bit71

P_LED           equ     Port73
B_LED           equ     Bit73

P_KEY           equ     Port72
B_KEY           equ     Bit72

P_Relay         equ     Port50
B_Relay         equ     Bit50


	KeyPort         ==      P_KEY
    Key_B           ==      B_KEY		    ; 


;******************************************************
;  Master,  Slaver共用总线
I2CS_Port       equ     P_SDA
SlaverSDA       equ     B_SDA
SlaverSCL       equ     B_SCL

P6_IO_Init		equ     (1<<B_IRQ)|(1<<BI_MISO)
P6_R_Init		equ     0

P7_IO_Init		equ     (1<<B_SCL)|(1<<B_SDA)|(1<<B_KEY)
P7_R_Init		equ     0

Port6PH_Init    equ     (1<<B_IRQ)
Port7PH_Init    equ     (1<<B_SCL)|(1<<B_SDA)|(1<<B_KEY)

C_I2CBusOut     equ     (1<<B_KEY)

P5_IO_Init      equ     0b00000000;
P5_R_Init       equ     0b00000100;
