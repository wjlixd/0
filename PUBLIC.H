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
;    P63 ֻ����Ϊ����ڣ� �ڲ�������������������
;        �����Ʒ����ʱ����Ҫע�⣬P63 �����ⲿ���������µص��裬����˿ڲ��ȶ���Ϊ�����Ļ���
;     
;  EM78911,  EM78P153, EM78P156 
; ����ע�����
; 1����ʹ�ö˿ڣ�
;      a, EM78911, ��ʹ��P60-P67,P54-P57
;         em78p153,      P60-P67,P50-P53
;      b, EM78911, P7������������
;         78P153,156,  P6����������
;      c, EM78911, P60-P67��ͨIO��   
;         em78p153,156, P60�ⲿ�ж�,P63ֻ�������
;      d, EM78911,  P64,P65  ��ͨIO��
;         em78p153,156, P64,P65���������ã���ʹ��IRCʱ��P64,P65��IO��
;      e, EM78911 - �ⲿ�жϿ�  P70,71,72,73
;         em78p153, �ⲿ�жϿ�  P60
;      f, IOCD ,�ڲ�����������ƣ�   ע��2��MCU ��ȫ�෴����
;         em78911,   0 - ��ֹ������ 1- ʹ������
;         em78P153,  0 - ʹ�������� 1- ��ֹ������ 
;
;      g, ����ʱ���轫WDT�رա���������ʱ��WDT�������Ǵ�WDT������WDT��λ
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
	HalfCarryFlag	equ	1			; ���λ��־
	DCFlag		equ	1
	
RamSelReg	equ		0x04	

    ;******************************************************************************
	; TCC ���ù�ʽ:   Tcc=256-Time*Fs/(Rc*2*1000)                                  *
	;   Tcc - Ҫ���õ�TCC��ֵ,  Fs-����Ƶ��,  Time-�ж�ʱ��,��λms, Rc-Const��Ƶ��   *
    ;******************************************************************************
	;        = 256-32*3580000/(256*2*1000)=32.25
	;        = 256-16*3580000/(256*2*1000)=144.125
    ;        = 256-16*3990000/(128*2*1000)=6.625=-242.75=6.625


if  MCU	== EM78911
; EM78911  �ж�ʱ���Ӧ TCC����
;    0x26  --  250us  
;    0x53  --  200us
;    0x82  --  150us
	C_InitTcc2K	 ==  0x26
	C_InitTcc150us==0x82		
	C_TCC10K	==   0xAC;0Xad	
	C_Tcc32ms   ==  32
		;  3.579M , 101us �ж�
		; 9.6K, һ��λ��104.1us
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
; EM78P153  �ж�ʱ���Ӧ TCC����( 3.98M IRC)
;    0x10  --  250us  
;    0x42  --  200us
;    0x75  --  150us

	C_Tcc32ms   ==  6
	C_InitTcc2K	 ==  0x10
	C_InitTcc150us== 0x75			; �ж�ʱ��150us
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






if MCU == EM78911				; ע��EM78911,P7 �� EM78P153, P6����ͬ
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
RA			equ		0x0A		;EM78911 ʹ��
  B_3579E	equ		6
RF			equ		0x0F
IntFlagReg	equ		0x0F
IntFlag		equ		0x0F


;���� IO�����Ĵ���

IOCB		equ  	0x0B
;  153    �������ص�����ƼĴ�����0-ʹ��������1-��ֹ������P66-64,P62-60 	
;  156    ͬ��153
IOCC		equ	 	0x0C
;  153    ©����·���ƣ�0-��ֹ��·��1-ʹ�ܿ�·��P67-64,P62-60
;  156    ͬ��153
;  911  �� OD ����
IOCD		equ	 	0x0D
;  153    ������VCC������ƼĴ�����0-ʹ��������1-��ֹ������P67-64,P62-60 ��P63��RST���ã���������
;  156    ......                   0-ʹ��������1-��ֹ����, P60-P67 ������
;  911	  ......                   0-��ֹ������1-ʹ���ڲ�����
IOCE		equ		0x0E
;153    WDT���ƣ� 
;    B7-WDTE,  0-WDT��ֹ��1-WDTʹ�ܡ�   
;    B6-EIS��0-P60����ͨIO�ڣ�1-P60���ⲿ�жϿڣ�ע�������ǰ���ú�P60������ڣ���
   B_EIS	equ	 6
   B_WDT	equ	 7
IOCF		equ		0x0F


IntMaskReg 	equ 	IOCF	
  TCIF		equ		0				; ��ʱ���ж�
  TccMask	equ		0x01

  ICIF		equ		1				; Port6 ����仯�жϱ�־λ
  ICMask	equ		0x02


if MCU==EM78911
  EXIF			equ		1			;P70�жϣ�����P71,P72,P73��EM78P153������
  ExtIntPort	equ		Port7
  ExtMask		equ		0x02
else  
  EXIF		equ		2			;P60�ж�
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
SysFlag			equ		0x18		;��ʱ���йصı�־
OpMode			equ		0x19

;***************************************************
;  ����ʱ��80ms�����5�Σ��ж�ʱ��16ms
;            1
;    ʱ��=-------s , TCC���� 256����жϣ��ж�ʱ��  
;          16384
;             1             1
;        = ------- *256 = ---- s
;           16384          64
;
;    Inttmp3,ѭ��������76543210
;                      |||____|____6λ�����ƣ�32 
;                      ||__________B6,0.5s ��־λ
;                      |___________B7,  1s ��־λ
;
;****************************************************
;
;CONT ����
;     �жϳ�ʼ����
;ContInit 
;     0b01000011			���жϣ� ָ������TCԴ�� 
;       76543210            ��Ƶ��ΪTCC 16K
;       ||||||_|___��Ƶϵ��
;       ||||+------PAB,��Ƶ������λ��0 - TCC, 
;       ||||                         1 - WDT         
;       |||+-------TE ,����Դ���ⲿ��0 - �͵��ߴ���
;       |||                          1 - �ߵ��ʹ���  
;       ||+--------TCC�ź�Դ��0 - �ڲ�ָ������
;       ||                 1 - 153-�ⲿ�ź�Դ, 911- 16.384K�ź�
;       |+---------�ж�������0 - �жϱ�����
;       |                    1 - �ж�����
;       +----------EM78911:P70�жϴ�������ѡ��  0 - �����ش���
;                               1 - �½��ش���
;                      B7ֻ������EM78911�� EM78P153,P60ֻ���½��ش���
;***************************************************
;  TCC ��Ƶ��
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
