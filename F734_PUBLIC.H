;*****************************************************************************
;注意事项：   置端口1或0 步骤， 首先设置端口方向，再设置数据，如下
;	MOV     A,@C_I2CBusOut
;	IOW     P_SDA
;	BC      P_SCL,B_SCL
;	BC      P_SDA,B_SDA

;如果先设置数据，再设置方向，有时起不到效果,如下
;	BC      P_SCL,B_SCL
;	BC      P_SDA,B_SDA

;	MOV     A,@C_I2CBusOut
;	IOW     P_SDA
;*****************************************************************************
;   
;                   +-------------------+
;              1+---+P50             P51+---+14
;                   |                   |
;              2+---+P67             P52+---+13
;                   |                   |
;              3+---+P66             P53+---+12
;                   |                   |
;              4+---+VDD             VSS+---+11
;                   |                   |
;              5+---+OSCI/P65        P60+---+10
;                   |                   |
;              6+---+OSCO/P64        P61+---+9
;                   |                   |
;              7+---+RST/P63         P62+---+8
;                   +-------------------+
;                       EM78P153B

; EM78F734
;
R0			equ		0x00
RE			equ		0x0E
TCCounter	equ		0x01
TCC			equ		0x01
PC			equ		0x02
TimeCounter	equ		0x01
StatusReg	equ     0x03
	IOC_PAGE	equ	6
	ZeroFlag	equ	2
	CarryFlag	equ	0	
	PowerFlag	equ	3
	HalfCarryFlag	equ	1			; 半进位标志
	DCFlag		equ	1
	
RamSelReg	equ		0x04	

    ;******************************************************************************
	; TCC 设置公式:   Tcc=256-Time*Fs/(Rc*2*1000)                                  *
	;   Tcc - 要设置的TCC数值,  Fs-振荡器频率,  Time-中断时间,单位ms, Rc-Const分频比   *
    ;******************************************************************************
	;        = 256-32*3580000/(256*2*1000)=32.25
	;        = 256-16*3580000/(256*2*1000)=144.125
    ;        = 256-16*3990000/(128*2*1000)=6.625=-242.75=6.625


	Port7   equ     0x7
	IOC7    equ     0x7

	Port70		equ		7
	Port71		equ		7
	Port72		equ		7
	Port73		equ		7

	Bit70		equ		0
	Bit71		equ		1
	Bit72		equ		2
	Bit73		equ		3

	Port6	equ		0x6
	IOC6	equ		0x6

	Port60      equ     6
	Port61      equ     6
	Port62      equ     6
	Port63      equ     6

	Bit60		equ		0
	Bit61		equ		1
	Bit62		equ		2
	Bit63		equ		3

	Port5		equ		0x05
	IOC5		equ		0x05

	Port50      equ     5
	Port51      equ     5
	Port52      equ     5
	Port53      equ     5

	Bit50		equ		0
	Bit51		equ		1
	Bit52		equ		2
	Bit53		equ		3

RF			equ		0x0F
IntFlagReg	equ		0x0F
IntFlag		equ		0x0F


;以下 IO操作寄存器
IOCA        equ     0x0A

IOCB		equ  	0x0B
;  153    下拉到地电阻控制寄存器，0-使能下拉，1-禁止下拉。P66-64,P62-60 	
IOCC		equ	 	0x0C
;  153    漏极开路控制，0-禁止开路，1-使能开路，P67-64,P62-60
IOCD		equ	 	0x0D
;  153    上拉到VCC电阻控制寄存器，0-使能上拉，1-禁止上拉。P67-64,P62-60 ，P63与RST共用，不能上拉
IOCE		equ		0x0E
;153    WDT控制， 
;    B7-WDTE,  0-WDT禁止，1-WDT使能。   
;    B6-EIS（0-P60做普通IO口，1-P60做外部中断口，注意必须提前设置好P60做输入口），
   B_EIS	equ	 6
   B_WDT	equ	 7
IOCF		equ		0x0F


IntMaskReg 	equ 	IOCF	
  TCIF		equ		0				; 定时器中断
  TccMask	equ		0x01

  ICIF		equ		1				; Port6 输入变化中断标志位
  ICMask	equ		0x02

  EXIF		equ		2			;P60中断
  ExtIntPort	equ		Port6
  ExtMask	equ		0x04


PrgTmp1			equ		0x10
PrgTmp2			equ		0x11
PrgTmp3			equ		0x12
PrgTmp4			equ		0x13
Inttmp1			equ		0x14
Inttmp2			equ		0x15
Inttmp3			equ		0x16
Inttmp4			equ		0x17
SysFlag			equ		0x18		;与时间有关的标志
OpMode			equ		0x19

;***************************************************
;  按键时间80ms，检测5次，中断时间16ms
;            1
;    时钟=-------s , TCC计数 256溢出中断，中断时间  
;          16384
;             1             1
;        = ------- *256 = ---- s
;           16384          64
;
;    Inttmp3,循环计数，76543210
;                      |||____|____6位计数计，32 
;                      ||__________B6,0.5s 标志位
;                      |___________B7,  1s 标志位
;
;****************************************************
;
;CONT 设置
;     中断初始设置
;ContInit 
;     0b01000011			开中断， 指令周期TC源， 
;       76543210            分频器为TCC 16K
;       ||||||_|___分频系数
;       ||||+------PAB,分频器分配位，0 - 禁止预分频，分频=1
;       ||||                       1 - 允许预分频，分频由B0-B2决定         
;       |||+-------TE ,TCC触发源，外部，0 - 低到高触发
;       |||                          1 - 高到低触发  
;       ||+--------TCC信号源，0 - 内部指令周期
;       ||                 1 - 153-外部信号源, F734- P74外部信号
;       |+---------中断允许。0 - 中断被屏蔽
;       |                    1 - 中断允许
;       +----------外部中断引脚P60/INT ,中断触发边沿选择  0 - 上升沿触发
;                               1 - 下降沿触发
;                      B7只适用于EM78911， EM78P153,P60只能下降沿触发
;***************************************************
;  TCC 分频比
;    b2 b1 b0
;    0   0  0    =  1:2
;    0   0  1    =  1:4
;    0   1  0    =  1:8
;    0   1  1    =  1:16
;    1   0  0    =  1:32
;    1   0  1    =    64
;    1   1  0    =   128
;    1   1  1    =   256
;***************************************************


