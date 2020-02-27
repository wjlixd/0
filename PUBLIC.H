;                   +-------------+
;              1+---+P50       P51+---+14
;                   |             |
;              2+---+P67       P52+---+13
;                   |             |
;              3+---+P66       P53+---+12
;                   |             |
;              4+---+VDD       VSS+---+11
;                   |             |
;              5+---+OSCI      P60+---+10
;                   |             |
;              6+---+OSCO      P61+---+9
;                   |             |
;              7+---+RST       P62+---+8
;                   +-------------+
;                       EM78P153B
;    P63 只能做为输入口， 内部无上拉，无下拉电阻
;        如果商品唤醒时，需要注意，P63 必须外部接上拉或下地电阻，否则端口不稳定，为连续的唤醒
;     
;  EM78911,  EM78P153, EM78P156 
; 仿真注意事项：
; 1、所使用端口，
;      a, EM78911, 可使用P60-P67,P54-P57
;         em78p153,      P60-P67,P50-P53
;      b, EM78911, P7口有上拉电阻
;         78P153,156,  P6有上拉电阻
;      c, EM78911, P60-P67普通IO口   
;         em78p153,156, P60外部中断,P63只能输入口
;      d, EM78911,  P64,P65  普通IO口
;         em78p153,156, P64,P65与振荡器共用，在使用IRC时，P64,P65做IO口
;      e, EM78911 - 外部中断口  P70,71,72,73
;         em78p153, 外部中断口  P60
;      f, IOCD ,内部上拉电阻控制，   注意2个MCU 完全相反设置
;         em78911,   0 - 禁止上拉， 1- 使能上拉
;         em78P153,  0 - 使能上拉， 1- 禁止上拉， 
;
;      g, 仿真时，需将WDT关闭。正常运行时打开WDT，仿真是打开WDT将产生WDT复位
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


if  MCU	== EM78911
; EM78911  中断时间对应 TCC数据
;    0x26  --  250us  
;    0x53  --  200us
;    0x82  --  150us
	C_InitTcc2K	 ==  0x26
	C_InitTcc150us==0x82		
	C_TCC10K	==   0xAC;0Xad	
	C_Tcc32ms   ==  32
		;  3.579M , 101us 中断
		; 9.6K, 一个位，104.1us
	Port60		equ		0x7
	Port61		equ		0x7
	Port62		equ		0x7
	Port63		equ		0x7
	Port64		equ		0x7
	Port65		equ		0x7
	Port66		equ		0x7
	Port67		equ		0x7

	Port50		equ		0x5
	Port51		equ		0x5
	Port52		equ		0x5
	Port53		equ		0x5
	
	Bit60		equ		0
	Bit61		equ		1
	Bit62		equ		2
	Bit63		equ		3
	Bit64		equ		4
	Bit65		equ		5
	Bit66		equ		6
	Bit67		equ		7

	Bit50		equ		4
	Bit51		equ		5
	Bit52		equ		6
	Bit53		equ		7
endif

if  MCU	== EM78P153
; EM78P153  中断时间对应 TCC数据( 3.98M IRC)
;    0x10  --  250us  
;    0x42  --  200us
;    0x75  --  150us

	C_Tcc32ms   ==  6
	C_InitTcc2K	 ==  0x10
	C_InitTcc150us== 0x75			; 中断时间150us
	Port60		equ		0x6
	Port61		equ		0x6
	Port62		equ		0x6
	Port63		equ		0x6
	Port64		equ		0x6
	Port65		equ		0x6
	Port66		equ		0x6
	Port67		equ		0x6

	Port50		equ		0x5
	Port51		equ		0x5
	Port52		equ		0x5
	Port53		equ		0x5
	
	Bit60		equ		0
	Bit61		equ		1
	Bit62		equ		2
	Bit63		equ		3
	Bit64		equ		4
	Bit65		equ		5
	Bit66		equ		6
	Bit67		equ		7

	Bit50		equ		0
	Bit51		equ		1
	Bit52		equ		2
	Bit53		equ		3
endif
if  MCU	== EM78F734
	Port60		equ		0x6
	Port61		equ		0x6
	Port62		equ		0x6
	Port63		equ		0x6
	Port64		equ		0x7
	Port65		equ		0x7
	Port66		equ		0x7
	Port67		equ		0x7

	Port50		equ		0x5
	Port51		equ		0x5
	Port52		equ		0x5
	Port53		equ		0x5
	
	Bit60		equ		0
	Bit61		equ		1
	Bit62		equ		2
	Bit63		equ		3
	Bit64		equ		0
	Bit65		equ		1
	Bit66		equ		2
	Bit67		equ		3

	Bit50		equ		0
	Bit51		equ		1
	Bit52		equ		2
	Bit53		equ		3
endif






if MCU == EM78911				; 注意EM78911,P7 与 EM78P153, P6口相同
	Port6	equ		0x7
	IOC6	equ		0x7

 	P50		equ	4				; EM78911,  P54 - P57
 	P51		equ	5				; em78p153, P50 - P53
 	P52		equ	6
 	P53		equ	7
else
	Port6	equ		0x6
	IOC6	equ		0x6
	
 	P50		equ	0
 	P51		equ	1
 	P52		equ	2
 	P53		equ	3
endif

Port5		equ		0x05
IOC5		equ		0x05


;Port7		equ		0x07
RA			equ		0x0A		;EM78911 使用
  B_3579E	equ		6
RF			equ		0x0F
IntFlagReg	equ		0x0F
IntFlag		equ		0x0F


;以下 IO操作寄存器

IOCB		equ  	0x0B
;  153    下拉到地电阻控制寄存器，0-使能下拉，1-禁止下拉。P66-64,P62-60 	
;  156    同上153
IOCC		equ	 	0x0C
;  153    漏极开路控制，0-禁止开路，1-使能开路，P67-64,P62-60
;  156    同上153
;  911  无 OD 功能
IOCD		equ	 	0x0D
;  153    上拉到VCC电阻控制寄存器，0-使能上拉，1-禁止上拉。P67-64,P62-60 ，P63与RST共用，不能上拉
;  156    ......                   0-使能上拉，1-禁止上拉, P60-P67 都可以
;  911	  ......                   0-禁止上拉，1-使能内部上拉
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


if MCU==EM78911
  EXIF			equ		1			;P70中断，其它P71,P72,P73，EM78P153不能用
  ExtIntPort	equ		Port7
  ExtMask		equ		0x02
else  
  EXIF		equ		2			;P60中断
  ExtIntPort	equ		Port6
  ExtMask	equ		0x04
endif

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
;       ||||+------PAB,分频器分配位，0 - TCC, 
;       ||||                         1 - WDT         
;       |||+-------TE ,触发源，外部，0 - 低到高触发
;       |||                          1 - 高到低触发  
;       ||+--------TCC信号源，0 - 内部指令周期
;       ||                 1 - 153-外部信号源, 911- 16.384K信号
;       |+---------中断允许。0 - 中断被屏蔽
;       |                    1 - 中断允许
;       +----------EM78911:P70中断触发边沿选择  0 - 上升沿触发
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


	Rom_Reset		equ		0x00

if 	MCU==EM78F734
	ROM_Table		equ		0x32
	Rom_Tcc			equ		0x09
	Rom_Ext			equ		0x03
else
	ROM_Table		equ		0x09
	Rom_Tcc			equ		0x08
	Rom_Ext			equ		0x08
endif

	WDT_Prescaler	equ     00001110b;

