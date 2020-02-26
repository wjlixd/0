PortPH_Init		equ		0b00000011;	           P63无上拉，P64,P65带上拉 上拉电阻,SCL,SDA 带上拉
PortPL_Init     equ     0b00000000;
WDT_P60_Init	equ		0b10000000;            P60 普通IO
CONT_Init		equ		0b01000011;				; PAB=0,选择 系统时钟为TCC信号源，分频比256， 32768/256= 128HZ
;        指令周期  4M/2
;        分频比 000 = 2
;        TCC计数256
;   频率 = 4M/2/2/256= 32hz  中断时间32ms
IntMask			equ		ICMask+TCCMASK;                 ;ICMask;

OpenDrain_Init	equ		0b00000000;             SDA,SCL 为OD输出

P6_IO_Init		equ		0b00001011;             P60 -RX, P61-TX, P66-SDA, P67-SCL
P6_R_Init		equ		0b00000100;
P5_IO_Init		equ		0b00000000;
P5_R_Init		equ		0b00000000;


C_I2CBusOut     equ     0b00001000;
P_SDA			equ     Port6
B_SDA			equ		Bit60
P_SCL			equ     Port6
B_SCL			equ     Bit61

I2CPortMask     equ     (1<<B_SDA) + (1<<B_SCL)

Rx_Port         equ     Port63
Rx_B            equ     Bit63
Tx_Port         equ     Port62
Tx_B            equ     Bit62
