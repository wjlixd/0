M_CopyRam macro
;********************************************************
; 复制RAM，从[tmp1] -->到[tmp2] , 共[A]个
; Prgtmp1 - 源地址
; Prgtmp2 - 目标地址
; [A] - 复制个数
; 使用RAM  ,   tmp3,tmp4
CopyRam:
    MOV     Prgtmp3,A

    MOV     A,Prgtmp1
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     Prgtmp4,A

    MOV     A,Prgtmp2
    MOV     RamSelReg,A
    MOV     A,Prgtmp4
    MOV     R0,A

    INC     Prgtmp1
    INC     Prgtmp2
    DJZ     Prgtmp3
    JMP     $-11
    RET
;***************************************** 
endm

M_Hex2DecTable	macro
Hex2DecTable:
	AND		A,@0x0F
	ADD		PC,A
	RETL	@DIG_0
	RETL	@DIG_1
	RETL	@DIG_2
	RETL	@DIG_3
	RETL	@DIG_4
	RETL	@DIG_5
	RETL	@DIG_6
	RETL	@DIG_7
	RETL	@DIG_8
	RETL	@DIG_9
	RETL	@DIG_A
	RETL	@DIG_B
	RETL	@DIG_C
	RETL	@DIG_D
	RETL	@DIG_E
	RETL	@DIG_F
endm

M_DEC_COM12DisplayDig macro
COM12DisplayDig:
	CALL	Hex2Dec
	MOV		Prgtmp1,A
	CALL	Hex2DecTable
	OR		A,@SEG_h
	CALL	WriteCOM2Data
	SWAPA	Prgtmp1
	CALL	Hex2DecTable
	CALL	WriteCOM1Data
	RET

COM34DisplayDig:
	CALL	Hex2Dec
	MOV		Prgtmp1,A
	CALL	Hex2DecTable
	CALL	WriteCOM4Data
	SWAPA	Prgtmp1
	CALL	Hex2DecTable
	OR		A,@SEG_h
	CALL	WriteCOM3Data
	RET
endm

M_HEX_COM12DisplayDig macro
COM12DisplayDig:
	MOV		Prgtmp1,A
	CALL	Hex2DecTable
	OR		A,@SEG_h
	CALL	WriteCOM2Data
	SWAPA	Prgtmp1
	CALL	Hex2DecTable
	CALL	WriteCOM1Data
	RET

COM34DisplayDig:
	MOV		Prgtmp1,A
	CALL	Hex2DecTable
	CALL	WriteCOM4Data
	SWAPA	Prgtmp1
	CALL	Hex2DecTable
	OR		A,@SEG_h
	CALL	WriteCOM3Data
	RET
endm


M_SoundOpticalFunc  macro
;SOFlag
	F_Applause	equ		0
	F_LApplause equ		1

    F_SoDelay   equ     2   ; 开关继电器时声音会响应SO，暂时不检测声音64ms
	F_SOSin		equ		3	; 有效的声光信号输出
	F_SoPast    equ		4	; 
	F_LongTime	equ		5
	F_SOLast	equ		6	; 保存声音最后一次信号, 必须与 SO_B 相同
	F_SoEnd		equ		7



	C_ApplauseTime	==  3			; 96ms
	C_LApplauseTime	==	6			; 32*(6+3)= 280ms
	C_SinEndTime	==	250			; 250*0.15MS= 38MS

SoDelay1s:
	MOV		A,@32
	JMP		$+2
SoDelay:
	MOV		A,@3
SoDelay32ms:
	MOV		Timer32ms,A
	BS		SOFlag,F_SoDelay
	RET

SoDetect:
	JBS		SOFlag,F_SoDelay
	JMP		$+5
	MOV		A,Timer32ms
	JBS		StatusReg,ZeroFlag
	RET
	CLR		SOFlag	

	JBC		SOFlag,F_SoEnd
	RET
	JBS		SOFlag,F_SoSin
	JMP		_SoCheckTime
	BC		SOFlag,F_SoSin

	JBC		SOFlag,F_SoPast
	JMP		$+6

	MOV		A,@~(1<<F_SOLast)			;除 SO_B外其它全清除
	AND		SOFlag,A
	BS		SOFlag,F_SoPast
	MOV		A,@C_ApplauseTime
	MOV		Timer32ms,A

	MOV		A,@C_SinEndTime		;信号结束检测时间
	MOV		Timer150us,A
	RET


_SoCheckTime:
	JBS		SOFlag,F_SoPast
	RET
	MOV		A,Timer150us
	JBS		StatusReg,ZeroFlag
	JMP		_SoCheckLongTime

	MOV		A,Timer32ms
	JBS		StatusReg,ZeroFlag
	BS		SOFlag,F_Applause
	BS		SOFlag,F_SoEnd
	RET

_SoCheckLongTime:
	MOV		A,Timer32ms
	JBS		StatusReg,ZeroFlag
	RET
	JBC		SOFlag,F_LongTime
	JMP		$+5		

	BS		SOFlag,F_LongTime
	MOV		A,@C_LApplauseTime
	MOV		Timer32ms,A
	RET

	BS		SOFlag,F_LApplause
	RET
endm

M_SoundOpticalInt	macro
; 使用 150us 中断，检测信号 0.2ms 低脉冲
	MOV		A,SOPort
	XOR		A,SOFlag
	AND		A,@1<<SO_B
	JBC		StatusReg,ZeroFlag			; SO端口发生变化了
	JMP		_IntSoEnd

	MOV		A,@1<<F_SOLast
	XOR		SOFlag,A
	JBS		SOFlag,F_SOLast
	BS		SOFlag,F_SoSin				; 检测到声光信号

_IntSoEnd:
endm


;	M_Dig2SegTable	;把数字转换为 7段码显示的 SEG码
M_Dig2SegTable  macro
;把数字转换为 7段码显示的 SEG码
Dig2SegTable:
	AND		A,@0x0F
	ADD		PC,A
	RETL	@DIG_0
	RETL	@DIG_1
	RETL	@DIG_2
	RETL	@DIG_3
	RETL	@DIG_4
	RETL	@DIG_5
	RETL	@DIG_6
	RETL	@DIG_7
	RETL	@DIG_8
	RETL	@DIG_9
	RETL	@DIG_A
	RETL	@DIG_B
	RETL	@DIG_C
	RETL	@DIG_D
	RETL	@DIG_E
	RETL	@DIG_F
endm	
;**********************************************************************************
;红外接收模块， 2018年10月21日
;******************************************************
;调试  IR 程序注意事项：
;  1、 要打开定时器中断，外部中断
;  2、 定时器中断时间0.25ms 
;  3、 在0.25ms程序中 加入：  M_IRRcv_TCC
;  4、 在120ms程序中，加入：  M_IRRcv_Timer120ms
;  5、 在变化中断中，  加入：  M_IRRcv_ICF
;  6、 设置 IR 端口：
;        IR_Port	equ		Port66
;        IR_B       equ     Bit60
;  7、 IRFlagReg(SysFlag)中， IR_B位不能被其它标志占用，且记
;  8、 程序复位加入           M_IRRcv_PwrReset  
;******************************************************


;************************************************************************
;   红外线接收程序模块 1 ，  放在端口变化中断中
;    利用红外接收端口产生变化中断，检测数据
;//mark:  M_IRRcv_ICF     红外线接收模块 - 变化中断
M_IRRcv_ICF   macro  

	MOV		A,IR_Port
	XOR		A,IRFlagReg
	AND		A,@1<<IR_B
	MOV		Inttmp3,A							; 获得变化位
	XOR		IRFlagReg,A							; 保存变化值 

	JBS		Inttmp3,IR_B                        ; IR 端口发生变化了
	JMP		IntPortEnd

	MOV		A,DisIRCnt							; IR关闭定时器，接收一次IR后，200MS禁止接收数据
	JBS		StatusReg,ZeroFlag
	JMP		IntPortEnd
	JBC		IRFlagReg,F_IREnd					; DisIRCnt=0,允许接收数据
	JMP		IntPortEnd							; 接收数据结束后，不处理端口

	JBS		IRFlagReg,IR_B
	JMP		IRGetBit

	CLR  	TimeCnt								;    +------+       +------
	BS		IRFlagReg,F_EnCnt					;----+      +-------+
	JMP		IntPortEnd							;    |      | 
                                                ;    |      +---变低时获得高电平宽度
                                                ;    +----------变高时清除计时器
                                                ;  高电平 F_EnCnt=1, 0.25ms中断计时，低电平禁止计时

IRGetBit:
	BC		IRFlagReg,F_EnCnt

	MOV		A,@2
	SUB		A,TimeCnt
	JBS		StatusReg,CarryFlag
	JMP		IntPortEnd

	MOV		A,@5
	SUB		A,TimeCnt
	JBS		StatusReg,CarryFlag
	JMP		IRSaveBit0						;  [2,4]  	-  0

	MOV		A,TimeCnt
	SUB		A,@8
	JBC		StatusReg,CarryFlag
	JMP		IRSaveBit1						;  [5,8]   	-  1

	MOV		A,@38                           ;   38*0.25=9.5ms
	SUB		A,TimeCnt
	JBS		StatusReg,CarryFlag
	JMP		IRStart

	BS		IRFlagReg,F_IREnd				; 	[20..]  -  结束    高电平宽度大于22【22*0.25=5.5ms】，则认为结束
	JMP		IntPortEnd
IRStart:                                    ;   红外起始码 高 9ms, 低4.5ms
	BS		IRFlagReg,F_IRStart				;	[9,37]	-	开始   高电平宽度【2.25ms-9.25ms] - 是开始标志
	JMP		IntPortEnd

IRSaveBit0:
IRSaveBit1:
	MOV		A,DataPtr
	MOV		RamSelReg,A
	RRC		R0

	INC		BitPtr
	MOV		A,BitPtr
	AND		A,@7
	JBC		StatusReg,ZeroFlag
	INC		DataPtr

IntPortEnd:
	MOV		IR_Port,IR_Port
ENDM
;************************************************
;  红外接收定时器中断部分，定时时间 0.25ms（ 250us )
;  
;//mark:  M_IRRcv_TCC     红外线接收模块 - 定时器部分
M_IRRcv_TCC macro
;********定时中断  0.25ms, 4K,用于 红外计时***********
	JBS		IRFlagReg,F_EnCnt               ; 如果允许计时
	JMP		_IRCntEnd

	JBC		TimeCnt,6
	JMP		_IRCntEnd                       ; TimeCnt=100 0000   = 64,计时16ms

	INC  	TimeCnt
	JBS		TimeCnt,6
	JMP		_IRCntEnd
	BS		IRFlagReg,F_IREnd				; [64..]  -  结束  ICF中有9.5ms检测，这里是双重保障
	BC		IRFlagReg,F_EnCnt
_IRCntEnd:	
;************************************************
endm

;  红外接收定时器中断部分，定时时间 0.25ms（ 250us )
M_IRRcv_Timer120ms  macro
	MOV		A,DisIRCnt
	JBS		StatusReg,ZeroFlag
	DEC		DisIRCnt
endm

M_IRRcv_PwrReset  macro    
	MOV		IR_Port,IR_Port
	MOV     A,IR_Port
	AND		A,@1<<IR_B
	MOV		IRFlagReg,A
endm

M_IRRcv_Init  macro
;//mark: M_IRRcv_Init
; mark: IR_Disable  禁止红外接收
;IR_Disable:
;	BC		IRFlagReg,F_EnCnt
;	BS		IRFlagReg,F_IREnd
;	RET

;mark IR_Init     红外接收模块 - 初始化
IR_Init:
	MOV		A,@DataBuf
	MOV		DataPtr,A

	MOV		A,@C_IRBufsize+2
	MOV		PrgTmp1,A
	MOV		A,@BitPtr
	MOV		RamSelReg,A

	CLR		R0
	INC		RamSelReg
	DJZ		PrgTmp1
	JMP		$-3
	BC      IRFlagReg,F_IREnd
	MOV		A,@3                            ; 120ms减1
	MOV		DisIRCnt,A                      ; 初始化开始，300ms不接收数据
	RET

;*******************************************************************
;//mark ChkIRRight
ChkIRRight:
	MOV		A,@16
	SUB		A,BitPtr
	JBS		StatusReg,CarryFlag
	JMP		_BelowMinBit

	MOV		A,@49
	SUB		A,BitPtr
	JBC		StatusReg,CarryFlag
	JMP		_AboveMaxBit

	BC		StatusReg,CarryFlag
	RRCA    BitPtr
	MOV		PrgTmp1,A
	BC		StatusReg,CarryFlag
	RRC    	PrgTmp1
	BC		StatusReg,CarryFlag
	RRCA   	PrgTmp1
	ADD		A,@0
	RET


_AboveMaxBit:
_BelowMinBit:
	CLRA
	RET


endm

M_IRRcv_Table   macro
;//mark: IRDataTable
C_Addr_IROn		==	6*0
C_Addr_IROff	==	6*1
C_Addr_IRLeft	==	6*2
C_Addr_IRRight	==	6*3
_4KeyIROnData:
	ADD		PC,A
	RETL	@0x07
	RETL	@0x07
	RETL	@0x60
	RETL	@~0x60
	RETL	@0
	RETL	@0
_4KeyIROffData:
	RETL	@0x07
	RETL	@0x07
	RETL	@0x01
	RETL	@~0x01
	RETL	@0
	RETL	@0
_4KeyIRLeftData:
	RETL	@0x07
	RETL	@0x07
	RETL	@0x68
	RETL	@~0x68
	RETL	@0
	RETL	@0
_4KeyIRRightData:
	RETL	@0x07
	RETL	@0x07
	RETL	@0x62
	RETL	@~0x62
	RETL	@0
	RETL	@0


;*******************************************************************
;//mark: ChkIRSame
ChkIRSame4KeyData:
    MOV     PrgTmp2,A
	CLR		PrgTmp1
	MOV		A,@DataBuf
	MOV		RamSelReg,A
;_ChkIRSameLoop:
	MOV		A,PrgTmp2
	CALL	_4KeyIROnData
	XOR		A,R0
	JBS		StatusReg,ZeroFlag
	RET

	INC		PrgTmp1
	INC		PrgTmp2
	INC		RamSelReg
	MOV		A,PrgTmp1
	XOR		A,@C_IRBufsize
	JBS		StatusReg,ZeroFlag
	JMP		$-11                        ; _ChkIRSameLoop
	RET

endm

;**********************************************************************************
;红外线接收模块占用7个RAM          程序有问题，不再使用
M_InfraredRay	macro
/*
中断时间 200 -250us 接收参数
C_IR_Sig_Min	==  1
C_IR_0_Min		==  1
C_IR_Sig_Max	==  5
C_IR_0_Max		==  3
C_IR_1_Max		==  8
C_IR_Tag_Max	==  10 
*/
;/*
;中断时间 150us 接收参数
C_IR_Sig_Min	==  2
C_IR_0_Min		==  2
C_IR_Sig_Max	==  5
C_IR_0_Max		==  5
C_IR_1_Max		==  15
C_IR_Tag_Max	==  35 
;*/


IR_Cnt          equ     IR_Ram
IR_BitCnt		equ		IR_Ram	+ 1  ;位计数
IR_Data         equ     IR_Ram	+ 2  ;接收到的数据 
IR_Buf  		equ     IR_Ram	+ 3  ;缓存

;  红外接收部分
	JBC		IRFlagReg,F_IREnd			; 大于等于8，数据结束
	JMP		_IR_End					; 接收结束

    MOV 	A,IR_Port
	XOR		A,IRFlagReg
	AND     A,@1<<IR_B
	JBC		StatusReg,ZeroFlag
	JMP		_IR_StatusSame
;***************** 红外端口状态改变了************
	MOV		A,@1<<IR_B
	XOR		IRFlagReg,A
	
;_IR_StatusChange:
	JBS		IRFlagReg,F_IRStatus
	JMP		_IR_StatusChange1_0


;*************** 上次是低电平，现变为高电平 ******	
_IR_StatusChange0_1:				;从0->1,检测0
	MOV		A,@C_IR_Sig_Min
	SUB		A,IR_Cnt
	JBS		StatusReg,CarryFlag
	JMP		_IR_Disturb

	MOV		A,IR_Cnt
	SUB		A,@C_IR_Sig_Max
	JBS		StatusReg,CarryFlag
	JMP		_IR_Disturb

	BS		IRFlagReg,F_PreData		; 检测到数据前导码，准备接收数据
	JMP		_IR_StatusChangeEnd


;*************** 上次是高电平，现变为低电平 ******	,检测数据是0，还是1
_IR_StatusChange1_0:				; 从1-> 0，检测 1
	JBS		IRFlagReg,F_PreData		; 只有检测到前导，才检测数据
	JMP     _IR_Disturb
	
	MOV		A,@C_IR_0_Min
	SUB		A,IR_Cnt                ;    0    1     3                8          10
	JBS		StatusReg,CarryFlag		;    |____|_____|________________|___________|
	JMP		_IR_Disturb             ;       0min   0max             1max        tag
                                    ;         [  0 ]  （      1     ]                  结束
	MOV		A,IR_Cnt				;         [1,3]     (3,8]            (8,10)      [10..)
	SUB		A,@C_IR_0_Max
	JBC		StatusReg,CarryFlag
	JMP		_IR_Rcv0_Save			; 0 - 小于等于2[1-2]为0

	MOV		A,IR_Cnt
	SUB		A,@C_IR_1_Max
	JBC		StatusReg,CarryFlag
	JMP		_IR_Rcv1_Save			; 1,   3<IR_Cnt<<5

	MOV		A,@C_IR_Tag_Max			; 6- 7 为标识位
	SUB		A,IR_Cnt
	JBC		StatusReg,CarryFlag
	BS		IRFlagReg,F_IREnd			; 大于等于8，数据结束
	JMP		_IR_StatusChangeEnd		; 小于8，标识位不记录


;***********保存数据********************************
_IR_Rcv0_Save:
	BC		StatusReg,CarryFlag
	JMP		$+2
_IR_Rcv1_Save:
	BS		StatusReg,CarryFlag
	RLC     IR_Data
	INC     IR_BitCnt

	MOV     A,IR_BitCnt
	AND     A,@0X07
	JBS     StatusReg,ZeroFlag
	JMP     _IR_NextBit

	SWAPA   IR_BitCnt
	AND     A,@0X0F
	ADD		A,@IR_Buf
	MOV     RamSelReg,A
	
	MOV		A,@IR_Buf+C_IR_Buf_Size  ;  4
	SUB		A,RamSelReg
	JBC		StatusReg,CarryFlag
	JMP		$+3

	MOV     A,IR_Data
	MOV     R0,A

	MOV     A,@0X08
	ADD		IR_BitCnt,A				; B3=0, MSB+1
	JMP		_IR_NextBit

;***********处理变化结束****************************
_IR_Disturb:				; 不是数据，重新进行检测
	CLR		IR_BitCnt    
_IR_NextBit:	
	BC		IRFlagReg,F_PreData
_IR_StatusChangeEnd:	
	CLR		IR_Cnt
	JMP 	_IR_End

;******************端口状态没有改变******************
_IR_StatusSame:
	MOV     A,@C_IR_1_Max+1  
	SUB     A,IR_Cnt
	JBS     StatusReg,CarryFlag		; 大于信号是干扰
	JMP		_IR_NextChk

	SWAPA	IR_BitCnt				; 数据接收中，长时间出现同一高低电平，则接收结束
	AND		A,@0X0f
	SUB		A,@1
	JBS		StatusReg,CarryFlag		;接收到的字节数 <=2  
	BS		IRFlagReg,F_IREnd		; >2  则结束
	JMP     _IR_End
_IR_NextChk:
	INC		IR_Cnt


_IR_End:
endm  

M_Rx433M_Main  macro
;*******************************************************************************
RxEnd:													; ?????,????
	INC		RxMode
	JMP		RxBegin
;*******************************************************************************
RxMode_Chk0:											; ??  10
	JBS		SysFlag,F_SamRdy
	JMP		RxBegin

	RLC		RxData
	BC		RxData,0
	JBC		SysFlag,Rx_LastB
	BS		RxData,0

	BC		SysFlag,F_SamRdy
	
	MOV		A,RxData
	AND		A,@(C_RxBit0+C_RxBit1)
	XOR		A,@C_RxBit0;							 	; ??? ??2?,??  01 ??
	JBS		StatusReg,ZeroFlag
	JMP		RxBegin

	INC		RxMode
	CLR		RxCnt									; ??  10 ????10?,?????
	CLR		RxData
	JMP		RxBegin									;	
;*******************************************************************************
RxMode_Chk0_Continue:
	JBS		SysFlag,F_SamRdy
	JMP		RxBegin

	RLC		RxData
	BC		RxData,0
	JBC		SysFlag,Rx_LastB
	BS		RxData,0

	BC		SysFlag,F_SamRdy
	
	INC     RxCnt
	JBS		RxCnt,1									;  ??2??????
	JMP		RxBegin

	MOV		A,RxData
	XOR		A,@C_RxBit0;							; 01; ??? ??2?,??  01 ??
	JBS		StatusReg,ZeroFlag
	JMP		RepeatRxBegin

	INC		RxMode
	CLR		RxCnt									; ??  10 ????10?,?????
	CLR		RxData
	JMP		RxBegin									;	

RepeatRxBegin:										;
	CLR		RxMode
	JMP		RxBegin
;***********************************************************************************
RxMode_Chk1:
	JBS		SysFlag,F_SamRdy
	JMP		RxBegin

	RLC		RxData
	BC		RxData,0
	JBC		SysFlag,Rx_LastB
	BS		RxData,0

	BC		SysFlag,F_SamRdy
	
	INC     RxCnt
	JBS		RxCnt,1									;  ??2??????
	JMP		RxBegin

	MOV		A,RxData
	XOR		A,@(C_RxBit1+C_RxBit0);					; ??? 11???
	JBC		StatusReg,ZeroFlag
	JMP		RepeatRxBegin

	MOV		A,RxData
	XOR		A,@C_RxBit1								; ??? 1
	JBS		StatusReg,ZeroFlag
	JMP		_RxMode_Chk1Continue

	INC		RxMode
	CLR		DataBitCnt
	CLR		SaveData
	BC		SysFlag,F_SamEnd
	JMP		_SaveRxBit1								;	

_RxMode_Chk1Continue:
_RxMode_NextBit:
	CLR		RxCnt
	CLR		RxData
	JMP		RxBegin
;***********************************************************************************
RxMode_SaveData:
	JBS		SysFlag,F_SamEnd
	JMP		$+3

	INC		RxMode
	JMP		RxBegin

	JBS		SysFlag,F_SamRdy
	JMP		RxBegin

	RLC		RxData
	BC		RxData,0
	JBC		SysFlag,Rx_LastB
	BS		RxData,0

	BC		SysFlag,F_SamRdy
	
	INC     RxCnt
	JBS		RxCnt,1									;  ??2??????
	JMP		RxBegin

	MOV		A,RxData
	JBC		StatusReg,ZeroFlag
	JMP		RxEnd									; ??? 00 ???

	XOR		A,@(C_RxBit1+C_RxBit0);					; ??? 11 ???
	JBC		StatusReg,ZeroFlag
	JMP		RxEnd

	MOV		A,RxData
	XOR		A,@C_RxBit1								; ??? 1
	JBC		StatusReg,ZeroFlag
	JMP		_SaveRxBit1

	BC      StatusReg,CarryFlag						;  ?? 00,11,01???,??10
	JMP		$+2
_SaveRxBit1:
	BS		StatusReg,CarryFlag
	RLC		SaveData
	INC		DataBitCnt

	MOV		A,DataBitCnt
	AND		A,@7
	JBS		StatusReg,ZeroFlag						; 8???????
	JMP		_RxMode_NextBit

	RRCA	DataBitCnt
	MOV		PrgTmp1,A
	RRC		PrgTmp1
	RRC		PrgTmp1

	MOV		A,PrgTmp1
	AND		A,@7
	ADD		A,@DataBuf-1
	MOV		RamSelReg,A
	MOV		A,SaveData
	MOV		R0,A
	JMP		_RxMode_NextBit
;***********************************************************************************
endm

M_Rx433M_Table  macro
Rx433M_Model:											; 接收 433M模块程序，通过调用函数完成
;***********************************************************************************
	MOV		A,RxMode
	ADD		PC,A
	JMP		RxMode_Chk0
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue
	JMP		RxMode_Chk0_Continue						;检测到 10次 10 ，CLK 信号
	JMP		RxMode_Chk1
	JMP		RxMode_SaveData
;	JMP		RxBegin										; 接收结束，等待下次命令
;***********************************************************************************
RxBegin:
	RET
endm
;tx 端信号：     接收端设置  cont = 0b01000010
;---+   +---+    发射端设置  cont = 0b01000100 ,TCC为0
;   |   |   |    一个完整信号波?危?45ms/11=4.09ms
;   +---+   +---
;    接收端中断时间：8ms/7 = 1.14ms
;
;
;
;********************************************
M_Rx433M_Int  macro
	SWAPA	RxPort
	XOR		A,SysFlag
	AND		A,@1<<Rx_LastB
	JBC		StatusReg,ZeroFlag
	JMP		_SamSame
_SamReverse:
;采样与前一个不同
	MOV		A,@1<<Rx_LastB
	XOR		SysFlag,A

	SWAP    CSampleCnt
	MOV		A,@0XF0
	AND		CSampleCnt,A

	JMP		_SamEnd
_SamSame:
;采样与前一个相同
	MOV		A,@9				; 大于2*4 
	SUB		A,CSampleCnt
	JBC		StatusReg,CarryFlag
	JMP		_SamTimeOver						; 采样计数大于8则认为时钟过长，不是时钟，属于干扰信号

	INC     CSampleCnt

	MOV		A,CSampleCnt
	AND		A,@0x0F
	XOR		A,@C_SamCntShort					;2
	JBS		StatusReg,ZeroFlag
	JMP		_SamNextBit

	BS		SysFlag,F_SamRdy
;  clkout 信号用于检测接收到的信号
;	JBS		SysFlag,Rx_LastB
;	BC      ClkOutPort,ClkOut_B
;	JBC		SysFlag,Rx_LastB
;	BS      ClkOutPort,ClkOut_B
	JMP		_SamEnd
_SamNextBit:
	MOV		A,CSampleCnt
	AND		A,@0x0F
	XOR		A,@C_SamCntLong
	JBC		StatusReg,ZeroFlag
	BS		SysFlag,F_SamRdy
	JMP		_SamEnd

_SamTimeOver:
	BS		SysFlag,F_SamEnd
_SamEnd:
endm
;********************************************
; 共用函数文件

M_Hex2Dec   macro
Hex2Dec:
	MOV		PrgTmp1,A		;暂时保存
	CLRA
	ADD		A,@0
	JBC		Prgtmp1,0
	ADD		A,@1
	JBC		Prgtmp1,1
	ADD		A,@2
	JBC		Prgtmp1,2
	ADD		A,@4
	JBC		Prgtmp1,3
	ADD		A,@8
	DAA
	
	JBC		Prgtmp1,4
	ADD		A,@0x16
	DAA
	
	JBC		Prgtmp1,5
	ADD		A,@0x32
	DAA

	JBC		Prgtmp1,6
	ADD		A,@0x64
	DAA
	
	ret
endm

; 倒计时程序，在中断中进行， 1秒中断
;   RunTimeSecond,F_DisCount   = 1 ，  禁止计数
;   在开始计数时，  设置  RunTimeSecond = 60 开数计数
;
CountDownTime		macro
;**************************  1秒 run 计数， 倒计时部分
	JBC		RunTimeSecond,F_DisCount
	JMP		_IntRunEnd

	MOV		A,CountTimeHour
	OR		A,CountTimeMin
	OR		A,CountTimeSec	
	JBC		StatusReg,ZeroFlag
	JMP		_IntRunEnd

	MOV		A,CountTimeSec
	JBS		StatusReg,ZeroFlag
	JMP		_IntRunDecSec

	MOV		A,@60
	MOV		CountTimeSec,A

	MOV		A,CountTimeMin
	JBS		StatusReg,ZeroFlag
	JMP		_IntRunDecMin

	MOV		A,@60
	MOV		CountTimeMin,A

_IntRunDecHour:
	DEC		CountTimeHour
_IntRunDecMin:
	DEC		CountTimeMin
_IntRunDecSec:
	DEC		CountTimeSec
_IntRunEnd:	
endm

;****************************************************
; 双字节减法指令,注意前后顺序
;  WA= WA-WB
;     WA > WB
SUBWord  	macro	WA,WB
	MOV		A,WB
	SUB		WA,A

	MOV		A,WB+1
	SUB		WA+1,A
	JBS		StatusReg,CarryFlag
	DEC		WA
endm



M_FDIV   macro
;*************************************************************************
;  单字节移位除法，商为小数，  0<商<1
;  被除数< 除数
;二、101÷1000001   , 移位除法，
;被除数101 除数1000001
;原理：设被除数为A、除数为B、商为Q（初值为0）
;设置一个Q单元，A由低向高位移位，每次移位进入
;后比较A单元和B的值，如果R≥B，则将这一位的商单元的值置1，然后从A中
;减去B（做补码加法运算），否则不做操作。商单元与移位同步进行。……直
;到A为0。如果移位小于8，继续以0补齐，移位8个结束
;  商为8位二进制   
;                 0b 1111 1111     权值表
;                    |||| ||||__  1/256
;                    |||| |||___  1/128
;                    |||| ||____  1/64
;                    |||| |_____  1/32
;                    ||||_______  1/16
;                    |||________  1/8
;                    ||_________  1/4
;                    |__________  1/2       
;*******************************************************************************
;             101                    ;   被除数    A
;        100 0001                    ;   除数      B
;        00000000                    ;   商        Q
;
;
;            1010    1               ;  第一次A左移，A<B
;          1 0100    2               ;  第二次A左移，A<B
;         10 1000    3               ;  第三次A左移，A<B
;        101 0000    4               ;  第四次A左移，A>B
;            1111                    ; 相减 A=1111           , 商 0000 0001
;          1 1110    5               ;  第五次A左移，A<B      ，商 0000 0010
;         11 1100    6               ;  第六次A左移，A<B      ，商 0000 0100
;        111 1000    7               ;  第七次A左移，A>B      , 商 0000 1000
;         11 0111                    ; 相减结果               , 商 0000 1001
;        110 1110    8               ;  第8次A左移，A>B       , 商 0001 0010
;         10 1101                    ; 相减结果               ，商 0001 0011
;*******************************************************************************
;             101                    ;   被除数    A
;            1010                    ;   除数      B
;        00000000                    ;   商        Q
;
;            1010    1               ;  第一次A左移，A>=B
;            0000                    ; 相减结果为0，则结束， 商为 0000 0001
;
;            移位不够8位，向左移动7个位，以0补齐，结果为 1000 0000
;*******************************************************************************
;除法运算
;   被除数  101    		  0X5    5        ANumerator      TMP1
;   除数    100 0001         0X41  65        BDenominator    TMP2
;   商                        13       Quotient        TMP3,  如果没有整除，余数在 Prgtmp1中
FDIV:
    CLR     Prgtmp3         ;Quotient
    CLR     Prgtmp4
    BS      Prgtmp4,3       ;TMP4=8
_DivLoop:
	BC		StatusReg,CarryFlag
    RLC     Prgtmp3         ;Quotient

    RLC     Prgtmp1         ;ANumerator
    MOV     A,Prgtmp2       ;BDenominator
    SUB     A,Prgtmp1       ;  ANumerator
    JBS     StatusReg,CarryFlag
    JMP     $+3
    MOV     Prgtmp1,A
    BS      Prgtmp3,0       ;;Quotient,0

	JBC		StatusReg,ZeroFlag
	JMP     $+4

	DJZ		Prgtmp4
    JMP     _DivLoop
    RET
    
    
	DEC		Prgtmp4
	BC		StatusReg,CarryFlag
		
    RLC     Prgtmp3         ;Quotient
    DJZ		Prgtmp4
	JMP     $-2
    RET
;******************************************************************
endm

M_FWDIV  macro
;双字节商为浮点数的除法运算
;  RamSelReg  为当前被除数，除数的保存地址
;  Prgtmp1,Prgtmp2保存商结果数据
;   被除数  101    		  0X5    5        ANumerator      TMP1
;   除数    100 0001         0X41  65        BDenominator    TMP2
;   商                        13       Quotient        TMP3,  如果没有整除，余数在 Prgtmp1中
FWDIV:
    CLR     Prgtmp1         ;Quotient
	CLR		Prgtmp2

	MOV		A,R0
	MOV		Prgtmp3,A		;  TMP3:TMP4    ANumerator 被除数

	INC		RamSelReg
	
	MOV		A,R0
	MOV		Prgtmp4,A

	INC		RamSelReg
	
	MOV		A,R0
	MOV		Prgtmp5,A		;  TMP5:TMP6    BDenominator 除数

	INC		RamSelReg
	
	MOV		A,R0
	MOV		Prgtmp6,A

    CLR     Prgtmp7
    BS      Prgtmp7,4       ;TMP7=16
_FwDivLoop:
	BC		StatusReg,CarryFlag
    RLC     Prgtmp2         ;Quotient
	RLC     Prgtmp1

    RLC     Prgtmp4         ;ANumerator
	RLC		Prgtmp3

	MOV		A,Prgtmp5
	SUB		A,Prgtmp3
	JBS		StatusReg,CarryFlag
	JMP		_DWBelow
	JBS		StatusReg,ZeroFlag
	JMP		_DWSUB

	MOV		A,Prgtmp6
	SUB		A,Prgtmp4
	JBS		StatusReg,CarryFlag
	JMP		_DWBelow
_DWSUB:
	MOV		A,Prgtmp6
	SUB		Prgtmp4,A
	JBS		StatusReg,CarryFlag
	DEC		Prgtmp3

	MOV		A,Prgtmp5
	SUB		Prgtmp3,A

    BS      Prgtmp2,0       ;;Quotient,0

_DWBelow:
	MOV		A,Prgtmp3
	OR		A,Prgtmp4
	JBC		StatusReg,ZeroFlag
	JMP     $+4

	DJZ		Prgtmp7
    JMP     _FwDivLoop
    RET
    
    
	DEC		Prgtmp7
	BC		StatusReg,CarryFlag
		
    RLC     Prgtmp2         ;Quotient
	RLC		Prgtmp1
    DJZ		Prgtmp7
	JMP     $-3
    RET
;******************************************************************
endm


M_DivByte  macro
;*************************************************************************
;  单字节移位除法
;
;二、1000001÷101   , 移位除法，
;被除数1000001 除数101
;原理：设被除数为A、除数为B、商为Q（初值为0）、余数为R（初值为0）。
;设置一个Q单元和R单元，A由高位至低位依次左移进入R单元。每次移位进入
;后比较R单元和B的值，如果R≥B，则将这一位的商单元的值置1，然后从R中
;减去B（做补码加法运算），否则不做操作。商单元与移位同步进行。……直
;到A全部进入R单元为止。此时Q中存放商、R中存放余数。
;除法运算
;   被除数  100 0001    0X41  65       ANumerator      TMP1
;   除数    101         0X5   5        BDenominator    TMP2
;   商                        13       Quotient        TMP3
;  余数                       0        Remainder       TMP4
DIV:
    CLR     Prgtmp3         ;Quotient
    CLR     Prgtmp4         ;Remainder
    CLR     Prgtmp5
    BS      Prgtmp5,3       ;TMP4=8
_DivLoop:
    RLC     Prgtmp1         ;ANumerator
    RLC     Prgtmp4         ;Remainder
    MOV     A,Prgtmp2       ;BDenominator
    SUB     A,Prgtmp4       ;Remainder
    JBS     StatusReg,CarryFlag
    JMP     $+4
    MOV     A,Prgtmp2       ;BDenominator
    SUB     Prgtmp4,A       ;Remainder,A
    BS      Prgtmp3,0       ;;Quotient,0

	DJZ		Prgtmp5
	JMP		$+2
	RET
	BC		StatusReg,CarryFlag
    RLC     Prgtmp3         ;Quotient
    JMP     _DivLoop
;******************************************************************
endm



M_MultiByte macro
;****************************************************
; 移位乘法
;一、1101x1011     
;被乘数1101 乘数1011
;   原理：由左向右逐位判断乘数的值，如果值为1，则被乘数加到积单元，
;   之后积单元左移一位；如果值为0，积单元左移一位；
;   ……直到乘数判断完为止。
;  A -  被乘数
;  Prgtmp1 -  乘数
;  积 - Prgtmp2 = [A]
;     单字节乘法子程序， 完成功能，  A = [A]* Tmp1
MultiByte:
	CLR		Prgtmp2
	CLR		Prgtmp3
	BS		Prgtmp3,3				; TMP3=8 ,循环8次

	JBC		Prgtmp1,7
	ADD		Prgtmp2,A
	DJZ		Prgtmp3
	JMP		$+3
	MOV		A,Prgtmp2
	RET

	BC		StatusReg,CarryFlag
	RLC		Prgtmp2
	BC		StatusReg,CarryFlag
	RLC		Prgtmp1
	JMP		$-10
endm


;使用RAM ,常量定义  ,单按键，无键值，只有键状态标志, 单键扫描程序
/*
IntKeyValue     equ     0x1B
	B_KeyDown       equ	7
	B_KeyUp   	    equ	6
    B_KeyDown3s 	equ	4
KeyCounter		equ		0x1A
KeyDownCounter	equ		0x1C

KeyPort		equ	 Port6			; EM78P153B,P6外部中断口
 P_Key1     equ     5
 KeyMask    equ	    1<<P_Key1;P62 key

*/
;***************** 简单按键扫描，一个或2个按键适用
; 早些时间文件，后面长按键3秒后产生按键，有错误，停止使用此程序
M_SingleKeyScan2018			macro
;**********32ms中断，键盘扫描*****************
;  32ms 中断一次，键盘扫描   256/16384= 1/64	
; IntKeyValue    B7 6 5 4 3 2 1 0
;                   |       |____KeyPin
;                   +____________KeyLast
;*******************************************
;**********25ms中断，键盘扫描*****************
;  25ms 中断一次，键盘扫描   256/16384= 1/64	
;*******************************************
;  单按键程序使用 3个RAM 
	IntKeyValue		==		KeyBuf3
	KeyCounter		==		KeyBuf3	+	1
	KeyDownCounter	==		KeyBuf3	+	2

 	KeyMask    		==    	1<<Key_B

	KeyVibrate		==		4
	C_KeyContinueTime==		8			;   每 16*8=108ms产生一个持续按键
	KeyConfirm3s	==		185			;   长按键3秒产生持续按键

	B_KeyDown		==		7
	B_KeyUp			==		6
	B_KeyDown3s		==		5

	MOV		A,IntKeyValue
	XOR		A,KeyPort
	AND		A,@KeyMask
	JBC		StatusReg,ZeroFlag
	JMP		_KeyConfirm

	MOV		A,@KeyMask
	XOR		IntKeyValue,A
    MOV     A,@KeyVibrate
    MOV     KeyCounter,A    
    BC		IntKeyValue,B_KeyDown3s			;按键变化后，清除3秒按键标志
    JMP     _KeyEnd
_KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     _KeyDownCount        	

    DEC     KeyCounter
    JBS     StatusReg,ZeroFlag
    JMP     _KeyEnd

	JBC		IntKeyValue,Key_B
	JMP		_KeyUp

    BS      IntKeyValue,B_KeyDown
	BC		IntKeyValue,B_KeyUp
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A
    JMP     _KeyEnd

_KeyUp:	
    BS      IntKeyValue,B_KeyUp
    BC		IntKeyValue,B_KeyDown3s
    CLR		KeyDownCounter
	JMP		_KeyEnd

_KeyDownCount:
	MOV		A,KeyDownCounter
	JBC		StatusReg,ZeroFlag
	JMP		_KeyEnd
	DEC		KeyDownCounter
	JBS		StatusReg,ZeroFlag
	JMP		_KeyEnd

	BS		IntKeyValue,B_KeyDown3s
	MOV		A,@C_KeyContinueTime
	MOV		KeyDownCounter,A

	JBC		SysFlag,F_ContinueTime
	BS		IntKeyValue,B_KeyDown
_KeyEnd:
endm

M_SingleKeyScan20181125  macro
;**********32ms中断，键盘扫描*****************
;  32ms 中断一次，键盘扫描   256/16384= 1/64
;  支持持续按键，长按3秒后，如果一直按下，将产生持续按键，使用RAM增加了一个	
; IntKeyValue    B7 6 5 4 3 2 1 0
;                   |       |____KeyPin
;                   +____________KeyLast
;*******************************************
;**********25ms中断，键盘扫描*****************
;  25ms 中断一次，键盘扫描   256/16384= 1/64	
;*******************************************
;  单按键程序使用 4个RAM 
	IntKeyValue		==		KeyBuf4
	KeyCounter		==		KeyBuf4	+	1
	KeyDownCounter	==		KeyBuf4	+	2
	KeyContinueCounter==    KeyBuf4	+	3

 	KeyMask    		==    	1<<Key_B

	KeyVibrate		==		4
	C_KeyContinueTime==		3			;   每 16*8=108ms产生一个持续按键
	KeyConfirm3s	==		100			;   长按键3秒产生持续按键

	B_KeyDown		==		7
	B_KeyUp			==		6
	B_KeyDown3s		==		5

	MOV		A,IntKeyValue
	XOR		A,KeyPort
	AND		A,@KeyMask
	JBC		StatusReg,ZeroFlag
	JMP		_KeyConfirm

	MOV		A,@KeyMask
	XOR		IntKeyValue,A
    MOV     A,@KeyVibrate
    MOV     KeyCounter,A    
    BC		IntKeyValue,B_KeyDown3s			;按键变化后，清除3秒按键标志
    JMP     _KeyEnd
_KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     _KeyDownCount        	

    DEC     KeyCounter
    JBS     StatusReg,ZeroFlag
    JMP     _KeyEnd

	JBC		IntKeyValue,Key_B
	JMP		_KeyUp

    BS      IntKeyValue,B_KeyDown
	BC		IntKeyValue,B_KeyUp
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A
    JMP     _KeyEnd

_KeyUp:	
    BS      IntKeyValue,B_KeyUp
    BC		IntKeyValue,B_KeyDown3s
    CLR		KeyDownCounter
	JMP		_KeyEnd

_KeyDownCount:
	MOV		A,KeyDownCounter
	JBC		StatusReg,ZeroFlag
	JMP		_KeyContinue
	DEC		KeyDownCounter
	JBS		StatusReg,ZeroFlag
	JMP		_KeyEnd

	BS		IntKeyValue,B_KeyDown3s
	JMP		_KeyContinueResetTime
_KeyContinue:	
	MOV		A,KeyContinueCounter
	JBS     StatusReg,ZeroFlag
	JMP     _KeyEnd
	
	JBC		SysFlag,F_ContinueTime
	BS		IntKeyValue,B_KeyDown
_KeyContinueResetTime:	
	MOV		A,@C_KeyContinueTime
	MOV		KeyContinueCounter,A	
_KeyEnd:    
endm

;***************** 简单按键扫描，一个或2个按键适用,去消持续按键功能
M_SingleKeyNoCont20190821		macro
;**********32ms中断，键盘扫描*****************
;  32ms 中断一次，键盘扫描   256/16384= 1/64	
; IntKeyValue    B7 6 5 4 3 2 1 0
;                   |       |____KeyPin
;                   +____________KeyLast
;*******************************************
;**********25ms中断，键盘扫描*****************
;  25ms 中断一次，键盘扫描   256/16384= 1/64	
;*******************************************
;  单按键程序使用 3个RAM 
/*
	KeyPort         ==      Port6
    Key_B           ==      3		    ; 

;   Key_B           ==      3		    ; IntKeyValue 此位占用
	B_KeyDown		==		7			; 按键按下100ms后置1
	B_KeyUp			==		6			; 按键弹起100ms后置1
	B_KeyDown3s		==		5			; 按键按下3秒后置1
*/
	KeyVibrate		==		4
	KeyConfirm3s	==		185			;   长按键3秒产生持续按键

	IntKeyValue		==		KeyBuf3
	KeyCounter		==		KeyBuf3	+	1
	KeyDownCounter	==		KeyBuf3	+	2
 	SingleKeyMask 	==    	1<<Key_B

	MOV		A,IntKeyValue
	XOR		A,KeyPort
	AND		A,@SingleKeyMask
	JBC		StatusReg,ZeroFlag
	JMP		_KeyConfirm

	MOV		A,@SingleKeyMask
	XOR		IntKeyValue,A
    MOV     A,@KeyVibrate
    MOV     KeyCounter,A    
    BC		IntKeyValue,B_KeyDown3s			;按键变化后，清除3秒按键标志
    JMP     _KeyEnd
_KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     _KeyDownCount        	

    DEC     KeyCounter
    JBS     StatusReg,ZeroFlag
    JMP     _KeyEnd

	JBC		IntKeyValue,Key_B
	JMP		_KeyUp

    BS      IntKeyValue,B_KeyDown
	BC		IntKeyValue,B_KeyUp
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A
    JMP     _KeyEnd

_KeyUp:	
    BS      IntKeyValue,B_KeyUp
    BC		IntKeyValue,B_KeyDown3s
    CLR		KeyDownCounter
	JMP		_KeyEnd

_KeyDownCount:
	MOV		A,KeyDownCounter
	JBC		StatusReg,ZeroFlag
	JMP		_KeyEnd
	DEC		KeyDownCounter
	JBS		StatusReg,ZeroFlag
	JMP		_KeyEnd

	BS		IntKeyValue,B_KeyDown3s
_KeyEnd:
endm
;******************************************************************************
/*
IntKeyValue		equ		KeyBuf3

; 端口定义
	EC11A_Port	==  Port6
	EC11A_B		==  Bit63

	EC11B_Port	==  Port6
	EC11B_B		==  Bit64

; 使用位定义
 F_EC11TurnLeft ==  2		; 结果输出，按扭左转动，
 F_EC11TurnRight==  1		;  ...........右....      
; F_EC11A_Last	==  EC11A_B		;  EC11B_Last  与 EC11 端口位相同，便于比较
; F_EC11B_Last	==  EC11B_B

*/

EnCoder_EC11	macro

 F_EC11A_Last	==  EC11A_B		;  EC11B_Last  与 EC11 端口位相同，便于比较
 F_EC11B_Last	==  EC11B_B

;  500us 中断检测编码器
	JBC		EC11A_Port,EC11A_B
	JMP		_EC11A_1

	JBS		IntKeyValue,F_EC11A_Last			;
	JMP		_EC11_0
; EC11A 检测到由高变低电平
	BC		IntKeyValue,F_EC11A_Last			;

	BC		IntKeyValue,F_EC11B_Last			;
	JBC		EC11B_Port,EC11B_B
	BS		IntKeyValue,F_EC11B_Last			;			记录 EC11B 当前的状态
	JMP		_EC11End	
_EC11_0:										;     EC11A 低电平，检测 B 是否有状态变化
	MOV		A,EC11B_Port
	XOR		A,IntKeyValue
	AND		A,@1<<EC11B_B						;  EC11B_Last  与 EC11 端口位相同，便于比较
	JBC		StatusReg,ZeroFlag
	JMP		_EC11End							;    B 端口与前一状态相同。不做处理
; EC11 B 端口发生了变化
	MOV		A,@1<<F_EC11B_Last
	XOR		IntKeyValue,A						;    改变B Last 状态
	
	BS      IntKeyValue,F_EC11_TurnFlag			;   EC11 发生了转动，方向由F_EC11B_Last 确定
	JMP		_EC11End
_EC11A_1:						;  A - 1
	BS		IntKeyValue,F_EC11A_Last			;
_EC11End:
endm




DefMCU	macro
	EM78P153	equ		1
	EM78P156	equ		2
	EM78911		equ		3
endm
/*
C_Wait10us	equ		 3
C_Wait13us	equ	     5
C_Wait20us	equ		10
C_Wait40us  equ		20	
C_Wait50us	equ		27
C_Wait100us equ		57
C_Wait200us equ		120
WaitTime:	
	MOV		A,@116
	MOV		Prgtmp4,A
	DJZ		Prgtmp4
	JMP		$-1
	RET		
*/


InitPort20190828	macro
; 增加 EM78F734仿真EM78P153
if MCU == EM78P153
	MOV		A,@~PortPL_Init
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	MOV		A,@OpenDrain_Init
	IOW		IOCC			;     OD开路	

	MOV		A,@~PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A

	MOV		A,@CONT_Init;
	CONTW
  
	MOV		A,@IntMask
	IOW		IOCF
	
    CLRA
    MOV     RF,A
    ENI	
else	
	MOV     A,@~P6P5PL_Init
	IOW     IOCB					; [P6,P5] 下拉到地电阻设置
	BANK    @3
	MOV     A,@~Port7PL_Init
	MOV     RF,A					; [P7 ] P7下拉到地电阻设置

	MOV		A,@OpenDrain_Init
	IOW		IOCC					;     OD开路	

	MOV     A,@~Port6PH_Init
	IOW     IOCD					; P6上拉到VDD电阻
	BANK    @2
	MOV     A,@~Port7PH_Init
	MOV     RF,A					; [P7 ] 上拉到VDD电阻

	MOV		A,@WDT_P60_Init ;
	IOW		IOCA					; 禁止WDT，P60做IO口	

	BANK    @0
	MOV		A,@P7_IO_Init
	IOW		Port7
	MOV		A,@P7_R_Init
	MOV		Port7,A

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A

	MOV		A,@CONT_Init;
	CONTW
  
	MOV		A,@IntMask					; 中断屏蔽 1
	IOW		IOCF
	
	MOV     A,@IntMask1					; 中断屏蔽 2
	IOW     IOCE

	BANK    @1							; 中断标志2
	MOV     A,@0x80
	MOV     0x08,A						; IRC 频率设置为8M,  R8 = 0X80

    CLRA
    MOV     RF,A
	BANK    @0							; 中断标志1
    MOV     RF,A
	
    ENI	
endif

endm


InitPort20181204	macro
;  对 上拉，下地进行修改，  0 -无上拉，下拉，   1-有上拉，下拉
;  结束增加 ENI
;  对RF清除改方法

	MOV		A,@~PortPL_Init
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	MOV		A,@OpenDrain_Init
	IOW		IOCC			;     OD开路	

	MOV		A,@~PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A

	MOV		A,@CONT_Init;
	CONTW
  
	MOV		A,@IntMask
	IOW		IOCF
	
    CLRA
    MOV     RF,A
    ENI	
endm

InitPort20181020	macro
;  对 上拉，下地进行修改，  0 -无上拉，下拉，   1-有上拉，下拉
;  结束增加 ENI
	MOV		A,@~PortPL_Init
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	MOV		A,@OpenDrain_Init
	IOW		IOCC			;     OD开路	

	MOV		A,@~PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A

	MOV		A,@CONT_Init;
	CONTW
  
	MOV		A,@IntMask
	IOW		IOCF
	
	CLR		RF	
    ENI	
endm

InitPort20180706	macro
	MOV		A,@0xFF
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	MOV		A,@OpenDrain_Init
	IOW		IOCC			;     OD开路	

	MOV		A,@PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A

	MOV		A,@CONT_Init;
	CONTW
  
	MOV		A,@IntMask
	IOW		IOCF
	
	CLR		RF
endm



InitPort20170918	macro
;  20170910,对IOCC做了更改
;  911中， R5 LSB 是程序页地址， MSB用做端口
;         IOC5, B0, =0, 设置P5为IO口，否则为LCD端口
;   使用漏极开漏输出，做外IC 电平转换，
;*******************************************
	MOV		A,@0xFF
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	MOV		A,@OpenDrain_Init
	IOW		IOCC			;     OD开路	

  if MCU == EM78911
	MOV		A,@~PortPH_Init	; 911  上拉到VCC电阻控制, 0-禁止，1-使能
  else	
	MOV		A,@PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
  endif	
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

  if  MCU == EM78911
	MOV		A,@P5_IO_Init<<4
	IOW		Port5
	MOV		A,@P5_R_Init<<4
	MOV		Port5,A
  else
	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A
  endif	

	MOV		A,@CONT_Init;
	CONTW
 if (EnWDT) && (WDT_P60_Init&0x80)
	BS		RE,6		;EM911  打开WDT，18ms
 endif
 if En3579 == 1
 	BS		RA,B_3579E
 endif
 
	MOV		A,@IntMask
	IOW		IOCF
	
	CLR		RF		
endm



InitPort20170913	macro
;  20170808,对IOC5做了更改
;  911中， R5 LSB 是程序页地址， MSB用做端口
;         IOC5, B0, =0, 设置P5为IO口，否则为LCD端口
;  cont 修改， B7 =  P60 中断上升，下降选择，  163为下降沿中断，911也设置为下降沿
;*******************************************
	MOV		A,@0xFF
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	CLRA
	IOW		IOCC			;     禁止开路	

  if MCU == EM78911
	MOV		A,@~PortPH_Init	; 911  上拉到VCC电阻控制, 0-禁止，1-使能
  else	
	MOV		A,@PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
  endif	
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

  if  MCU == EM78911
	MOV		A,@P5_IO_Init<<4
	IOW		Port5
	MOV		A,@P5_R_Init<<4
	MOV		Port5,A
	MOV		A,@CONT_Init+0x80;
	CONTW
  else
	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A
	MOV		A,@CONT_Init;
	CONTW
  endif	

 if (EnWDT) && (WDT_P60_Init&0x80)
	BS		RE,6		;EM911  打开WDT，18ms
 endif
 if En3579 == 1
 	BS		RA,B_3579E
 endif
 
	MOV		A,@IntMask
	IOW		IOCF
	
	CLR		RF		
endm

;//mark: InitPort20170808
InitPort20170808	macro
;  20170808,对IOC5做了更改
;  911中， R5 LSB 是程序页地址， MSB用做端口
;         IOC5, B0, =0, 设置P5为IO口，否则为LCD端口
;
;*******************************************
	MOV		A,@0xFF
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	CLRA
	IOW		IOCC			;     禁止开路	

  if MCU == EM78911
	MOV		A,@~PortPH_Init	; 911  上拉到VCC电阻控制, 0-禁止，1-使能
  else	
	MOV		A,@PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
  endif	
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A

  if  MCU == EM78911
	MOV		A,@P5_IO_Init<<4
	IOW		Port5
	MOV		A,@P5_R_Init<<4
	MOV		Port5,A
  else
	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A
  endif	

	MOV		A,@CONT_Init;
	CONTW
 if (EnWDT) && (WDT_P60_Init&0x80)
	BS		RE,6		;EM911  打开WDT，18ms
 endif
 if En3579 == 1
 	BS		RA,B_3579E
 endif
 
	MOV		A,@IntMask
	IOW		IOCF
	
	CLR		RF		
endm


;********************************

InitPort	macro
	MOV		A,@0xFF
	IOW		IOCB			; 153 ,下拉到地电阻禁止
	CLRA
	IOW		IOCC			;     禁止开路	

  if MCU == EM78911
	MOV		A,@~PortPH_Init	; 911  上拉到VCC电阻控制, 0-禁止，1-使能
  else	
	MOV		A,@PortPH_Init	; 153  上拉到VCC电阻控制，0-使能，1-禁止
  endif	
	IOW		IOCD
	
	MOV		A,@WDT_P60_Init ;
	IOW		IOCE			; 禁止WDT，P60做IO口	

	MOV		A,@P6_IO_Init
	IOW		Port6
	MOV		A,@P6_R_Init
	MOV		Port6,A
	
	MOV		A,@P5_IO_Init
	IOW		Port5
	MOV		A,@P5_R_Init
	MOV		Port5,A

	MOV		A,@CONT_Init;
	CONTW
 if (MCU  == EM78911) && (WDT_P60_Init&0x80)
	BS		RE,6		;EM911  打开WDT，18ms
 endif
 if En3579 == 1
 	BS		RA,B_3579E
 endif
 
	MOV		A,@IntMask
	IOW		IOCF
	
	CLR		RF		
endm
;********************************
ClrRam  macro
	MOV		A,@31
	MOV		Prgtmp1,A
	MOV		A,@0x11
	MOV		RamSelReg,A
	
	CLR		R0
	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		$-3
	CLR		RamSelReg
endm 
;********************************
;*** EM78911***************  
;      复位地址 	：	00h
;      软中断地址	：  01h,  由中断指令INT产生
;      硬中断地址	:   08h

;*** EM78P153**************  
;      复位地址 	：	00h
;      软中断地址	：  01h
;      硬中断地址	:   08h
;
;
StartUp	Macro
	ORG		0
	JMP		ResetCode
	
	
	
	ORG		0x08
	JMP		IntCode
endm
;********************************
TST	MACRO	R1,@C
	MOV		A,R1
  if @C==0	
	JBS		StatusReg,ZeroFlag
  else
	JBC		StatusReg,ZeroFlag  
  endif
ENDM
;********************************
COM	MACRO	R1,R2
	MOV		A,R2
	SUB		A,R1
ENDM
COM	MACRO	R1,@R2
	MOV		A,@R2
	SUB		A,R1
ENDM
;********************************
AND	MACRO	@R1,R2
	MOV		A,R2
	AND		A,@R1
ENDM
;********************************
ADD	MACRO	R1,R2
	MOV		A,R2
	ADD		R1,A
ENDM
;********************************


;********************************

MOV	MACRO R1,@R2
	MOV		A,@R2
	MOV		R1,A
ENDM

MOV	MACRO	R1,R2
	MOV		A,R2
	MOV		R1,A
ENDM
;********************************

IOW	MACRO	R1,@R2
	MOV		A,@R2
	IOW		R1
ENDM	

BCTCIF  Macro
	MOV     A,RF
	AND     A,@~(1<<TCIF)
	MOV     RF,A
endm

;********************************
PUSH	Macro
;    DISI                        ; 必须要关中断，防止牵套
    MOV     Inttmp1,A
    SWAP    Inttmp1             ;
    SWAPA   StatusReg           ;
    MOV     Inttmp2,A           ;  
endm
POP		Macro
    SWAPA   Inttmp2
    MOV     StatusReg,A
    SWAPA   Inttmp1
;    ENI						;  reti 指令已经包含 ENI ，无需这条指令
endm
;********************************

PushStack	Macro				;
    MOV     Inttmp1,A
    SWAP    Inttmp1             ;
    SWAPA   StatusReg           ;
    MOV     Inttmp2,A           ;  
    MOV     A,RamSelReg
    MOV     Inttmp4,A
endm

PopStack	Macro
    MOV     A,Inttmp4
    MOV     RamSelReg,A
    SWAPA   Inttmp2
    MOV     StatusReg,A
    SWAPA   Inttmp1
;    ENI						;  reti 指令已经包含 ENI ，无需这条指令
endm

ModeKeyRam		macro
	KeyLast	  	equ		KeyRamBegin
	KeyCounter	equ		KeyRamBegin+1
	IntKeyValue	equ		KeyRamBegin+2
		KeyDownFlag == 7
		KeyUpFlag	== 6
	KeyDown3sFlag	== 5
KeyDownCounter	equ		KeyRamBegin+3
	KeyConfirm3s	== 180
	KeyVibrate		== 4

endm


ModKeyScan		Macro
;**********16ms*****************
_ScanKey:   
    MOV     A,KeyPort
    AND     A,@KeyMask
    MOV     Inttmp3,A          
    XOR     A,KeyLast   
    JBC     StatusReg,ZeroFlag
    JMP     _KeyConfirm
    
    MOV     A,Inttmp3    ; 按键变化了         
    MOV     KeyLast,A
    MOV     A,@KeyVibrate
    MOV     KeyCounter,A    
    BC		IntKeyValue,KeyDown3sFlag	;按键变化后，清除3秒按键标志
    JMP     _KeyEnd
_KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     _KeyDownCount        	

    DEC     KeyCounter
    JBS     StatusReg,ZeroFlag
    JMP     _KeyEnd

    MOV     A,Inttmp3
    XOR     A,@KeyMask
    JBC     StatusReg,ZeroFlag
    JMP     _KeyUp
    
    MOV     A,Inttmp3
    JBS		IntKeyValue,KeyDown3sFlag	;如果持续按键，则只设置按键标志，不清除按键值
    MOV     IntKeyValue,A
    BS      IntKeyValue,KeyDownFlag
	BC		IntKeyValue,KeyUpFlag
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A
    JMP     _KeyEnd

_KeyUp:
    BS      IntKeyValue,KeyUpFlag 
    BC		IntKeyValue,KeyDown3sFlag
    CLR		KeyDownCounter
	JMP		_KeyEnd
_KeyDownCount:
	MOV		A,KeyDownCounter
	JBC		StatusReg,ZeroFlag
	JMP		_KeyEnd
	DEC		KeyDownCounter
	JBC		StatusReg,ZeroFlag
	BS		IntKeyValue,KeyDown3sFlag	
;*********************************************
_KeyEnd:
endm
;*******************************************
;
ModPreKeyValue	Macro
	JBS		IntKeyValue,KeyDownFlag
	RET

	CLR		KeyValue
	JBC		IntKeyValue,KeyUpFlag		;
	JMP		_TranKeyScanCodeToKeyValue	;按键弹起后转换键值
	
	JBS		IntKeyValue,KeyDown3sFlag
	RET

	JBS		FlagReg,F_KeyDown3s
	JMP		_PreProcessKeyValue_LongPress	; 	F_KeyDown3s=0 ,当长按键处理

	JBC		IntKeyValue,B_K1			;  持续键， 修改键持续按
	RET
	MOV		A,KeyCounter
	JBS		StatusReg,ZeroFlag
	RET
	MOV		A,@5						; 每5*32ms 产生一个按键
	MOV		KeyCounter,A
	JMP		_TranKeyScanCodeToKeyValue
		
_PreProcessKeyValue_LongPress:
	BS		KeyValue,1
;***********************
_TranKeyScanCodeToKeyValue:
	JBS		IntKeyValue,B_K1
	BC		KeyValue,0
	
	JBS		IntKeyValue,B_K2
	BS		KeyValue,0

	BS     	KeyValue,KeyDownFlag
	BC		IntKeyValue,KeyDownFlag
endm
;*********************************************************************
;  EPROM 程序模块，注意以下模块，速度比较慢，写页时间大约 50ms, 快速EPROM 请使用 E2 模块
ModI2C	macro

	I2CSDAMask	equ 1<<I2C_SDA
	I2CWriteCmd	equ	0xA0		;选择EPROM 地址0，对EPROM写操作
	I2CReadCmd	equ	0xA1
;*******************************************************
;                                  
;                                                
;                                                   
;                                               
;                                                   
;i2c 程序
;***********************************************************
I2C_Start:
	BS		I2CPort,I2C_SDA
	BS		I2CPort,I2C_SCL			; SCL =1时， SDA 由1->0 
	BC		I2CPort,I2C_SDA
	BC		I2CPort,I2C_SCL
	RET

;    SCL 从0-1，产生时钟 ，=1时读ACK
;         _____________
;  ______|
;
;   SDA      XXXXX 读ACK
;	


;*************************************************************
; I2C_SentAck:		; 收到EPROM 8位数据，给予应答
	; BC		I2CPort,I2C_SDA
	; NOP
	; BC		I2CPort,I2C_SCL
	; NOP
	; BS		I2CPort,I2C_SCL
	
	; RET
	
; WaitNOPS:
	; NOP
	; NOP
	; NOP
	; NOP
	; RET
	
;*************************************************************
;           ___     ____
;SCL:   ___|   |___|
;
;SDA:   -xx------xx---
;
;
;
;  A= 数据,  使用 tmp3,tmp4
;
I2C_Sent8Bit:
	MOV		Prgtmp3,A
	
	MOV		A,@8
	MOV		Prgtmp4,A
;loop：	
	BC		I2CPort,I2C_SCL			;SCL=0,释放SCL总线,让SDA变化
	; CALL	WaitNOPS
	BC		I2CPort,I2C_SDA
	RLC		PrgTmp3
	JBC		StatusReg,CarryFlag
	BS		I2CPort,I2C_SDA	
	; CALL	WaitNOPS
	BS		I2CPort,I2C_SCL
	
	DJZ		Prgtmp4
	JMP		$-7
;***
	;SDA  设为输出口

	BC		I2CPort,I2C_SCL
	; CALL	WaitNOPS
	BS		I2CPort,I2C_SCL

	IOR		I2CPort
	OR		A,@I2CSDAMask
	IOW		I2CPort					;SDA  设为输出口
	
	JBC		I2CPort,I2C_SDA
	JMP		I2CError
	BC		I2CPort,I2C_SCL
	BC		I2CPort,I2C_SDA
	
	IOR		I2CPort
	AND		A,@~I2CSDAMask
	IOW		I2CPort					;SDA  设为输出口
	BS		StatusReg,CarryFlag
	RET
;*****************************************************************
;读8位数， SDA输入，SCL,由低，变高后，读一位，
;连续读8位。结束SCL=0,释放SCL总线,让SDA变化
I2C_Read8Bit:
	IOR		I2CPort
	OR		A,@I2CSDAMask
	IOW		I2CPort					;SDA  设为输入口

	CLR		PrgTmp3
	MOV		A,@8
	MOV		Prgtmp4,A

	BC		I2CPort,I2C_SCL
;LOOP:	
	BS		I2CPort,I2C_SCL			;准备接收数据

	BC		StatusReg,CarryFlag
	JBC		I2CPort,I2C_SDA
	BS		StatusReg,CarryFlag
	RLC		PrgTmp3
	BC		I2CPort,I2C_SCL

	DJZ		PrgTmp4
	JMP		$-7
	
	IOR		I2CPort
	AND		A,@~I2CSDAMASK
	IOW		I2CPort
	
	BC		I2CPort,I2C_SDA
	
	MOV		A,PrgTmp3
	RET
;**********************************************************
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
I2C_WritePage:
	MOV		A,@8
	MOV		Prgtmp4,A				;发送位数
	
	CALL	I2C_Start
	
	MOV		A,@I2CWriteCmd
	CALL	I2C_Sent8Bit
	JBS		StatusReg,CarryFlag
	JMP		I2CError
	
	MOV		A,Prgtmp2
	CALL	I2C_Sent8Bit
	JBS		StatusReg,CarryFlag
	JMP		I2CError
	
	MOV		A,R0
	CALL	I2C_Sent8Bit
	JBS		StatusReg,CarryFlag
	JMP		I2CError

	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		$-6
	
;***********************************************************	
I2C_Stop:
	BC		I2CPort,I2C_SDA
	BS		I2CPort,I2C_SCL			; SCL =1时， SDA 由0->1 
	BS		I2CPort,I2C_SDA	
	BC		I2CPort,I2C_SCL
;***********************************************************
I2CError:	
	RET
;***********************************************************
;   RamSelReg, 当前读的数据存放位置
;   Prgtmp1,读的字节数
;   Prgtmp2,  EPROM 地址，单字节	
I2C_ReadPage:
	MOV		A,@8
	MOV		Prgtmp4,A				;发送位数

	CALL	I2C_Start				;    Start
		
	MOV		A,@0xA0			;    0xA0
	CALL	I2C_Sent8Bit
	JBS		StatusReg,CarryFlag
	JMP		I2CError
	
	MOV		A,PrgTmp2				;    写eprom 地址
	CALL	I2C_Sent8Bit
	JBS		StatusReg,CarryFlag
	JMP		I2CError
	
	CALL	I2C_Start				;    Start
	
	MOV		A,@0xA1			;    0xA1		准备读
	CALL	I2C_Sent8Bit
	JBS		StatusReg,CarryFlag
	JMP		I2CError
;loop:	
	BC		I2CPort,I2C_SDA
	CALL	I2C_Read8Bit			;    读第N个数
	MOV		R0,A					;        *PTR= data
	INC		RamSelReg

	DJZ		PrgTmp1
	JMP		$+2
	
	JMP		I2C_STOP
; 读下个数据
	BC		I2CPort,I2C_SDA
	BS		I2CPort,I2C_SCL
	BC		I2CPort,I2C_SCL
	JMP		$-10
	
endm

;**************************************
; 以下使用 HT1621B LCD 驱动模块
modTm162B	macro

	
;***********************************************	
;  A  -  显示指令，  09 打开音频， 08-关闭音频
; TM1621B ,音频控制
ToneOnOff:
    BC      LcdPort,LCD_CS      ; 开始控制芯片

    BS      LcdPort,LCD_DATA
    CALL    Wave
    BC      LcdPort,LCD_DATA
    CALL    Wave
    BC      LcdPort,LCD_DATA
    CALL    Wave

;	MOV		A,@0x09			; 打开音频
	CALL    Tran_inst	
    BS      LcdPort,LCD_CS      ; 结束控制
	RET
;***********************************************	
;LCD模块显示
Initial:
    BC      LcdPort,LCD_CS      ; 开始k
    
    BS      LcdPort,LCD_DATA
    CALL    Wave
    BC      LcdPort,LCD_DATA
    CALL    Wave
    BC      LcdPort,LCD_DATA
    CALL    Wave
        
    MOV     A,@0x00			; 00关闭系统
    CALL    Tran_inst
    MOV     A,@0x18			; 18选择内部RC256K振荡器
    CALL    Tran_inst
    MOV     A,@0X03			; 03 打开偏压发生器
    CALL    Tran_inst
    MOV     A,@0X29			; 29 设置4COM,1/3偏压
    CALL    Tran_inst
    MOV     A,@0X01			; 01 打开系统振荡器
    CALL    Tran_inst
	MOV		A,@0x60			; 音频2k
	CALL    Tran_inst			
    BS      LcdPort,LCD_CS          ; 写命令结束 
    RET     ;

Wave:
    BC      LcdPort,LCD_WR
;    NOP
    BS      LcdPort,LCD_WR
;    NOP
    BC      LcdPort,LCD_WR
;    NOP
    RET     

Tran_inst:
    MOV     Prgtmp1,A
    MOV     A,@8
    MOV     Prgtmp2,A
    
;Loop:
    JBS     Prgtmp1,7
    BC      LcdPort,LCD_DATA
    JBC     Prgtmp1,7
    BS      LcdPort,LCD_DATA        
    CALL    Wave
    RLC     Prgtmp1
    DJZ     Prgtmp2
    JMP     $-7
    
    BC      LcdPort,LCD_DATA
    CALL    Wave
    RET
;***********************************
;   tmp1 - 6位地址
;   tmp2 - 数据个数， 8位数据，
;   R4 - 数据起始地址
Tran_data:
    BC      LcdPort,LCD_CS      ; 开始k
    
    BS      LcdPort,LCD_DATA
    CALL    Wave
    BC      LcdPort,LCD_DATA
    CALL    Wave
    BS      LcdPort,LCD_DATA
    CALL    Wave

    MOV     A,@6
    MOV     Prgtmp4,A           ;6位地址
;loop1:
    JBC     Prgtmp1,5
    BS      LcdPort,LCD_DATA
    JBS     Prgtmp1,5
    BC      LcdPort,LCD_DATA
    CALL    Wave
    RLC     Prgtmp1
    DJZ     Prgtmp4
    JMP     $-7

;       
    MOV     A,R0
    MOV     Prgtmp1,A   
    INC     RamSelReg
    
    MOV     A,@8
    MOV     Prgtmp4,A           ;6位地址
;loop2:
    JBC     Prgtmp1,7
    BS      LcdPort,LCD_DATA
    JBS     Prgtmp1,7
    BC      LcdPort,LCD_DATA
    CALL    Wave
    RLC     Prgtmp1
    DJZ     Prgtmp4
    JMP     $-7
    
    NOP
    DJZ     Prgtmp2
    JMP     $-15


    BS      LcdPort,LCD_CS
    RET
endm

TestPort	macro
;********************************
TestModeEnter:
	CLRA
	IOW		Port5
	IOW		Port6
	
_TestLoop:	
	WDTC
	JBS		LcdFlag,F_500ms
	JMP		_TestLoop
	BC		LcdFlag,F_500ms

	MOV		A,@0B11111111
	MOV		PrgTmp1,A
	MOV		A,@8
	MOV		PrgTmp2,A	

	MOV		A,PrgTmp1
	MOV		Port6,A
	MOV		Port5,A
	BC		StatusReg,CarryFlag
	RLC		PrgTmp1
	CLR		Port6
	CLR		Port5
	DJZ		PrgTmp2
	JMP		$-8
	JMP		_TestLoop	
endm
;*******************************************************

;*************************************************	
Mod_Eprom	macro

if  Enack
_ACKError:			; 只用于出现问题时进行调试
	NOP
	NOP
	RET

;*************************************************	
;          __    ____
;   SCL      |__|
;         ____        _____ 
;   SDA   ____ I--R-O _____
E2GetAck:
	BC		P_SCL,B_SCL
	
	IOR		P_SDA
	OR		A,@1<<B_SDA
	IOW		P_SDA				;SDA 输入

	BS		P_SCL,B_SCL
	
	BC		StatusReg,CarryFlag
	JBS		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	
	BC		P_SCL,B_SCL

	AND		A,@~(1<<B_SDA)
	IOW		P_SDA				; SDA 恢复输出

	BC		P_SDA,B_SDA			;SDA 在ACK后为低，方便 STOP信号
	RET
endif	

;*************************************************	
; 命令字放在A中  , EPROM 传输一个命令字
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
E2WriteCommand:
	MOV		Prgtmp3,A
	MOV		A,@8
	MOV		Prgtmp4,A
_E2WriteCommandLoop:
	BC		P_SCL,B_SCL	;
	BC		P_SDA,B_SDA
	JBC		Prgtmp3,7
	BS		P_SDA,B_SDA	;
	BS		P_SCL,B_SCL	; Tlow=3*0.6=1.8us
	RLC		Prgtmp3
	DJZ		Prgtmp4
	JMP		_E2WriteCommandLoop; Thigh=4*0.6=2.4us
	RET
;*************************************************	
if  !E2_PageOp
;*************************************************	
; tmp1- 要写的数据,  指定地址写一个数据，比较少使用，大多为页写，节省时间
; tmp2- EPROM地址
E2WriteData:
	ME2_START
		
	MOV		A,@0xA0			; 0xA0写命令,0xA1读命令
	CALL	E2WriteCommand
	ME2_ACK

    MOV		A,Prgtmp2
    CALL	E2WriteCommand
	ME2_ACK


    MOV		A,Prgtmp1
    CALL	E2WriteCommand
	ME2_ACK

	ME2_STOP	
	RET	
endif
;*********************************
; RamSelReg,  写数据地址
; tmp1- 要写的数据个数
; tmp2- EPROM地址	
E2_WritePageData:
	ME2_START
		
	MOV		A,@0xA0			; 0xA0写命令,0xA1读命令
	CALL	E2WriteCommand
	ME2_ACK

    MOV		A,Prgtmp2
    CALL	E2WriteCommand
	ME2_ACK

_E2WritePageLoop:
	MOV		A,R0
	CALL	E2WriteCommand
	ME2_ACK

	INC     RamSelReg
	DJZ		Prgtmp1
	JMP		_E2WritePageLoop
	ME2_STOP

	RET	
endm	

M_TM1650_Eprom	macro
;以下是定义部分



; eprom 部分已经调试通过， TM1650, eprom 共用总线
	F_Tm1650Read	== 7								; 区分是EPROM，还是 TM1650


DIG_0	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_g)
DIG_1	equ	 (SEG_a+SEG_b)
DIG_2	equ	 (SEG_b+SEG_c+SEG_e+SEG_f+SEG_g)
DIG_3	equ	 (SEG_a+SEG_b+SEG_c+SEG_f+SEG_g)
DIG_4	equ	 (SEG_a+SEG_b+SEG_d+SEG_f)
DIG_5	equ	 (SEG_a+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_6	equ	 (SEG_a+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_7	equ	 (SEG_a+SEG_b+SEG_c)
DIG_9	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_8	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)

DIG_G	equ	 SEG_f
DIG_A	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f)
DIG_B	equ	 (SEG_a+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_H	equ	 (SEG_a+SEG_b+SEG_d+SEG_e+SEG_f)
DIG_H1	equ	 (SEG_a+SEG_d+SEG_e+SEG_f)
DIG_COLON equ (SEG_b+SEG_c)
DIG_E	equ	 (SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_N   equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e)
DIG_C   equ	 (SEG_e+SEG_f+SEG_g)
DIG_D   equ	 (SEG_a+SEG_b+SEG_e+SEG_f+SEG_g)
DIG_F	equ	 (SEG_c+SEG_d+SEG_e+SEG_f)
DIG_I   equ  (SEG_a+SEG_b)
DIG_L   equ  (SEG_d+SEG_e+SEG_g)
DIG_O	equ  (SEG_a+SEG_e+SEG_f+SEG_g)

;以下是程序
Wait3us:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	RET


TM1650_OFF:
	CALL	E2Start
	
	MOV		A,@0x48
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,@0x20						; 01 开显示， 00，关闭显示
	JMP		_Tm1650OnOffCom
;TM1650 打开关闭显示
TM1650_ON:
	CALL	E2Start
	
	MOV		A,@0x48
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	DefaultContrast				;读取默认亮度，
	MOV		Prgtmp3,A
	SWAPA	Prgtmp3						;放在 MSB，交换
	OR		A,@0X01						; 开显示   ;	MOV		A,@0x21						; 01 开显示， 00，关闭显示
_Tm1650OnOffCom:
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	E2Stop
	RET

;*******************************************************************************************
;     显示数据， A中
;   WriteComData    使用RAM  , Prgtmp2,tmp3,tmp4
TM1650_WriteCom1:
WriteCOM1Data:
	MOV		Prgtmp2,A
	CALL	E2Start
	MOV		A,@C_TM1650_COM1
	JMP		_Tm1650WriteCom
TM1650_WriteCom2:
WriteCOM2Data:
	MOV		Prgtmp2,A
	CALL	E2Start
	MOV		A,@C_TM1650_COM2
	JMP		_Tm1650WriteCom
TM1650_WriteCom3:
WriteCOM3Data:
	MOV		Prgtmp2,A
	CALL	E2Start
	MOV		A,@C_TM1650_COM3
	JMP		_Tm1650WriteCom
TM1650_WriteCom4:
WriteCOM4Data:
	MOV		Prgtmp2,A
	CALL	E2Start
	MOV		A,@C_TM1650_COM4
	JMP		_Tm1650WriteCom
;*******************************************************************************************
;	  显存地址 ，0,1,2,3  放在 E2Addr中
;     显示数据， Prgtmp2中
;
TM1650_WriteRam:
	
	CALL	E2Start
	
	BC		StatusReg,CarryFlag
	RLCA	E2_Addr
	AND		A,@0x06 				;对E2Addr 纠错 
	OR		A,@0x68					;写显存地址 ，68,6A,6C,6E 四个地址 ，对应COM1,COM2,COM3,COM4
_Tm1650WriteCom:	
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	E2Stop
	RET	
;*****************************************
;  读到的键值在 Prgtmp3中
;
TM1650_ReadKey:
	CALL	E2Start

	MOV		A,@0x49
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck
	
	CALL	E2ReadByte
	CALL	E2SendAck
	CALL	E2Stop
	RET


;*************************************************	
; 命令字放在A中  , EPROM 传输一个命令字
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
E2WriteCommand:
	BC		P_SCL,B_SCL	;
	CALL	Wait3us

	MOV		Prgtmp3,A
	MOV		A,@8
	MOV		Prgtmp4,A
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA

_E2WriteCommandLoop:
	BC		P_SCL,B_SCL	;
	CALL	Wait3us

	BC		P_SDA,B_SDA
	JBC		Prgtmp3,7
	BS		P_SDA,B_SDA	;

	BS		P_SCL,B_SCL	; Tlow=3*0.6=1.8us

	CALL	Wait3us
	RLC		Prgtmp3
	DJZ		Prgtmp4
	JMP		_E2WriteCommandLoop; Thigh=4*0.6=2.4us
	BC		P_SCL,B_SCL	;
	RET
;*****************************************************************************************
E2Start:
	BC		P_SCL,B_SCL		;控制总线
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
	BS		P_SDA,B_SDA		; SDA 由高变低为开始
	CALL	Wait3us
	BS		P_SCL,B_SCL		;
	CALL	Wait3us				; 起始建立时间>0.6us
	BC		P_SDA,B_SDA		;
	ret
_E2ErrorNoAck:              ;  ack 出错处理    
	MOV		A,@0xEF
	ret
;*****************************************************************************************
E2SendNoAckStop:            ;  发送完成 NOACK 接着发送 STOP 指令
    BC  	P_SCL , B_SCL 
	CALL	Wait3us

	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BS  	P_SDA , B_SDA 
    BS  	P_SCL , B_SCL 
	CALL	Wait3us
;*****************************************************************************************
E2Stop:
    BC  	P_SCL , B_SCL 

	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BC  	P_SDA , B_SDA 

    BS  	P_SCL , B_SCL 
	CALL	Wait3us
    BS  	P_SDA , B_SDA 
	ret
;*************************************************	
E2SendAck:
    BC  	P_SCL , B_SCL 
	CALL	Wait3us

	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BC  	P_SDA , B_SDA 
    BS  	P_SCL , B_SCL 
	ret
;*************************************************	
E2GetAck:
    BC  	P_SCL , B_SCL 
	CALL	Wait3us

	IOR		P_SDA
	OR		A,@1<<B_SDA
	IOW		P_SDA
    BS  	P_SCL , B_SCL 
	BC		StatusReg,CarryFlag
	JBS		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RET		

;******************************************************
;读一个字节,  
E2ReadByte:					; 退出时， SCL = 0
	CLR   	Prgtmp3
	MOV		A,@8
	MOV		Prgtmp4,A


_E2_ReadByteLoop:				; 循环中，SCL 周期 = 11 ， 约 11*0.56= 6.2us = 160K 速度
	BC		P_SCL,B_SCL

	JBS		Prgtmp4,3
	JMP		$+4
	IOR  	P_SDA
	OR  	A,@1<<B_SDA
	IOW		P_SDA

	CALL	Wait3us

	BS		P_SCL,B_SCL

	BC		StatusReg,CarryFlag
	JBC		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RLC		Prgtmp3

	CALL	Wait3us				; 此处， SCL 由 0 -> 1 ，需要等待 7 个指令周期以上，时间少于7个周期，会出错

					; 此处， SCL 由 0 -> 1 ，需要等待 7 个指令周期以上，时间少于7个周期，会出错
	DJZ		Prgtmp4
	JMP		_E2_ReadByteLoop

	MOV		A,Prgtmp3			; 读出的数据放在A中	
	RET

;       TM1650 暂且不用，这部分EPROM 有用

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
I2ClockWritePageData:
	CALL	E2Start
	MOV		A,@0xB0				; 写I2CClock 设备地址
	JMP		$+3

E2WritePageData:

	CALL	E2Start
	MOV		A,@0xA0				; 写EPROM 设备地址
	CALL	E2WriteCommand		; 设备地址,使用tmp3,tmp4
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

_E2WritePageLoop:
	MOV		A,R0
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		_E2WritePageLoop	

	CALL	E2Stop
	RET
;**************************************************
;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
I2ClockReadPageData:
	CALL	E2Start
	MOV		A,@0xB0				; eprom 读设备地址
	CALL	E2WriteCommand		; 设备地址
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	E2Start
	MOV		A,@0xB1
	JMP		_I2ClockReadIn
E2ReadPageData:
	CALL	E2Start
	MOV		A,@0xA0				; eprom 读设备地址
	CALL	E2WriteCommand		; 设备地址
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	E2Start
	MOV		A,@0xA1
_I2ClockReadIn:	
	CALL	E2WriteCommand		; 设备地址
	CALL	E2GetAck
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	BC		PrgTmp2,F_Tm1650Read		; 设置为EPROM读方式
_E2ReadPageLoop:
	CALL	E2ReadByte
	MOV		R0,A
	INC		RamSelReg


	DEC		Prgtmp1
	JBC		StatusReg,ZeroFlag
	JMP		$+3

	CALL	E2SendAck
	JMP		_E2ReadPageLoop

	CALL	E2SendNoAckStop
	RET


endm


M_TM1650KeyScan2018  macro
; 按键部分
;
; IntKeyValue    B7 6 5 4 3 2 1 0
;                 | | | | |     |
;                 | | | | +--------->  KeyValue
;                 | | | | 
;                 | | | +----------->  F_ContinueTime
;                 | | +------------->  KeyDown3sFlag
;                 | +--------------->  KeyUpFlag
;                 +----------------->  KeyDownFlag
 KeyDownFlag	==	7
 KeyUpFlag		==	6
 KeyDown3sFlag	==	5
 F_ContinueTime	==  4			;产生持续按键

 KeyValueMask == 0x0F

 KeyVibrate		==  2
 KeyConfirm3s	==	100
 C_KeyContinueTime   == 8			; 长按键，每隔 4*25ms 产生一个 B_KeyDown.


;  读键扫描码保存在TMP3中，通过查表获得键值， 键值在tmp2中
;  确认键完成，将键值TMP2中保存在 IntKeyValue中。
;  键标志用4个位，其它4个位保存键值 ，最大支持15个按键
;   ScanKeyCode 第一个为键个数。  后面为键扫描码，在TM1650资料中
;  此表格放在ROM开始位置
;ScanKeyCode:
;	ADD		PC,A
;	RETL	@8				;8个键值
;	RETL	@SEG6_COM1		;CLOCK   
;	RETL	@SEG4_COM3		;WEEK    
;	RETL	@SEG7_COM1		;MODE     
;	RETL	@SEG5_COM3		;SET    
;	RETL	@SEG6_COM3		; HOUR     
;	RETL	@SEG7_COM3		; MIN     
;	RETL	@SEG4_COM1		; CLR     
;	RETL	@SEG5_COM1		; RESET    
;//mark Tm1650KeyScan						; 2018.05.06修改，增加键码表，增加长按键一直加
Tm1650KeyScan:
	JBS		SysFlag,F_25ms
	RET

	BC		SysFlag,F_25ms
	CALL	TM1650_ReadKey				;  键值在Prgtmp3中
	CLRA
	CALL	ScanKeyCode					;  获得键值个数
	MOV		Prgtmp2,A					;

	MOV		A,Prgtmp2
	CALL	ScanKeyCode					;  获得 KEY8 扫描码
	XOR		A,Prgtmp3
	JBC		StatusReg,ZeroFlag
	JMP		_Tm1650GetCode
	DJZ		Prgtmp2
	JMP		$-6
_Tm1650GetCode:
	MOV		A,Prgtmp2		;扫描码
    XOR     A,KeyLast
    JBC     StatusReg,ZeroFlag
    JMP     _Tm1628KeyConfirm

    MOV     A,Prgtmp2    ; 按键变化了
    MOV     KeyLast,A
    MOV     A,@KeyVibrate
    MOV     KeyCounter,A

	BC		IntKeyValue,KeyDown3sFlag

    JMP     __Tm1628KeyEnd
_Tm1628KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     __Tm1628KeyDownCount

    DEC     KeyCounter
    JBS     StatusReg,ZeroFlag
    JMP     __Tm1628KeyEnd

    MOV     A,Prgtmp2
    JBC     StatusReg,ZeroFlag
    JMP     __Tm1628KeyUp

;************************************* 保存键值*************
	MOV		A,@~KeyValueMask
	AND		IntKeyValue,A
	MOV		A,Prgtmp2
	OR		IntKeyValue,A
;**********************************************************
    BS      IntKeyValue,KeyDownFlag
	BC		IntKeyValue,KeyUpFlag
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A
    JMP     __Tm1628KeyEnd

__Tm1628KeyUp:
    BS      IntKeyValue,KeyUpFlag
    CLR		KeyDownCounter
	JMP		__Tm1628KeyEnd
__Tm1628KeyDownCount:
	MOV		A,KeyDownCounter
	JBC		StatusReg,ZeroFlag
	JMP		__Tm1628KeyEnd
	DEC		KeyDownCounter
	JBS		StatusReg,ZeroFlag
	JMP		__Tm1628KeyEnd

	BS		IntKeyValue,KeyDown3sFlag
	JBS		IntKeyValue,F_ContinueTime
	JMP		__Tm1628KeyEnd

	BS		IntKeyValue,KeyDownFlag
	MOV		A,@C_KeyContinueTime
	MOV		KeyDownCounter,A
;*********************************************
__Tm1628KeyEnd:
	RET
endm



M_TM1650_KeyScan macro
Tm1650KeyScan:	
	JBS		SysFlag,F_32ms
	RET
	
	BC		SysFlag,F_32ms
	CALL	TM1650_ReadKey				;  键值在Prgtmp3中
	MOV		A,Prgtmp3
    AND     A,@0x40
	MOV		Prgtmp2,A					;按下键扫描码
	
_Tm1650GetCode:	
	MOV		A,Prgtmp2		;扫描码
    XOR     A,KeyLast   
    JBC     StatusReg,ZeroFlag
    JMP     _Tm1628KeyConfirm
    
    MOV     A,Prgtmp2    ; 按键变化了         
    MOV     KeyLast,A
    MOV     A,@KeyVibrate
    MOV     KeyCounter,A    
	
	BC		IntKeyValue,KeyDown3sFlag
	
    JMP     __Tm1628KeyEnd
_Tm1628KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     __Tm1628KeyDownCount        	

    DEC     KeyCounter
    JBS     StatusReg,ZeroFlag
    JMP     __Tm1628KeyEnd

    MOV     A,Prgtmp2
    JBC     StatusReg,ZeroFlag
    JMP     __Tm1628KeyUp

;*************************************  转换键值*************    
; EC11 不使用键值，ABK 用标志记录
;**********************************************************
    BS      IntKeyValue,KeyDownFlag
	BC		IntKeyValue,KeyUpFlag
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A
    JMP     __Tm1628KeyEnd

__Tm1628KeyUp:
    BS      IntKeyValue,KeyUpFlag 
    CLR		KeyDownCounter
	JMP		__Tm1628KeyEnd
__Tm1628KeyDownCount:
	MOV		A,KeyDownCounter
	JBC		StatusReg,ZeroFlag
	JMP		__Tm1628KeyEnd
	DEC		KeyDownCounter
	JBC		StatusReg,ZeroFlag
	BS		IntKeyValue,KeyDown3sFlag	
;*********************************************
__Tm1628KeyEnd:	
	RET
endm

;//mark:   M_TM1650_Eprom_I2CClock

M_TM1650_Eprom_I2CClock		macro
; 2018.09.15 更新，TM1650, EPROM, I2CCLOCK 共用程序,I2C增加倒计时功能，增加4M系统时钟选项


C_I2CCLKAddr_TimeYear			equ		0        ;  时间    年
C_I2CCLKAddr_TimeMonth			equ		1        ;  时间    月
C_I2CCLKAddr_TimeDay			equ		2        ;  时间    日 
C_I2CCLKAddr_TimeHour			equ		3        ;  时间    时 
C_I2CCLKAddr_TimeMin			equ		4        ;  时间    分 
C_I2CCLKAddr_TimeSec			equ		5        ;  时间    秒 

C_I2CCLKAddr_CntDownTimes		equ     6        ;  倒计时 次数
C_I2CCLKAddr_CntDownHour		equ		7        ;  倒计时 小时
C_I2CCLKAddr_CntDownMin			equ		8        ;  倒计时 分
C_I2CCLKAddr_CntDownSec			equ		9        ;  倒计时 秒
C_I2CCLKAddr_CntDownFlag		equ		10       ;  倒计时 标志

;CntDownFlag	
   F_CntEnable	equ		7
   F_CntStart	equ		6
   F_CntEnd		equ		5

C_I2CCLKAddr_CntDownBakHour		equ		11       ;  倒计时 小时-备份
C_I2CCLKAddr_CntDownBakMin		equ		12       ;  倒计时 分  -备份
C_I2CCLKAddr_CntDownBakSec		equ		13       ;  倒计时 秒  -备份

DIG_0	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_g)
DIG_1	equ	 (SEG_a+SEG_b)
DIG_2	equ	 (SEG_b+SEG_c+SEG_e+SEG_f+SEG_g)
DIG_3	equ	 (SEG_a+SEG_b+SEG_c+SEG_f+SEG_g)
DIG_4	equ	 (SEG_a+SEG_b+SEG_d+SEG_f)
DIG_5	equ	 (SEG_a+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_6	equ	 (SEG_a+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_7	equ	 (SEG_a+SEG_b+SEG_c)
DIG_9	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_8	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)

DIG_G	equ	 SEG_f
DIG_A	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f)
DIG_B	equ	 (SEG_a+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_H	equ	 (SEG_a+SEG_b+SEG_d+SEG_e+SEG_f)
DIG_H1	equ	 (SEG_a+SEG_d+SEG_e+SEG_f)
DIG_COLON equ (SEG_b+SEG_c)
DIG_E	equ	 (SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_N   equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e)
DIG_C   equ	 (SEG_e+SEG_f+SEG_g)
DIG_D   equ	 (SEG_a+SEG_b+SEG_e+SEG_f+SEG_g)
DIG_F	equ	 (SEG_c+SEG_d+SEG_e+SEG_f)
DIG_I   equ  (SEG_a+SEG_b)
DIG_L   equ  (SEG_d+SEG_e+SEG_g)
DIG_O	equ  (SEG_a+SEG_e+SEG_f+SEG_g)
;SysFlag, F_SlaverSlow
;      F_SlaverSlow = 0 , 从设备速度快，等待长时间短    ，  适用TM1650, EPROM 24C02,速度快
;      F_SlaverSlow = 1 , 从设备速度慢，需要等待长时间长，   适用I2C时钟使用32K晶体，速度慢
;以下是程序
Wait3us:
 if SysClk4M								; 系统时钟选项，有32768HZ, 4M不同，等待时间不同

	MOV		A,@1
	JBC		SysFlag,F_SlaverSlow
	MOV		A,@250

	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

	ADD		A,@0xFF
	JBS     StatusReg,ZeroFlag
	JMP		$-28
  else
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
  endif	
	RET


TM1650_Ctrl:
	CALL	E2Start_2018
	
	MOV		A,@0x48
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

    MOV     A,RelayStatus
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	JMP		E2Stop_2018					;优化代码    

/*
TM1650_OFF:
	CALL	E2Start_2018
	
	MOV		A,@0x48
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,@0x20						; 01 开显示， 00，关闭显示
	JMP		_Tm1650OnOffCom
;TM1650 打开关闭显示
TM1650_ON:
	CALL	E2Start_2018
	
	MOV		A,@0x48
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	DefaultContrast				;读取默认亮度，
	MOV		Prgtmp3,A
	SWAPA	Prgtmp3						;放在 MSB，交换
	OR		A,@0X01						; 开显示   ;	MOV		A,@0x21						; 01 开显示， 00，关闭显示
_Tm1650OnOffCom:
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	JMP		E2Stop_2018					;优化代码
;	CALL	E2Stop_2018
;	RET

*/
;*******************************************************************************************
;     显示数据， A中
;   WriteComData    使用RAM  , Prgtmp2,tmp3,tmp4
TM1650_WriteCom1:
WriteCOM1Data:
	MOV		Prgtmp2,A
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM1
	JMP		_Tm1650WriteCom
TM1650_WriteCom2:
WriteCOM2Data:
	MOV		Prgtmp2,A
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM2
	JMP		_Tm1650WriteCom
TM1650_WriteCom3:
WriteCOM3Data:
	MOV		Prgtmp2,A
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM3
	JMP		_Tm1650WriteCom
TM1650_WriteCom4:
WriteCOM4Data:
	MOV		Prgtmp2,A
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM4
	JMP		_Tm1650WriteCom
;*******************************************************************************************
;	  显存地址 ，0,1,2,3  放在 E2Addr中
;     显示数据， Prgtmp2中
;    TM1650_WriteRam 其它程序不使用，删除处理
;TM1650_WriteRam:
;	
;	CALL	E2Start_2018
;	
;	BC		StatusReg,CarryFlag
;	RLCA	E2_Addr
;	AND		A,@0x06 				;对E2Addr 纠错 
;	OR		A,@0x68					;写显存地址 ，68,6A,6C,6E 四个地址 ，对应COM1,COM2,COM3,COM4
_Tm1650WriteCom:	
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	JMP		E2Stop_2018				; 优化代码
;	CALL	E2Stop_2018
;	RET	
;*****************************************
;  读到的键值在 Prgtmp3中
;
TM1650_ReadKey:
	CALL	E2Start_2018

	MOV		A,@0x49
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck
	
	CALL	E2ReadByte_2018
	CALL	E2SendAck_2018
	JMP		E2Stop_2018				; 优化代码
;	CALL	E2Stop_2018
;	RET


_E2ErrorNoAck:
	MOV		A,@0xEF
	RET


;**************************修改代码**2018.07.12*******************************
; 开始前， SCL,SDA 总线释放状态
;//mark:   E2Start_2018
E2Start_2018:
	BC		P_SCL,B_SCL		; 告知从设备

	BS		P_SDA,B_SDA		; SDA 由高变低为开始
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
	CALL	Wait3us
	BS		P_SCL,B_SCL

	CALL	Wait3us
	BC		P_SDA,B_SDA		;

	JMP		Wait3us			; 优化代码
;	CALL	Wait3us
;	ret
	

;*************************************************
;//mark:  E2SendAck_2018
E2SendAck_2018:
    BC  	P_SCL , B_SCL 
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BC  	P_SDA , B_SDA 

	CALL	Wait3us

    BS  	P_SCL , B_SCL 
	JMP		Wait3us				; 优化代码
;	CALL	Wait3us
;	ret

;*************************************************	
; 命令字放在A中  , EPROM 传输一个命令字
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
;//mark:  E2WriteCommand_2018
E2WriteCommand_2018:
	BC		P_SCL,B_SCL	;
	MOV		Prgtmp3,A			; 保存数据

	MOV		A,@8
	MOV		Prgtmp4,A
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA

;_E2WriteCommandLoop:
	BC		P_SCL,B_SCL	;
	CALL	Wait3us

	BC		P_SDA,B_SDA
	JBC		Prgtmp3,7
	BS		P_SDA,B_SDA	;

	BS		P_SCL,B_SCL	; Tlow=3*0.6=1.8us
	CALL	Wait3us

	RLC		Prgtmp3
	DJZ		Prgtmp4
	JMP		$-9			;_E2WriteCommandLoop; Thigh=4*0.6=2.4us

	RET	
	
;//mark: E2GetAck_2018
E2GetAck_2018:
    BC  	P_SCL , B_SCL 
	IOR		P_SDA
	OR		A,@1<<B_SDA
	IOW		P_SDA

	CALL	Wait3us

    BS  	P_SCL , B_SCL 
	CALL	Wait3us

	BC		StatusReg,CarryFlag
	JBS		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RET		

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//mark:    E2ReadPageData
E2ReadPageData:
if EepromOpt==0
	RET
endif

	CALL	E2Start_2018
	MOV		A,@0xA0
	JBC		SysFlag,F_SlaverSlow
	MOV		A,@0xB0					; eprom 读设备地址

	CALL	E2WriteCommand_2018		; 设备地址
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	E2Start_2018
	MOV		A,@0xA1
	JBC		SysFlag,F_SlaverSlow
	MOV		A,@0xB1					; eprom 读设备地址
	CALL	E2WriteCommand_2018		; 设备地址
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck
	JMP		$+2

_E2ReadPageLoop:
	CALL	E2SendAck_2018
	CALL	E2ReadByte_2018
	MOV		R0,A
	INC		RamSelReg

	DJZ		Prgtmp1
	JMP		_E2ReadPageLoop
;	JMP		E2SendNoAckStop_2018
;*************************************************
;//mark:  E2SendNoAckStop_2018
E2SendNoAckStop_2018:            ;  发送完成 NOACK 接着发送 STOP 指令
    BC  	P_SCL , B_SCL 
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BS  	P_SDA , B_SDA 

	CALL	Wait3us

    BS  	P_SCL , B_SCL 
	CALL	Wait3us

;//mark:   E2Stop_2018
E2Stop_2018:
	BC		P_SCL,B_SCL	;

	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BC  	P_SDA , B_SDA 
	CALL	Wait3us

	BS		P_SCL,B_SCL	;
	
	CALL	Wait3us
    BS  	P_SDA , B_SDA 

	ret


;******************************************************
;读一个字节,  
;//mark:  E2ReadByte_2018
E2ReadByte_2018:					; 退出时， SCL = 0
	CLR   	Prgtmp3
	MOV		A,@8
	MOV		Prgtmp4,A
_E2_ReadByteLoop2018:				; 循环中，SCL 周期 = 11 ， 约 11*0.56= 6.2us = 160K 速度
	BC		P_SCL,B_SCL

	JBS		Prgtmp4,3
	JMP		$+4
	IOR  	P_SDA
	OR  	A,@1<<B_SDA
	IOW		P_SDA

	CALL	Wait3us

	BS		P_SCL,B_SCL

	BC		StatusReg,CarryFlag
	JBC		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RLC		Prgtmp3

	CALL	Wait3us				; 此处， SCL 由 0 -> 1 ，需要等待 7 个指令周期以上，时间少于7个周期，会出错

					; 此处， SCL 由 0 -> 1 ，需要等待 7 个指令周期以上，时间少于7个周期，会出错
	DJZ		Prgtmp4
	JMP		_E2_ReadByteLoop2018

	MOV		A,Prgtmp3			; 读出的数据放在A中	
	RET



;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//mark:  E2WritePageData
E2WritePageData:
if EepromOpt==0
	RET
endif
	CALL	E2Start_2018
	MOV		A,@0xA0				; 写EPROM 设备地址
	JBC		SysFlag,F_SlaverSlow
	MOV		A,@0xB0				; 写EPROM 设备地址

	CALL	E2WriteCommand_2018		; 设备地址,使用tmp3,tmp4
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

_E2WritePageLoop:
	MOV		A,R0
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		_E2WritePageLoop	

	JMP		E2Stop_2018				; 优化代码
;	CALL	E2Stop_2018
;	RET
	
endm

M_TM1650_Eprom_32k  macro
;//TODO: M_TM1650_Eprom_32k
; 2018.10.30 更新，为32K晶体使用，减化代码


C_I2CCLKAddr_TimeYear			equ		0        ;  时间    年
C_I2CCLKAddr_TimeMonth			equ		1        ;  时间    月
C_I2CCLKAddr_TimeDay			equ		2        ;  时间    日 
C_I2CCLKAddr_TimeHour			equ		3        ;  时间    时 
C_I2CCLKAddr_TimeMin			equ		4        ;  时间    分 
C_I2CCLKAddr_TimeSec			equ		5        ;  时间    秒 

C_I2CCLKAddr_CntDownTimes		equ     6        ;  倒计时 次数
C_I2CCLKAddr_CntDownHour		equ		7        ;  倒计时 小时
C_I2CCLKAddr_CntDownMin			equ		8        ;  倒计时 分
C_I2CCLKAddr_CntDownSec			equ		9        ;  倒计时 秒
C_I2CCLKAddr_CntDownFlag		equ		10       ;  倒计时 标志

;CntDownFlag	
   F_CntEnable	equ		7
   F_CntStart	equ		6
   F_CntEnd		equ		5

C_I2CCLKAddr_CntDownBakHour		equ		11       ;  倒计时 小时-备份
C_I2CCLKAddr_CntDownBakMin		equ		12       ;  倒计时 分  -备份
C_I2CCLKAddr_CntDownBakSec		equ		13       ;  倒计时 秒  -备份

DIG_0	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_g)
DIG_1	equ	 (SEG_a+SEG_b)
DIG_2	equ	 (SEG_b+SEG_c+SEG_e+SEG_f+SEG_g)
DIG_3	equ	 (SEG_a+SEG_b+SEG_c+SEG_f+SEG_g)
DIG_4	equ	 (SEG_a+SEG_b+SEG_d+SEG_f)
DIG_5	equ	 (SEG_a+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_6	equ	 (SEG_a+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_7	equ	 (SEG_a+SEG_b+SEG_c)
DIG_9	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_8	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)

DIG_G	equ	 SEG_f
DIG_A	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f)
DIG_B	equ	 (SEG_a+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_H	equ	 (SEG_a+SEG_b+SEG_d+SEG_e+SEG_f)
DIG_H1	equ	 (SEG_a+SEG_d+SEG_e+SEG_f)
DIG_COLON equ (SEG_b+SEG_c)
DIG_E	equ	 (SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_N   equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e)
DIG_C   equ	 (SEG_e+SEG_f+SEG_g)
DIG_D   equ	 (SEG_a+SEG_b+SEG_e+SEG_f+SEG_g)
DIG_F	equ	 (SEG_c+SEG_d+SEG_e+SEG_f)
DIG_I   equ  (SEG_a+SEG_b)
DIG_L   equ  (SEG_d+SEG_e+SEG_g)
DIG_O	equ  (SEG_a+SEG_e+SEG_f+SEG_g)
;SysFlag, F_SlaverSlow
;      F_SlaverSlow = 0 , 从设备速度快，等待长时间短    ，  适用TM1650, EPROM 24C02,速度快
;      F_SlaverSlow = 1 , 从设备速度慢，需要等待长时间长，   适用I2C时钟使用32K晶体，速度慢
;以下是程序


TM1650_OFF:
	CALL	E2Start_2018
	
	MOV		A,@0x48
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,@0x20						; 01 开显示， 00，关闭显示
	JMP		_Tm1650OnOffCom
;TM1650 打开关闭显示
TM1650_ON:
	CALL	E2Start_2018
	
	MOV		A,@0x48
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	DefaultContrast				;读取默认亮度，
	MOV		Prgtmp3,A
	SWAPA	Prgtmp3						;放在 MSB，交换
	OR		A,@0X01						; 开显示   ;	MOV		A,@0x21						; 01 开显示， 00，关闭显示
_Tm1650OnOffCom:
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	JMP		E2Stop_2018					;优化代码
;	CALL	E2Stop_2018
;	RET

;*******************************************************************************************
;     显示数据， A中
;   WriteComData    使用RAM  , Prgtmp2,tmp3,tmp4
TM1650_WriteCom1:
WriteCOM1Data:
	MOV		Prgtmp2,A
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM1
	JMP		_Tm1650WriteCom
TM1650_WriteCom2:
WriteCOM2Data:
	MOV		Prgtmp2,A
    JBC     SysFlag,F_RelayOn
    BS      PrgTmp2,4
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM2
	JMP		_Tm1650WriteCom
TM1650_WriteCom3:
WriteCOM3Data:
	MOV		Prgtmp2,A
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM3
	JMP		_Tm1650WriteCom
TM1650_WriteCom4:
WriteCOM4Data:
	MOV		Prgtmp2,A
	CALL	E2Start_2018
	MOV		A,@C_TM1650_COM4
	JMP		_Tm1650WriteCom
;*******************************************************************************************
;	  显存地址 ，0,1,2,3  放在 E2Addr中
;     显示数据， Prgtmp2中
;    TM1650_WriteRam 其它程序不使用，删除处理
;TM1650_WriteRam:
;	
;	CALL	E2Start_2018
;	
;	BC		StatusReg,CarryFlag
;	RLCA	E2_Addr
;	AND		A,@0x06 				;对E2Addr 纠错 
;	OR		A,@0x68					;写显存地址 ，68,6A,6C,6E 四个地址 ，对应COM1,COM2,COM3,COM4
_Tm1650WriteCom:	
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	JMP		E2Stop_2018				; 优化代码
;	CALL	E2Stop_2018
;	RET	
;*****************************************
;  读到的键值在 Prgtmp3中
;
TM1650_ReadKey:
	CALL	E2Start_2018

	MOV		A,@0x49
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck
	
	CALL	E2ReadByte_2018
	CALL	E2SendAck_2018
	JMP		E2Stop_2018				; 优化代码
;	CALL	E2Stop_2018
;	RET


_E2ErrorNoAck:
	MOV		A,@0xEF
	RET


;**************************修改代码**2018.07.12*******************************
; 开始前， SCL,SDA 总线释放状态
;//mark:   E2Start_2018
E2Start_2018:
	BC		P_SCL,B_SCL		; 告知从设备

	BS		P_SDA,B_SDA		; SDA 由高变低为开始
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
	
	BS		P_SCL,B_SCL

	
	BC		P_SDA,B_SDA		;

	ret
	

;*************************************************
;//mark:  E2SendAck_2018
E2SendAck_2018:
    BC  	P_SCL , B_SCL 
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BC  	P_SDA , B_SDA 

	

    BS  	P_SCL , B_SCL 
	ret

;*************************************************	
; 命令字放在A中  , EPROM 传输一个命令字
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
;//mark:  E2WriteCommand_2018
E2WriteCommand_2018:
	BC		P_SCL,B_SCL	;
	MOV		Prgtmp3,A			; 保存数据

	MOV		A,@8
	MOV		Prgtmp4,A
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA

;_E2WriteCommandLoop:
	BC		P_SCL,B_SCL	;
	

	BC		P_SDA,B_SDA
	JBC		Prgtmp3,7
	BS		P_SDA,B_SDA	;

	BS		P_SCL,B_SCL	; Tlow=3*0.6=1.8us
	

	RLC		Prgtmp3
	DJZ		Prgtmp4
	JMP		$-7			;_E2WriteCommandLoop; Thigh=4*0.6=2.4us

	RET	
	
;//mark: E2GetAck_2018
E2GetAck_2018:
    BC  	P_SCL , B_SCL 
	IOR		P_SDA
	OR		A,@1<<B_SDA
	IOW		P_SDA

	

    BS  	P_SCL , B_SCL 
	

	BC		StatusReg,CarryFlag
	JBS		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RET		

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//mark:    E2ReadPageData
E2ReadPageData:
	CALL	E2Start_2018
	MOV		A,@0xA0
	JBC		SysFlag,F_SlaverSlow
	MOV		A,@0xB0					; eprom 读设备地址

	CALL	E2WriteCommand_2018		; 设备地址
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	CALL	E2Start_2018
	MOV		A,@0xA1
	JBC		SysFlag,F_SlaverSlow
	MOV		A,@0xB1					; eprom 读设备地址
	CALL	E2WriteCommand_2018		; 设备地址
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck
	JMP		$+2

_E2ReadPageLoop:
	CALL	E2SendAck_2018
	CALL	E2ReadByte_2018
	MOV		R0,A
	INC		RamSelReg

	DJZ		Prgtmp1
	JMP		_E2ReadPageLoop
;	JMP		E2SendNoAckStop_2018
;*************************************************
;//mark:  E2SendNoAckStop_2018
E2SendNoAckStop_2018:            ;  发送完成 NOACK 接着发送 STOP 指令
    BC  	P_SCL , B_SCL 
	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BS  	P_SDA , B_SDA 

	

    BS  	P_SCL , B_SCL 
	

;//mark:   E2Stop_2018
E2Stop_2018:
	BC		P_SCL,B_SCL	;

	IOR		P_SDA
	AND		A,@~(1<<B_SDA)			
	IOW		P_SDA
    BC  	P_SDA , B_SDA 
	

	BS		P_SCL,B_SCL	;
	
	
    BS  	P_SDA , B_SDA 

	ret


;******************************************************
;读一个字节,  
;//mark:  E2ReadByte_2018
E2ReadByte_2018:					; 退出时， SCL = 0
	CLR   	Prgtmp3
	MOV		A,@8
	MOV		Prgtmp4,A
_E2_ReadByteLoop2018:				; 循环中，SCL 周期 = 11 ， 约 11*0.56= 6.2us = 160K 速度
	BC		P_SCL,B_SCL

	JBS		Prgtmp4,3
	JMP		$+4
	IOR  	P_SDA
	OR  	A,@1<<B_SDA
	IOW		P_SDA

	

	BS		P_SCL,B_SCL

	BC		StatusReg,CarryFlag
	JBC		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RLC		Prgtmp3

					; 此处， SCL 由 0 -> 1 ，需要等待 7 个指令周期以上，时间少于7个周期，会出错

					; 此处， SCL 由 0 -> 1 ，需要等待 7 个指令周期以上，时间少于7个周期，会出错
	DJZ		Prgtmp4
	JMP		_E2_ReadByteLoop2018

	MOV		A,Prgtmp3			; 读出的数据放在A中	
	RET



;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//mark:  E2WritePageData
E2WritePageData:
	CALL	E2Start_2018
	MOV		A,@0xA0				; 写EPROM 设备地址
	JBC		SysFlag,F_SlaverSlow
	MOV		A,@0xB0				; 写EPROM 设备地址

	CALL	E2WriteCommand_2018		; 设备地址,使用tmp3,tmp4
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

_E2WritePageLoop:
	MOV		A,R0
	CALL	E2WriteCommand_2018
	CALL	E2GetAck_2018
	JBS		StatusReg,CarryFlag
	JMP		_E2ErrorNoAck

	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		_E2WritePageLoop	

	JMP		E2Stop_2018				; 优化代码
;	CALL	E2Stop_2018
;	RET


endm


M_SleepWakeupInt  macro 
;//mark: M_SleepWakeupInt 睡眠唤醒后进入中断	
SlepStart:
	MOV		A,@0B00001111;
	CONTW								; 设置WDT分频比 > 1
	WDTC
	MOV     A,@0B00000000;
	IOW		IOCE						; 关闭WDT

	MOV		Port6,Port6

	MOV		A,@ICMask
	IOW		IOCF
	SLEP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	WDTC
endm


M_Sleep  macro 
;//mark: M_Sleep 睡眠	
;P63 只能做为输入口， 内部无上拉，无下拉电阻
;端口唤醒时需要注意，P63 必须外部接上拉或下地电阻，否则端口不稳定，产生连续的唤醒
;  睡眠时电流 0.5uA
;  睡眠前设置好端口
SlepStart:
; 进入睡眠前，请设置好P6端口状态，
	DISI								; 关中断
	MOV		A,@0B00001111;
	CONTW								; 设置WDT分频比 > 1
	WDTC
	MOV     A,@0B00000000;
	IOW		IOCE						; 关闭WDT

	MOV		Port6,Port6

	MOV		A,@ICMask
	IOW		IOCF
	SLEP
	NOP
	NOP
	NOP
	NOP
	WDTC
endm


M_Slep  macro 
;//mark: M_Slep 睡眠	
;P63 只能做为输入口， 内部无上拉，无下拉电阻
;端口唤醒时需要注意，P63 必须外部接上拉或下地电阻，否则端口不稳定，产生连续的唤醒
;  睡眠时电流 0.5uA

SlepStart:
	DISI								; 关中断
	MOV		A,KeyOutPort
	AND		A,@~KeyColMask
	MOV		KeyOutPort,A				; 行输出低电平， 列上拉全高电平

	MOV		A,@0B00001111;
	CONTW								; 设置WDT分频比 > 1
	WDTC
	MOV     A,@0B00000000;
	IOW		IOCE						; 关闭WDT

	MOV		Port6,Port6

	MOV		A,@ICMask
	IOW		IOCF
	SLEP
	NOP
	NOP
	NOP
	NOP
	WDTC
	JMP		WakeupStart
endm

;//mark: ****************************
;//红外接收模块，与32K通信程序
; 使用RAM     RTDataStep,RTDataBit,RTData
; 从RAM读数据，发送到外模块，或外模块写到RAM中。
;    每次传送 6 + 8 位数据， 第一位为读写控制位，0-向我写数据，1-从我读数据
M_RTData_Table  MACRO
;//mark: RTData【接收发送数据模块】
RTDataFunction:
    MOV     A,RTDataStep
    ADD     PC,A
    JMP     RTChkDataLow       ; 0
    JMP     RTDataClkLow       ; 1 
    JMP     RTDataRxBit        ; 2    ; CLK=1,
                               ;
    JMP     RTDataChkRW        ; 3    
    JMP     RTDataClkLow       ; 4    
    JMP     RTDataRxBit        ; 5    ; CLK=1,
                               ;
    JMP     RTDataWriteMe      ; 6        
                               ;
    JMP     RTDataClkLowW      ; 7        
    JMP     RTDataClkHigh      ; 8    
    JMP     RTDataWEnd         ; 9     
endm
M_RTData_ROM   macro
;//TODO: 0、检测DATA变低，变低后开始接收地址
; 检测Data=0低电平，要收发数据
RTChkDataLow:
    JBC     RTData_Port,RTData_B
    RET

    MOV     A,@6
    MOV     RTDataBit,A
_RTNextStep:
    INC     RTDataStep
    RET
;//TODO: 1(4)、CLK 变低，请求地址数据，主设备在CLK变低时写数据
RTDataClkLow:
    BC      RTClk_Port,RTClk_B
    JMP     _RTNextStep
;********************************************************
;//TODO: 2(5)、CLK 变高，读地址数据
RTDataRxBit:                                    ; B5 - 读写位， 0 - 向我写数据， 1-从我读数据
    BS      RTClk_Port,RTClk_B                  ; B4-B0  [0-31] ram地址
    BC      StatusReg,CarryFlag
    JBC     RTData_Port,RTData_B
    BS      StatusReg,CarryFlag

    RLC     RTData
_RTDecStep:
    DEC     RTDataBit
    JBC     StatusReg,ZeroFlag
    JMP     _RTNextStep

    DEC     RTDataStep
    RET
;//NOTE:└─地址位6位，没读完，重复第2步，读完进入下一步
;********************************************************
;//TODO:3、检查ADDR 最高位，即读到的第一位，0-向我写数据，1-从我读数据
RTDataChkRW:
    MOV     A,RTData
    MOV     RTDATA_Addr,A
    CLR     RTData
    MOV     A,@8
    MOV     RTDataBit,A

    JBS     RTDATA_Addr,F_ReadMe    ;最高位 5
    JMP     _RTNextStep                 ; 向我写数据
_RTDataR:
;//NOTE:└─从我读数据，改变DAT为输出，准备数据，指向第7步
    IOR     RTData_Port                 ; 读我的数据，我输出
    AND     A,@~(1<<RTData_B)
    IOW     RTData_Port

    MOV     A,RTDATA_Addr
    AND     A,@0X1F
    ADD     A,@0x10
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     RTData,A                    ; 从地址获得我的数据

    MOV     A,@7
    MOV     RTDataStep,A
    RET
;********************************************************
;//TODO:  6、数据保存
RTDataWriteMe:
    MOV     A,RTDATA_Addr
    AND     A,@0X1F
    ADD     A,@0x10
    MOV     RamSelReg,A
    MOV     A,RTData
	AND		A,@0X01E
	JBC		StatusReg,ZeroFlag
	JMP		$+3

    MOV     A,RTData
    MOV     R0,A                    ; 从地址获得我的数据

    CLR     RTDataStep
    RET
;********************************************************
;//NOTE: ┌─从我这读数据， 
;//TODO:7、CLK 变低，发送数据
RTDataClkLowW:
    BC      RTClk_Port,RTClk_B

    RLC     RTData
    JBS     StatusReg,CarryFlag
    BC      RTData_Port,RTData_B
    JBC     StatusReg,CarryFlag
    BS      RTData_Port,RTData_B

    JMP     _RTNextStep
;//TODO:8、CLK 变高，读完成8位数据，下一步，没有读完，上一步7
RTDataClkHigh:
    BS      RTClk_Port,RTClk_B
    JMP     _RTDecStep
;//TODO: 9、数据完成，DATA变为输入，STEP=0
RTDataWEnd:
    IOR     RTData_Port
    OR      A,@1<<RTData_B
    IOW     RTData_Port
    CLR     RTDataStep
    RET
endm

M_I2CMaster201909 macro
;//NOTE:M_I2CMaster201909
/*
 2019.9.7 更新，为32K晶体使用
    TM1650 不是标准I2C设备，单独使用总线P67,P66
    其它I2C设备，EPROM,旋转按扭，共用总线

    增加总线忙闲检测
    使用注意：  SCL, SDA 在同一个PORT上，  P62,P61

    TM1650 特点：
	    地址  48H     --         显示开关控制   
		              48H XXH   显示控制
					      XX :  B6-4 8级亮度，  B3 - 8/7段控制 ， B0 - 关/开 显示
					  68H XX    COM1 数据
					      XX :  S7,S6,S5,S4,S3,S2,S1,S0 段码值
				      6AH XX    COM2 数据
					  6CH XX    COM3 数据
					  6EH XX    COM4 数据
					  49H 读按键值(占用4个地址)
					  4BH ....
					  4DH ....
					  4FH ....
	TM1650 一个设备地址，只有一个RAM，采用立即读写方式
	EPROM  - 24C02,占用 A0-AF
	                  A0H 写
					  A1H 读
	                  A2H 写
					  A3H 读
	                  A4H 写
					  A5H 读
	                  A6H 写
					  A7H 读
	                  A8H 写
					  A9H 读
	                  AAH 写
					  ABH 读
	                  ACH 写
					  ADH 读
	                  AEH 写
					  AFH 读

    I2C 旋转按扭 占用 98H, 99H 两个地址				  
*/

ifdef EnTm1650Disp

DIG_0	equ	 (SEG_a|SEG_b|SEG_c|SEG_d|SEG_e|SEG_g)
DIG_1	equ	 (SEG_a|SEG_b)
DIG_2	equ	 (SEG_b|SEG_c|SEG_e|SEG_f|SEG_g)
DIG_3	equ	 (SEG_a|SEG_b|SEG_c|SEG_f|SEG_g)
DIG_4	equ	 (SEG_a|SEG_b|SEG_d|SEG_f)
DIG_5	equ	 (SEG_a|SEG_c|SEG_d|SEG_f|SEG_g)
DIG_6	equ	 (SEG_a|SEG_c|SEG_d|SEG_e|SEG_f|SEG_g)
DIG_7	equ	 (SEG_a|SEG_b|SEG_c)
DIG_9	equ	 (SEG_a|SEG_b|SEG_c|SEG_d|SEG_f|SEG_g)
DIG_8	equ	 (SEG_a|SEG_b|SEG_c|SEG_d|SEG_e|SEG_f|SEG_g)

DIG_G	equ	 SEG_f
DIG_A	equ	 (SEG_a|SEG_b|SEG_c|SEG_d|SEG_e|SEG_f)
DIG_B	equ	 (SEG_a|SEG_d|SEG_e|SEG_f|SEG_g)
DIG_H	equ	 (SEG_a|SEG_b|SEG_d|SEG_e|SEG_f)
DIG_H1	equ	 (SEG_a|SEG_d|SEG_e|SEG_f)
DIG_COLON equ (SEG_b|SEG_c)
DIG_E	equ	 (SEG_c|SEG_d|SEG_e|SEG_f|SEG_g)
DIG_N   equ	 (SEG_a|SEG_b|SEG_c|SEG_d|SEG_e)
DIG_C   equ	 (SEG_e|SEG_f|SEG_g)
DIG_D   equ	 (SEG_a|SEG_b|SEG_e|SEG_f|SEG_g)
DIG_F	equ	 (SEG_c|SEG_d|SEG_e|SEG_f)
DIG_I   equ  (SEG_a|SEG_b)
DIG_L   equ  (SEG_d|SEG_e|SEG_g)
DIG_O	equ  (SEG_a|SEG_e|SEG_f|SEG_g)

;以下是程序

    C_TmSCLo_SDAi  ==   C_TmSCLo_SDAo     |   (1<<TMB_SDA)
    C_TmSCLi_SDAo  ==   C_TmSCLo_SDAo     |   (1<<TMB_SCL)
    C_TmSCLi_SDAi  ==   C_TmSCLo_SDAo     |   (1<<TMB_SCL)    |   (1<<TMB_SDA)

;********************************************************************
TM_Start:
    MOV     A,@C_TmSCLi_SDAo
    IOW     TMP_SDA
	BC      TMP_SDA,TMB_SDA
	RET	
;********************************************************************
TM_WriteCommand:
	MOV     Prgtmp3,A
	MOV     A,@8
	MOV     Prgtmp4,A

_TM_Loop:
	MOV     A,@C_TmSCLo_SDAo
	IOW     TMP_SDA	
	BC      TMP_SCL,TMB_SCL

	JBS     Prgtmp3,7
	BC      TMP_SDA,TMB_SDA
	JBC     Prgtmp3,7
	BS      TMP_SDA,TMB_SDA

	MOV     A,@C_TmSCLi_SDAo
	IOW     TMP_SDA

	RLC     Prgtmp3
	DJZ     Prgtmp4
	JMP     _TM_Loop
	RET
;********************************************************************
TM_GetAck:
TM_Get1Bit:
	MOV     A,@C_TmSCLo_SDAi
	IOW     TMP_SDA	
	BC      TMP_SCL,TMB_SCL

	MOV     A,@C_TmSCLi_SDAi
	IOW     TMP_SDA	
	RET
;********************************************************************
;********************************************************************
TM1650_WriteCom1:			
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM1
	JMP     TM1650_ON+4

TM1650_WriteCom2:
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM2
	JMP     TM1650_ON+4

TM1650_WriteCom3:
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM3
	JMP     TM1650_ON+4

TM1650_WriteCom4:
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM4
	JMP     TM1650_ON+4

;********************************************************************
TM1650_OFF:
	MOV     A,@0x20
    JMP     $+2
TM1650_ON:
    MOV     A,@0X31
    MOV     PrgTmp1,A

	CALL	TM_Start
    MOV     A,@0x48
	CALL	TM_WriteCommand
	CALL	TM_GetAck

	MOV     A,PrgTmp1
	CALL	TM_WriteCommand
	CALL	TM_GetAck

TM_Stop:   
	MOV     A,@C_TmSCLo_SDAo
	IOW     TMP_SDA	
	BC      TMP_SCL,TMB_SCL
	BC      TMP_SDA,TMB_SDA

	MOV     A,@C_TmSCLi_SDAo
	IOW     TMP_SDA	

	MOV     A,@C_TmSCLi_SDAi
	IOW     TMP_SDA	
	RET
endif
;********************************************************************

;********************************************************************
ifdef EnTm1650Key
TM_ReadByte:
	CLR     Prgtmp3
	MOV     A,@8
	MOV     Prgtmp4,A

	CALL	TM_Get1Bit
	
    BC      StatusReg,CarryFlag
    JBC     TMP_SDA,TMB_SDA
    BS      StatusReg,CarryFlag
    RLC     Prgtmp3

    DJZ     Prgtmp4
    JMP     $-6
    RET

; 键值读到 Prgtmp3 中
TM1650_ReadKeyValue:		
	CALL	TM_Start
	MOV     A,@0x49
	CALL	TM_WriteCommand
	CALL	TM_GetAck
	CALL	TM_ReadByte
    JMP     TM_Stop
endif
;********************************************************************
ifdef EnI2CMaster
C_I2CSclIn_SdaOut   equ     C_I2CBusOut    +  (1<<B_SCL)
C_I2CSclOut_SdaIn   equ     C_I2CBusOut    +  (1<<B_SDA) 
C_I2CBusIn          equ     C_I2CBusOut    +  (1<<B_SCL) + (1<<B_SDA)

_E2ErrorNoAck:
_ErrorBusBusy:
	MOV		A,@0xEF
	RET

;//NOTE: I2C_BUSo0
I2C_BUSo0:                              ; SCL 输出0， SDA 输出0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy
	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	BC      P_SCL,B_SCL
	BC      P_SDA,B_SDA
    RET
;//NOTE: I2C_BUSo
I2C_BUSo:                               ; SCL 输出端口，SDA输出端口
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy

	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	RET
;**************************修改代码**2018.07.12*******************************
; 开始前， SCL,SDA 总线释放状态
;//NOTE:   I2C_Start   
;              SDA,SCL要有上拉电阻
I2C_Start:
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy
    
;//NOTE:I2C_SCLi_SDAo0
I2C_SCLi_SDAo0:
	MOV     A,@C_I2CSclIn_SdaOut        ; SCL =1 ,SDA 1->0
	IOW     P_SDA
	BC      P_SDA,B_SDA
    RET
;//NOTE:I2C_SCLi_SDAo
I2C_SCLi_SDAo:
	MOV     A,@C_I2CSclIn_SdaOut        ; SCL =1 ,SDA 1->0
	IOW     P_SDA
	RET
;//NOTE:I2C_SCLo_SDAo
I2C_SCLo_SDAo:                          ; SCL 只能输出为0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy   
	MOV     A,@C_I2CBusOut              ; 占用总线输出数据
	IOW     P_SDA
    BC      P_SCL,B_SCL
	RET
	

;*************************************************
;//NOTE:  I2C_SendAck
I2C_SendAck:
	CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    JMP     I2C_SCLi_SDAo               ; SCL=1, SDA=0
;*************************************************	
; 命令字放在A中  , EPROM 传输一个命令字
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
;//NOTE:  I2C_WriteCommand
I2C_WriteCommand:
	MOV		Prgtmp3,A			; 保存数据
	MOV		A,@8
	MOV		Prgtmp4,A

_I2CWriteCommandLoop:
	CALL    I2C_SCLo_SDAo

	JBS		Prgtmp3,7           ; 设置 SDA
	BC		P_SDA,B_SDA
	JBC		Prgtmp3,7
	BS		P_SDA,B_SDA	;

	CALL    I2C_SCLi_SDAo	    ; SCL=1

	RLC		Prgtmp3
	DJZ		Prgtmp4
	JMP		_I2CWriteCommandLoop

	RET	
;*****************************************************
;//NOTE: I2C_GetAck
I2C_Get1Bit:
I2C_SendNoAck:
I2C_GetAck:
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy

	MOV     A,@C_I2CSclOut_SdaIn
	IOW     P_SCL
	BC      P_SCL,B_SCL

;//NOTE:I2C_BusIn
I2C_BusIn:
	MOV     A,@C_I2CBusIn
	IOW     P_SCL
	RET
	

;******************************************************
;读一个字节,  
;//TODO:  I2C_ReadByte
I2C_ReadByte:					; 退出时， SCL = 0
	CLR   	Prgtmp3
	MOV		A,@8
	MOV		Prgtmp4,A
_I2C_ReadByteLoop:				; 循环中，SCL 周期 = 11 ， 约 11*0.56= 6.2us = 160K 速度
    CALL    I2C_Get1Bit

	BC		StatusReg,CarryFlag
	JBC		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RLC		Prgtmp3

	DJZ		Prgtmp4
	JMP		_I2C_ReadByteLoop

	MOV		A,Prgtmp3			; 读出的数据放在A中	
	RET

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   PrgTmp5   设备地址      ，  B0 - 0 写数据， B0-1 读数据
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:    I2C_ReadPageData
I2C_ReadPageData:
	CALL	I2C_Start
	MOV		A,PrgTmp5
	CALL	I2C_WriteCommand
	CALL	I2C_GetAck
	JBC     P_SDA,B_SDA		
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	I2C_WriteCommand
	CALL	I2C_GetAck
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck
;********************************************************************    
    CALL    I2C_GetAck                  ; 占用总线，释放总线
; 此处必须增加一个时钟，前一个读ACK结束时，从设备输出0，表示收到，增加这一个时钟
; 通知从设备已经读到了ACK，可以释放总线了。如果从设备不释放总线，下面一个开始
; 将会出错
;********************************************************************    
	CALL	I2C_Start
	INCA    PrgTmp5
	CALL	I2C_WriteCommand
	CALL	I2C_GetAck
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    JMP     $+2
_I2CReadPageLoop:
	CALL	I2C_SendAck

	CALL	I2C_ReadByte
	MOV		R0,A
	INC		RamSelReg

	DJZ		Prgtmp1
	JMP		_I2CReadPageLoop

;*************************************************
;  发送完成 NOACK 接着发送 STOP 指令
    CALL    I2C_SendNoAck
;//mark:   I2C_Stop
I2C_Stop:
    CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    CALL    I2C_SCLi_SDAo               ; SCL=1, SDA=0
    JMP     I2C_BusIn                   ; SCL=1, SDA=1

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   PrgTmp5   设备地址      ，  B0 - 0 写数据， B0-1 读数据
;   Prgtmp1,  写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:I2C_WritePageData
I2C_WritePageData:
	CALL	I2C_Start
	MOV		A,PrgTmp5               ; 写EPROM 设备地址
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	CALL	I2C_GetAck
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

	MOV		A,Prgtmp2
	CALL	I2C_WriteCommand
	CALL	I2C_GetAck
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_WritePageLoop:
	MOV		A,R0
	CALL	I2C_WriteCommand
	CALL	I2C_GetAck
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		_I2C_WritePageLoop	

	JMP		I2C_Stop                ; 优化代码
endif
endm




M_I2C_Slaver201909 macro
;//NOTE: M_I2C_Slaver201909
ChkRWBitMask:
RcvAddrBitMask:
    ADD     PC,A
    RETL    @1<<7
    RETL    @1<<6
    RETL    @1<<5
    RETL    @1<<4
    RETL    @1<<3
    RETL    @1<<2
    RETL    @1<<1
    RETL    @1<<0

DevAddrSame:
    ADD     PC,A
    RETL    @0B11111111
    RETL    @0B10000000     ;
    RETL    @0B11000000     ;
    RETL    @0B11100000     
    RETL    @0B11110000     
    RETL    @0B11111000
    RETL    @0B11111100
    RETL    @0B11111110

DevAddrSame1:
    ADD     PC,A
    RETL    @0B11111110
    RETL    @0B00000000
    RETL    @0B10000000     ;
    RETL    @0B11000000     ;
    RETL    @0B11100000     
    RETL    @0B11110000     
    RETL    @0B11111000
    RETL    @0B11111100
 
;*****************************************
;使用 I2C Slaver 且注意：
;   由于存在 列表，需要将 宏放在程序开始位置
;   将 IntPortEnd 放在 main开始
;*****************************************
	C_Slaver_BusIn		==	 C_Slaver_SCLi_SDAo | (1<<SlaverSDA)

    C_ChkDevAddr        ==   1
    C_DevAddr_RW        ==   C_ChkDevAddr       + 1
    C_GetByteAddr       ==   C_DevAddr_RW       + 1
    C_WriteMeDataFirst  ==   C_GetByteAddr      + 1      
    C_WriteByte         ==   C_WriteMeDataFirst + 1
    C_WriteMeDataNext   ==   C_WriteByte        + 1        
    C_GetAck            ==   C_WriteMeDataNext  + 1
    C_ReadAck           ==   C_GetAck           + 1
    C_RcvByte           ==   C_ReadAck          + 1
    C_TxAck             ==   C_RcvByte          + 1
    C_TxByte            ==   C_TxAck            + 1
;*****************************************
;//todo: IntPort                               ;此为查询方式处理。I2C 协议，避免 maskter设备速度过快有些中断漏掉
IntPort:
	MOV		A,I2CS_Port
	XOR		A,SystemFlag
	AND		A,@I2CSMask
	MOV		IntTemp,A                        ; IntTemp为 端口当前检测到的变化位
	XOR		SystemFlag,A                     ; SystemFlag 为端口当前值
 
    JBS     SystemFlag,F_SDAInput
    JMP     ChkStartEnd 

    JBS     SystemFlag,SlaverSCL            ; 在 SCL 高电平时
    JMP     ChkStartEnd    

	JBS		IntTemp,SlaverSDA               ; SDA 变化了
	JMP		ChkStartEnd
	
	JBS		SystemFlag,SlaverSDA
    JMP     Step01_RcvDevAddr               ; SDA 由高变低为 START,  GetStart:
GetStop:                                    ; SDA 由低变高为 STOP
    BS      SystemFlag,F_DataValid          ; 接收到STOP ，处理这一组数据

    CLR     I2CStep
    JMP     _SlaverSDA_1

Error_DevAddrDiff:      
    CLR     I2CStep                         ; SDA当前电平为低电平，即 SDA由高变低时，变 START信号，START后接收设备地址
ChkStartEnd:
NextOpration:
;//mark: 命令表
    MOV     A,I2CStep
    ADD     PC,A
    JMP     IntPortEnd                      ;0  等待接收 START ，或 STOP 空闲操作，只用于接收 START,STOP
    JMP     Step02_ChkDevAddr               ;1
    JMP     Step03_DevAddr_RW               ;2
    JMP     Step04_GetByteAddr              ;3
    JMP     Step05_WriteMeDataFirst         ;4
    JMP     Step06_WriteByte                ;5
    JMP     Step07_WriteMeDataNext          ;6
    JMP     Step14_GetAck                   ;7
    JMP     Step15_ReadAck                  ;8 
    JMP     Step_RcvByte                    ;9 
    JMP     Step_TxACK                      ;10
    JMP     Step_TxByte                     ;11
;*****************************************************************************************    
Step01_RcvDevAddr:                          ; 接收到 START 后进行的操作
    CLR     DevAddrCnt                      ; 接收地址计数器
    MOV     A,@C_ChkDevAddr
    MOV     I2CStep,A
    CLR     Data
    JMP     IntPortEnd
;*****************************************************************************************    
CalDevAddr:
    RRCA    DevAddrCnt
    MOV     PrgTmp1,A
    RRC     PrgTmp1
    RRCA    PrgTmp1    
    AND     A,@7
    ADD     A,@DevAddrCnt
    MOV     PrgTmp1,A

    MOV     A,DevAddrCnt
    AND     A,@7
    JBS     StatusReg,ZeroFlag
    INC     PrgTmp1

    MOV     A,PrgTmp1
    MOV     RamSelReg,A
    RET

; 根据位数，计算保存RAM地址
SaveDevAddress:
    CALL    CalDevAddr
    MOV     A,Data
    MOV     R0,A
    CLR     Data
    RET
;*****************************************************************************************    
GetLsbAddrCnt:
    MOV     A,DevAddrCnt
    AND     A,@7
    RET

Step02_ChkDevAddr:                          ; 当前接收到的字节为 ADDR
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化
    JMP     IntPortEnd
    
	JBC		SystemFlag,SlaverSCL
	JMP		$+5                   

    MOV     A,DevAddrCnt                    ; SCL为低电平，改变端口方向
    JBS     StatusReg,ZeroFlag
    JMP     IntPortEnd
    JMP     SDAInput

    MOV     A,DevAddrCnt
    AND     A,@7
    CALL    RcvAddrBitMask
    JBS     SystemFlag,SlaverSDA
    CLRA
    OR      Data,A

    INC     DevAddrCnt

    MOV     A,DevAddrCnt
    AND     A,@7
    JBC     StatusReg,ZeroFlag
    CALL    SaveDevAddress

    MOV     A,DevAddrCnt
    XOR     A,DevAddrByte
    JBS     StatusReg,ZeroFlag
    JMP     IntPortEnd

    MOV     A,DevAddrCnt
    AND     A,@7
    JBS     StatusReg,ZeroFlag
    CALL    SaveDevAddress
;地址接收完成，已经保存                 ; PrgTmp1 - 最后一个地址
    MOV     A,@DevAddrCnt
    SUB     A,PrgTmp1
    MOV     PrgTmp2,A                ; PrgTmp2 - 设备地址个数

    MOV     A,PrgTmp1
    MOV     RamSelReg,A
    CALL    GetLsbAddrCnt
    CALL    DevAddrSame1
    AND     A,R0
    JBS     StatusReg,ZeroFlag
    JMP     $+8

    DEC     PrgTmp2
    JBC     StatusReg,ZeroFlag
    JMP     Step02_DevAddrChkPass

    DEC     RamSelReg
    OR      A,R0
    JBC     StatusReg,ZeroFlag
    JMP     $-6
;*****检查是否相同**********
    DECA    DevAddrCnt
    AND     A,@7
    JBC     StatusReg,ZeroFlag
    DEC     PrgTmp1

    MOV     A,@DevAddrCnt
    SUB     A,PrgTmp1                ; 接收到的地址最后一个
    MOV     PrgTmp3,A                ; PrgTmp3 - 设备地址字节个数
    ADD     A,@DevAddrByte
    MOV     PrgTmp2,A                ; 设置的地址最后一个

    MOV     A,PrgTmp1
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     PrgTmp4,A
    MOV     A,PrgTmp2
    MOV     RamSelReg,A
    MOV     A,R0
    XOR     A,PrgTmp4
    MOV     PrgTmp4,A

    DECA    DevAddrCnt
    AND     A,@7
    CALL    DevAddrSame  
    AND     A,PrgTmp4
    JBS     StatusReg,ZeroFlag
    JMP     Error_DevAddrDiff
    
Step02_ComDevAddrLoop:
    DEC     PrgTmp1
    DEC     PrgTmp2
    DEC     PrgTmp3
    JBC     StatusReg,ZeroFlag
    JMP     Step02_DevAddrChkPass

    MOV     A,PrgTmp1
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     PrgTmp4,A
    MOV     A,PrgTmp2
    MOV     RamSelReg,A
    MOV     A,R0
    XOR     A,PrgTmp4
    JBC     StatusReg,ZeroFlag
    JMP     Step02_ComDevAddrLoop
    JMP     Error_DevAddrDiff

Step02_DevAddrChkPass:
    MOV     A,@C_DevAddr_RW
    JMP     PreSetTxAck                     ; 发送 TX_ACK 后进入 Step03_DevAddr_RW（检测设备地址是读还是写）

Step03_DevAddr_RW:                          ; 分析 addr 是读还是写
    CALL    CalDevAddr
    DECA    DevAddrCnt
    AND     A,@7
    CALL    ChkRWBitMask
    AND     A,R0
    JBS     StatusReg,ZeroFlag              ; Addr , B0-0 写当前设备，  -1 读当前设备
    JMP     _Step03_DevAddr_R

    MOV     A,@C_GetByteAddr                ; 向我写数据
    JMP     PreSetRcvByte                   ; 接收一个字节后进入 Step04_GetByteAddr （接收到的是RAM地址）

Step04_GetByteAddr:                         ; 接收到的是RAM地址
    MOV     A,Data
    ADD     A,@DataBuf
    MOV     DataPtr,A                       ; 设定数据指针

    MOV     A,@C_WriteMeDataFirst           ; 
    JMP     PreSetTxAck                     ; 发送 TX_ACK 后，进入 Step05_WriteMeDataFirst （向我写第一个数据）
    
Step05_WriteMeDataFirst:
    MOV     A,@C_WriteByte                  ; 
	JMP     PreSetRcvByte                   ; 接收到一个字节后，进入 Step06_WriteByte （向我写一个数据）
	
Step06_WriteByte:                           ; 当前进入写数据操作
    MOV     A,DataPtr
    MOV     RamSelReg,A                     ; 置数据指针
    MOV     A,Data
    MOV     R0,A                            ; 保存数据
    INC     DataPtr                         ; 数据指针向后移一个

    MOV     A,@0x30                         ; 153B RAM最大2F，大于2F，重置BUF
    SUB     A,DataPtr
    JBS     StatusReg,CarryFlag
    JMP     $+3
    MOV     A,@DataBuf                      ; 数据指针大于等于0X30 ，重新设置数据指针为DataBuf
    MOV     DataPtr,A

    MOV     A,@C_WriteMeDataNext
    JMP     PreSetTxAck                     ; 发送TX_ACK后，进入 Step07_WriteMeDataNext（接收第2、3，。。数据，向我写数据）

Step07_WriteMeDataNext:
    MOV     A,@C_WriteByte    ;
	JMP     PreSetRcvByte

_Step03_DevAddr_R:
_Step03_DevAddr_R1:
	MOV     A,@8                            ; 操作为读命令，向主设备发送第一个数据
	MOV     CLKS,A
    MOV     A,DataPtr
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     Data,A                          ; 获得当前指针数据

    INC     DataPtr                         ; 数据指针向后移一个

    MOV     A,@0x30                         ; 153B RAM最大2F，大于2F，重置BUF
    SUB     A,DataPtr
    JBS     StatusReg,CarryFlag
    JMP     $+3
    MOV     A,@DataBuf                      ; 数据指针大于等于0X30，重新设定数据指针
    MOV     DataPtr,A

    MOV     A,@C_GetAck                     ;
    MOV     StepBak,A
    MOV     A,@C_TxByte
    MOV     I2CStep,A                       ; 发送当前数据后，进入Step14_GetAck
    JMP     IntPortEnd

Step14_GetAck:
    MOV     A,@C_ReadAck
    MOV     I2CStep,A                       ; 当前8位数据发送完成后，进入Step15_ReadAck （读RX_ACK）
    JMP     IntPortEnd
Step15_ReadAck:
    JBS     IntTemp,SlaverSCL
    JMP     IntPortEnd
    
	JBS		SystemFlag,SlaverSCL
	JMP		SDAInput                        ; SCL 为低电平，改变 SDA为输入
	JBC		SystemFlag,SlaverSDA            ; SCL 为高电平，
	JMP		Step16_ReadStop                 ; SDA 为高电平，则读到为 NO_ACK
    JMP     _Step03_DevAddr_R1              ; SDA 为低电平，则读到 RX_ACK ，准备发送下个数据

Step16_ReadStop:
    CLR     I2CStep
    JMP     IntPortEnd
;*****************************************
FirstClkInput:                              ; SCL 为变为低电平时
    JBS     CLKS,3
    JMP     IntPortEnd
SDAInput:
_SlaverSDA_1:
    MOV     A,@C_Slaver_BusIn               ; SCL, SDA 设置为输入
	IOW		I2CS_Port
    BS      SystemFlag,F_SDAInput
	JMP		IntPortEnd

_SlaverSDA_0:
    MOV     A,@C_Slaver_SCLi_SDAo           ; SCL 为输入， SDA 为输出
	IOW		I2CS_Port
	BC		I2CS_Port,SlaverSDA    
    BC      SystemFlag,F_SDAInput
    JMP     IntPortEnd

;*****************************************
Step_RcvByte:                               ; 接收一个字节过程
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化
    JMP     IntPortEnd
    
	JBS		SystemFlag,SlaverSCL
	JMP		FirstClkInput                   ; SCL为低电平，改变端口方向
    
	BC		StatusReg,CarryFlag             ; SCL为高电平，读入数据，保存在DATA中
	JBC		SystemFlag,SlaverSDA
	BS		StatusReg,CarryFlag             ; SCL为高电平，读入数据，保存在DATA中
	RLC		Data
	
	DJZ		CLKS
	JMP		IntPortEnd

    JMP     _ReturnStep
;*****************************************
Step_TxACK:                                 ; 发送 TX_ACK 过程
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化时
    JMP     IntPortEnd

	JBS		SystemFlag,SlaverSCL            ; 
	JMP		_SlaverSDA_0

_ReturnStep:   
    MOV     A,StepBak                       ; SCL为高电平时，返回操作
    MOV     I2CStep,A
    JMP     NextOpration
;*****************************************
Step_TxByte:                                ; 发送一个字节过程
    JBS     IntTemp,SlaverSCL               ; SCL发生变化时
    JMP     IntPortEnd

	JBC		SystemFlag,SlaverSCL
	JMP		Step_TxByte_DatEnd

	RLC		Data
    JBC     StatusReg,CarryFlag             ; 发送数据
    JMP     _SlaverSDA_1
    JMP     _SlaverSDA_0

Step_TxByte_DatEnd:
	DJZ		CLKS
	JMP		IntPortEnd    

    JMP     _ReturnStep                     ; 发送8位后返回操作
;***************************************** 
PreSetTxAck:
    MOV     StepBak,A
    MOV     A,@C_TxAck
    MOV     I2CStep,A
    JMP     IntPortEnd
;*****************************************    
PreSetRcvByte:
    MOV     StepBak,A

	MOV     A,@8
	MOV     CLKS,A
	CLR		Data

    MOV     A,@C_RcvByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;********************************************************

ifdef EnI2CMaster
    C_MinAddrBits   ==   2
    C_MaxAddrBits   ==   40
;检查设备地址位置正确， C=1
; 地址出错，C=0
ChkDevAddrBits:
    MOV     A,@C_MinAddrBits
    SUB     A,DevAddrByte
    JBS     StatusReg,CarryFlag
    RET

    MOV     A,DevAddrByte
    SUB     A,@C_MaxAddrBits
    RET

;简化设备地址，删除多余的0
SimpleDevAddr:
    CALL    ChkDevAddrBits
    JBC     StatusReg,CarryFlag
    JMP     $+3
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte,A

    RRCA    DevAddrByte
    MOV     PrgTmp1,A
    RRC     PrgTmp1
    RRCA    PrgTmp1

    AND     A,@7
    ADD     A,@DevAddrByte+1
    MOV     PrgTmp1,A

    MOV     A,DevAddrByte
    AND     A,@7    
    JBC     StatusReg,ZeroFlag
    DEC     PrgTmp1

    MOV     A,PrgTmp1
    MOV     RamSelReg,A
    SUB     A,@DevAddrByte+C_DevAddrBytes-1
    MOV     PrgTmp1,A

    MOV     A,DevAddrByte
    AND     A,@7
    CALL    DevAddrSame1
    AND     R0,A

    MOV     A,PrgTmp1
    JBC     StatusReg,ZeroFlag
    RET
    INC     RamSelReg
    CLR     R0
    DJZ     PrgTmp1
    JMP     $-3
    RET
endif

endm

M_RF24L01   macro             ; 2019.10.12
;*******************************************************************
; main 循环中增加以上，当中断产生时，读接收数据，并清除缓冲区，中断标志
;  当接收到数据时， SystemFlag.F_RfRxOk = 1
;  JBS     P_IRQ,B_IRQ          
;  CALL    nRF24L01_RxPacket
;*******************************************************************
; TX_BUF              equ     DataBuf   	 +   1  ; 发送缓冲
; RX_BUF              equ     DataBuf        +   1  ; 接收缓冲
;*******************************************************************
; ;RF24L01 发送端，接收端地址，此表格要放在开始位置
;   CALL    init_NRF24L01     ; 程序复位要初始化RF24L01
; 
; TX_ADDRESS:                 ; 本地地址
; RX_ADDRESS:                 ; 接收端地址
;     ADD     PC,A
;     RETL    @0x34
;     RETL    @0x43
;     RETL    @0x10
;     RETL    @0x10
;     RETL    @0x01
;*******************************************************************
; 以下是端口定义，要在PORTDEF.H中定义
; P_CE            equ     Port6       ; 输出至RF， RX/TX模式选择
; B_CE            equ     1
                                
; P_CSN           equ     Port6
; B_CSN           equ     2           ; 输出至RF, SPI EN信号
                                
; P_SCK           equ     Port6
; B_SCK           equ     0           ; 输出至RF, SPI CLK信号
                                
; PO_MOSI         equ     Port5
; BO_MOSI         equ     3           ; 输出至RF，向24L01输出数据
                                
; PI_MISO         equ     Port5
; BI_MISO         equ     2           ; 从RF读数据，
                                
; P_IRQ           equ     Port5       ; RF数据完成，产生中断
; B_IRQ           equ     1           


;//MARK: 常数
    TX_ADR_WIDTH   ==  5    ; 发送地址宽度
    TX_PLOAD_WIDTH ==  08   ; 发送数据字节数

    RX_ADR_WIDTH   ==  TX_ADR_WIDTH
    RX_PLOAD_WIDTH ==  TX_PLOAD_WIDTH    ;

;//MARK: nRF24L01-操作命令
; nRF24L01 收发数据部分
    READ_REG        ==  0x00
    WRITE_REG       ==  0x20
    RD_RX_PLOAD     ==  0x61    ; 读取接收数据指令
    WR_TX_PLOAD     ==  0xA0    ; 写待发数据指令
    FLUSH_TX        ==  0xE1    ; 冲洗发送 FIFO
    FLUSH_RX        ==  0xE2    ;     接收
    REUSE_TX_PL     ==  0xE3    ; 重复装载数据
    C_Nop           ==  0xFF
;//MARK: nRF24L01-寄存器
    CONFIG          ==  0x00    ; 配置收发状态，CRC,收发状态响应方式
    EN_AA           ==  0x01    ; 自动应答功能设置
    EN_RXADDR       ==  0x02    ; 可用信道
    SETUP_AW        ==  0x03    ; 地址宽度
    SETUP_RETR      ==  0x04    ; 自动重发
    RF_CH           ==  0x05    ; 工作频率
    RF_SETUP        ==  0x06    ; 发射速率，功耗
    STATUS          ==  0x07    ; 状态字
        RX_DR           ==  6
            ;接收数据中断。当接收到有效数据后置一。写‘1’清除中断。
        TX_DS           ==  5
            ;数据发送完成中断。当数据发送完成后产生中断。如果工作在自动应答模式下，只有当接收到应答信号后此位置一。写‘1’清除中断。
        MAX_RT          ==  4       
            ;达到最多次重发中断。写‘1’清除中断。如果MAX_RT 中断产生则必须清除后系统才能进行通讯。
    OBSERVE_TX      ==  0x08    ; 发送检测
    CD              ==  0x09    ; 地址检测
    RX_ADDR_P0      ==  0x0A    ; 频道0接收数据地址
    RX_ADDR_P1      ==  0x0B    ; 频道1接收数据地址
    RX_ADDR_P2      ==  0x0C    ; 频道2接收数据地址
    RX_ADDR_P3      ==  0x0D    ; 频道3接收数据地址
    RX_ADDR_P4      ==  0x0E    ; 频道4接收数据地址
    RX_ADDR_P5      ==  0x0F    ; 频道5接收数据地址
    TX_ADDR         ==  0x10    ; 发送地址寄存器
    RX_PW_P0        ==  0x11    ; 接收频道0接收数据长度
    RX_PW_P1        ==  0x12    ; 接收频道0接收数据长度
    RX_PW_P2        ==  0x13    ; 接收频道0接收数据长度
    RX_PW_P3        ==  0x14    ; 接收频道0接收数据长度
    RX_PW_P4        ==  0x15    ; 接收频道0接收数据长度
    RX_PW_P5        ==  0x16    ; 接收频道0接收数据长度
    FIFO_STATUS     ==  0x17    ; 

SPI_WRITEBYTE:
    MOV     PrgTmp3,A
    MOV     A,@8
    MOV     PrgTmp4,A           ; 8个时钟
;LOOP
    RLC     PrgTmp3             ; 数据高位在前

    JBC     StatusReg,CarryFlag             ; 数据建立
    BS      PO_MOSI,BO_MOSI
    JBS     StatusReg,CarryFlag
    BC      PO_MOSI,BO_MOSI

    BS      P_SCK,B_SCK
    BC      P_SCK,B_SCK
    DJZ     PrgTmp4
    JMP     $-8
    RET

SPI_READBYTE:
    MOV     A,@8
    MOV     PrgTmp4,A           ; 8个时钟
;LOOP
    BS      P_SCK,B_SCK

    BC      StatusReg,CarryFlag             ; 数据建立
    JBC     PI_MISO,BI_MISO
    BS      StatusReg,CarryFlag             ; 数据建立
    RLC     PrgTmp3

    BC      P_SCK,B_SCK

    DJZ     PrgTmp4
    JMP     $-7
    MOV     A,PrgTmp3
    RET

SPI_READSTATUS:
    BC      P_CSN,B_CSN
    CALL    SPI_READBYTE
    BS      P_CSN,B_CSN
    RET

;******************************************
;//NOTE: SPI_RW_Reg
; 将数据写到寄存器中
;   PrgTmp1 - [value]
;   [A] - [reg]
SPI_RW_Reg:
    BC      P_CSN,B_CSN
    CALL    SPI_WRITEBYTE

    MOV     A,PrgTmp1
    CALL    SPI_WRITEBYTE
    BS      P_CSN,B_CSN
    RET
;******************************************
;//NOTE: SPI_Read_Buf
;   RamSelReg  -  读出数据存储地址  
;   PrgTmp1 - 读数据个数
;   [A] - 要读寄存器地址
;
SPI_Read_Buf:
    BC      P_CSN,B_CSN

    CALL    SPI_WRITEBYTE

    CALL    SPI_READBYTE
    MOV     R0,A
    INC     RamSelReg
    DJZ     PrgTmp1
    JMP     $-4

    BS      P_CSN,B_CSN

    RET
;******************************************
;//NOTE:  SPI_Write_Buf
;   RamSelReg  -  写数据地址  
;   PrgTmp1 - 读数据个数
;   [A] - 要读寄存器地址
;
SPI_Write_Buf:
    BC      P_CSN,B_CSN

    CALL    SPI_WRITEBYTE

    MOV     A,R0
    CALL    SPI_WRITEBYTE
    INC     RamSelReg
    DJZ     PrgTmp1
    JMP     $-4

    BS      P_CSN,B_CSN

    RET
;******************************************
;//NOTE:  SPI_Write_Buf_Const
; 要写缓冲区常量，与C语言不同，需要专用函数, 取消返回值
; 
;   PrgTmp1 - 读数据个数
;   [A] - 要读寄存器地址
;
SPI_Write_Buf_Const:
    BC      P_CSN,B_CSN
    CLR     PrgTmp2

    CALL    SPI_WRITEBYTE
;LOOP
    MOV     A,PrgTmp2
    CALL    TX_ADDRESS                  ; 发送和接收使用同一个地址

    CALL    SPI_WRITEBYTE
    INC     PrgTmp2
    DJZ     PrgTmp1
    JMP     $-5

    BS      P_CSN,B_CSN
    RET
;******************************************
ClrBuffer:
    MOV     A,@RX_BUF
    MOV     RamSelReg,A
    MOV     A,@TX_PLOAD_WIDTH
    MOV     PrgTmp1,A

    CLR     R0
    INC     RamSelReg
    DJZ     PrgTmp1
    JMP     $-3
    RET
;******************************************
;//NOTE: nRF24L01_RxPacket
; 数据读取后,清除中断标志，进入RX模式
;  RamSelReg  
nRF24L01_RxPacket:
    JBC     P_IRQ,B_IRQ
    RET
    CALL    ClrBuffer

    CALL    SPI_READSTATUS          ; 读状态寄存器判断数据接收状况
    
    JBS     PrgTmp3,RX_DR           ; 是否接收到数据
    JMP     ClearRxDrInt

    BC      P_CE,B_CE               ; SPI,读SPI需要将 CE=0, 发射数据，CE = 1
    MOV     A,@RX_BUF
    MOV     RamSelReg,A
    MOV     A,@TX_PLOAD_WIDTH
    MOV     PrgTmp1,A
    MOV     A,@RD_RX_PLOAD
    CALL    SPI_Read_Buf            ; 从 RX_FIFO 读接收的数据
    BS      SystemFlag,F_RfRxOk     ; 接收数据成功
ClearRxDrInt:
    MOV     A,@(1<<MAX_RT) | (1<<RX_DR) | (1<<TX_DS)
    MOV     PrgTmp1,A
    BC      P_CE,B_CE
 
    MOV     A,@WRITE_REG+STATUS
    CALL    SPI_RW_Reg              ; 接收到数据后，RX_DR,TX_DS,MAX_PT都置1，通过写1清除中断标志

;//NOTE: SetRx_Mode
; 数据接收配置
;
SetRx_Mode:
    BC      P_CE,B_CE

    MOV     A,@0x0F
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+CONFIG
    CALL    SPI_RW_Reg              ; IRQ收发完成中断响应，16位CRC,主接收

    BC      P_CSN,B_CSN
    MOV     A,@FLUSH_RX
    CALL    SPI_WRITEBYTE           ; 清除接收缓冲区
    BS      P_CSN,B_CSN

    BS      P_CE,B_CE
    RET
    
; ;******************************************
;     MOV     A,@130
; ;******************************************
; ;//NOTE: inerDelay_us
; ; 延时函数，单位us,      测试结果：        [A]=100，  4M - 延时220US,   8M -延时110us
; ;  8M 频率， 指令周期 0.25us
; inerDelay_us:
;     MOV     PrgTmp1,A
    
;     NOP 
;     NOP 
;     DJZ     PrgTmp1
;     JMP     $-3
;     RET


;******************************************
;//NOTE: nRF24L01_TxPacket
; 发送 tx_buf 中的数据, 切换到发送模式，待10us
nRF24L01_TxPacket:
    BC      P_CE,B_CE                   ; Standby 模式

    BC      P_CSN,B_CSN
    MOV     A,@FLUSH_TX
    CALL    SPI_WRITEBYTE               ; 清除发送缓冲区
    BS      P_CSN,B_CSN

    MOV     A,@TX_BUF
    MOV     RamSelReg,A
    MOV     A,@TX_PLOAD_WIDTH
    MOV     PrgTmp1,A
    MOV     A,@WR_TX_PLOAD    
    CALL    SPI_Write_Buf               ;//装载数据

    MOV     A,@0x0E                     ; 设置发射模式
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+CONFIG
    CALL    SPI_RW_Reg

    BS      P_CE,B_CE                   ; 置高CE,激发数据发送
    RET
;******************************************
;//TODO: init_NRF24L01
init_NRF24L01:
    BC      P_CE,B_CE                   ; 片选
    BS      P_CSN,B_CSN                 ; SPI 禁止
    BC      P_SCK,B_SCK

    MOV     A,@TX_ADR_WIDTH
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+TX_ADDR
    CALL    SPI_Write_Buf_Const         ; 写本地地址

    MOV     A,@RX_ADR_WIDTH
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+RX_ADDR_P0
    CALL    SPI_Write_Buf_Const         ; 写接收端地址

    MOV     A,@0x01
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+EN_AA          ; 频道0自动 ACK 应答允许
    CALL    SPI_RW_Reg

    MOV     A,@0x01
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+EN_RXADDR      ; 允许接收地址只有频道0，如果需要多频道可以参考page21    
    CALL    SPI_RW_Reg

    MOV     A,@0x00
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+RF_CH          ; 设置信道工作为2.4Ghz,收发必须一致
    CALL    SPI_RW_Reg

    MOV     A,@RX_PLOAD_WIDTH
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+RX_PW_P0       ; 设置接收数据长度，本次设置32字节
    CALL    SPI_RW_Reg

    MOV     A,@0x07
    MOV     PrgTmp1,A
    MOV     A,@WRITE_REG+RF_SETUP       ; 设置发射速率为1MHZ，发射功率为最大0dB
    CALL    SPI_RW_Reg



    JMP     ClearRxDrInt



endm


M_I2CMaster201911  macro
;**********************************************************
;    M_I2CMaster201911           ; I2C 主控程序
;**********************************************************
/*
 2019.11.6 更新，I2C Slaver , Master,支持7bit,10bit地址格式
    06-写设备地址， 07-读设备地址

    TM1650 不是标准I2C设备，单独使用总线P67,P66
    其它I2C设备，EPROM,旋转按扭，共用总线

    增加总线忙闲检测
    使用注意：  SCL, SDA 在同一个PORT上，  P62,P61

    TM1650 特点：
	    地址  48H     --         显示开关控制   
		              48H XXH   显示控制
					      XX :  B6-4 8级亮度，  B3 - 8/7段控制 ， B0 - 关/开 显示
					  68H XX    COM1 数据
					      XX :  S7,S6,S5,S4,S3,S2,S1,S0 段码值
				      6AH XX    COM2 数据
					  6CH XX    COM3 数据
					  6EH XX    COM4 数据
					  49H 读按键值(占用4个地址)
					  4BH ....
					  4DH ....
					  4FH ....
	TM1650 一个设备地址，只有一个RAM，采用立即读写方式
	EPROM  - 24C02,占用 A0-AF
	                  A0H 写
					  A1H 读
	                  A2H 写
					  A3H 读
	                  A4H 写
					  A5H 读
	                  A6H 写
					  A7H 读
	                  A8H 写
					  A9H 读
	                  AAH 写
					  ABH 读
	                  ACH 写
					  ADH 读
	                  AEH 写
					  AFH 读

    I2C 旋转按扭 占用 98H, 99H 两个地址				  
*/

ifdef EnTm1650Disp

DIG_0	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_g)
DIG_1	equ	 (SEG_a+SEG_b)
DIG_2	equ	 (SEG_b+SEG_c+SEG_e+SEG_f+SEG_g)
DIG_3	equ	 (SEG_a+SEG_b+SEG_c+SEG_f+SEG_g)
DIG_4	equ	 (SEG_a+SEG_b+SEG_d+SEG_f)
DIG_5	equ	 (SEG_a+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_6	equ	 (SEG_a+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_7	equ	 (SEG_a+SEG_b+SEG_c)
DIG_9	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_f+SEG_g)
DIG_8	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)

DIG_G	equ	 SEG_f
DIG_A	equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e+SEG_f)
DIG_B	equ	 (SEG_a+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_H	equ	 (SEG_a+SEG_b+SEG_d+SEG_e+SEG_f)
DIG_H1	equ	 (SEG_a+SEG_d+SEG_e+SEG_f)
DIG_COLON equ (SEG_b+SEG_c)
DIG_E	equ	 (SEG_c+SEG_d+SEG_e+SEG_f+SEG_g)
DIG_N   equ	 (SEG_a+SEG_b+SEG_c+SEG_d+SEG_e)
DIG_C   equ	 (SEG_e+SEG_f+SEG_g)
DIG_D   equ	 (SEG_a+SEG_b+SEG_e+SEG_f+SEG_g)
DIG_F	equ	 (SEG_c+SEG_d+SEG_e+SEG_f)
DIG_I   equ  (SEG_a+SEG_b)
DIG_L   equ  (SEG_d+SEG_e+SEG_g)
DIG_O	equ  (SEG_a+SEG_e+SEG_f+SEG_g)

;以下是程序

    C_TMSCL_Mask   ==   1<<TMB_SCL
    C_TMSDA_Mask   ==   1<<TMB_SDA

    C_TmSCLo_SDAo  ==   C_ExtTmMask
    C_TmSCLo_SDAi  ==   C_ExtTmMask     +   C_TMSDA_Mask
    C_TmSCLi_SDAo  ==   C_ExtTmMask     +   C_TMSCL_Mask
    C_TmSCLi_SDAi  ==   C_ExtTmMask     +   C_TMSCL_Mask    +   C_TMSDA_Mask

;********************************************************************
TM_Start:
    MOV     A,@C_TmSCLi_SDAo
    IOW     TMP_SDA
	BC      TMP_SDA,TMB_SDA
	RET	
;********************************************************************
TM_WriteCommand:
	MOV     Prgtmp3,A
	MOV     A,@8
	MOV     Prgtmp4,A

_TM_Loop:
	MOV     A,@C_TmSCLo_SDAo
	IOW     TMP_SDA	
	BC      TMP_SCL,TMB_SCL

	JBS     Prgtmp3,7
	BC      TMP_SDA,TMB_SDA
	JBC     Prgtmp3,7
	BS      TMP_SDA,TMB_SDA

	MOV     A,@C_TmSCLi_SDAo
	IOW     TMP_SDA

	RLC     Prgtmp3
	DJZ     Prgtmp4
	JMP     _TM_Loop
	RET
;********************************************************************
TM_GetAck:
TM_Get1Bit:
	MOV     A,@C_TmSCLo_SDAi
	IOW     TMP_SDA	
	BC      TMP_SCL,TMB_SCL

	MOV     A,@C_TmSCLi_SDAi
	IOW     TMP_SDA	
	RET
;********************************************************************
;********************************************************************
TM1650_WriteCom1:			
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM1
	JMP     TM1650_ON+4

TM1650_WriteCom2:
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM2
	JMP     TM1650_ON+4

TM1650_WriteCom3:
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM3
	JMP     TM1650_ON+4

TM1650_WriteCom4:
	MOV     PrgTmp1,A
    CALL    TM_Start
	MOV     A,@C_TM1650_COM4
	JMP     TM1650_ON+4

;********************************************************************
TM1650_OFF:
	MOV     A,@0x20
    JMP     $+2
TM1650_ON:
    MOV     A,@0X31
    MOV     PrgTmp1,A

	CALL	TM_Start
    MOV     A,@0x48
	CALL	TM_WriteCommand
	CALL	TM_GetAck

	MOV     A,PrgTmp1
	CALL	TM_WriteCommand
	CALL	TM_GetAck

TM_Stop:   
	MOV     A,@C_TmSCLo_SDAo
	IOW     TMP_SDA	
	BC      TMP_SCL,TMB_SCL
	BC      TMP_SDA,TMB_SDA

	MOV     A,@C_TmSCLi_SDAo
	IOW     TMP_SDA	

	MOV     A,@C_TmSCLi_SDAi
	IOW     TMP_SDA	
	RET
endif
;********************************************************************

;********************************************************************
ifdef EnTm1650Key
TM_ReadByte:
	CLR     Prgtmp3
	MOV     A,@8
	MOV     Prgtmp4,A

	CALL	TM_Get1Bit
	
    BC      StatusReg,CarryFlag
    JBC     TMP_SDA,TMB_SDA
    BS      StatusReg,CarryFlag
    RLC     Prgtmp3

    DJZ     Prgtmp4
    JMP     $-6
    RET

; 键值读到 Prgtmp3 中
TM1650_ReadKeyValue:		
	CALL	TM_Start
	MOV     A,@0x49
	CALL	TM_WriteCommand
	CALL	TM_GetAck
	CALL	TM_ReadByte
    JMP     TM_Stop
endif
;********************************************************************
ifdef EnI2CMaster
C_I2CSclIn_SdaOut   equ     C_I2CBusOut    +  (1<<B_SCL)
C_I2CSclOut_SdaIn   equ     C_I2CBusOut    +  (1<<B_SDA) 
C_I2CBusIn          equ     C_I2CBusOut    +  (1<<B_SCL) + (1<<B_SDA)



_E2ErrorNoAck:
_ErrorBusBusy:
	MOV		A,@0xEF
	RET

;//NOTE: I2C_BUSo0
I2C_BUSo0:                              ; SCL 输出0， SDA 输出0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy
	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	BC      P_SCL,B_SCL
	BC      P_SDA,B_SDA
    RET
;//NOTE: I2C_BUSo
I2C_BUSo:                               ; SCL 输出端口，SDA输出端口
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy

	MOV     A,@C_I2CBusOut
	IOW     P_SDA
	RET
;**************************修改代码**2018.07.12*******************************
; 开始前， SCL,SDA 总线释放状态
;//NOTE:   I2C_Start   
;              SDA,SCL要有上拉电阻
I2C_Start:
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy
    
;//NOTE:I2C_SCLi_SDAo0
I2C_SCLi_SDAo0:
	MOV     A,@C_I2CSclIn_SdaOut        ; SCL =1 ,SDA 1->0
	IOW     P_SDA
	BC      P_SDA,B_SDA
    RET
;//NOTE:I2C_SCLi_SDAo
I2C_SCLi_SDAo:
	MOV     A,@C_I2CSclIn_SdaOut        ; SCL =1 ,SDA 1->0
	IOW     P_SDA
	RET
;//NOTE:I2C_SCLo_SDAo
I2C_SCLo_SDAo:                          ; SCL 只能输出为0
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy   
	MOV     A,@C_I2CBusOut              ; 占用总线输出数据
	IOW     P_SDA
    BC      P_SCL,B_SCL
	RET
	

;*************************************************
;//NOTE:  I2C_SendAck
I2C_SendAck:
	CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    JMP     I2C_SCLi_SDAo               ; SCL=1, SDA=0
;*************************************************	
; 命令字放在A中  , EPROM 传输一个命令字
;          __      ____
;   SCL      |____|
;         ____    _____ 
;   SDA   ____XXXX_____
;//NOTE:  I2C_WriteCommand
I2C_WriteCommand:
	MOV		Prgtmp3,A			; 保存数据
	MOV		A,@8
	MOV		Prgtmp4,A

_I2CWriteCommandLoop:
	CALL    I2C_SCLo_SDAo

	JBS		Prgtmp3,7           ; 设置 SDA
	BC		P_SDA,B_SDA
	JBC		Prgtmp3,7
	BS		P_SDA,B_SDA	;

	CALL    I2C_SCLi_SDAo	    ; SCL=1

	RLC		Prgtmp3
	DJZ		Prgtmp4
	JMP		_I2CWriteCommandLoop

;	RET	
;*****************************************************
;//NOTE: I2C_GetAck
I2C_Get1Bit:
I2C_SendNoAck:
I2C_GetAck:
	JBS     P_SCL,B_SCL
	JMP     _ErrorBusBusy

	MOV     A,@C_I2CSclOut_SdaIn
	IOW     P_SCL
	BC      P_SCL,B_SCL

;//NOTE:I2C_BusIn
I2C_BusIn:
	MOV     A,@C_I2CBusIn
	IOW     P_SCL
	RET
	

;******************************************************
;读一个字节,  
;//TODO:  I2C_ReadByte
I2C_ReadByte:					; 退出时， SCL = 0
	CLR   	Prgtmp3
	MOV		A,@8
	MOV		Prgtmp4,A
_I2C_ReadByteLoop:				; 循环中，SCL 周期 = 11 ， 约 11*0.56= 6.2us = 160K 速度
    CALL    I2C_Get1Bit

	BC		StatusReg,CarryFlag
	JBC		P_SDA,B_SDA
	BS		StatusReg,CarryFlag
	RLC		Prgtmp3

	DJZ		Prgtmp4
	JMP		_I2C_ReadByteLoop

	MOV		A,Prgtmp3			; 读出的数据放在A中	
	RET

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   PrgTmp5   设备地址      ，  B0 - 0 写数据， B0-1 读数据
;   Prgtmp1,写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:    I2C_ReadPageData
I2C_ReadPageData:
    BC      PrgTmp5,0               ; 如果设备地址未位为1，则校正为0

	CALL	I2C_Start
	MOV		A,PrgTmp5
	CALL	I2C_WriteCommand
	JBC     P_SDA,B_SDA		
	JMP		_E2ErrorNoAck

    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag
    JMP     _I2C_ReadPage_ByteAddr

	MOV		A,PrgTmp6               ; 10位地址 后面一个字节
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_ReadPage_ByteAddr:
	MOV		A,Prgtmp2
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck
;********************************************************************    
    CALL    I2C_GetAck                  ; 占用总线，释放总线
; 此处必须增加一个时钟，前一个读ACK结束时，从设备输出0，表示收到，增加这一个时钟
; 通知从设备已经读到了ACK，可以释放总线了。如果从设备不释放总线，下面一个开始
; 将会出错
;********************************************************************    
	CALL	I2C_Start
	INCA    PrgTmp5
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    JMP     $+2
_I2CReadPageLoop:
	CALL	I2C_SendAck

	CALL	I2C_ReadByte
	MOV		R0,A
	INC		RamSelReg

	DJZ		Prgtmp1
	JMP		_I2CReadPageLoop

;*************************************************
;  发送完成 NOACK 接着发送 STOP 指令
    CALL    I2C_SendNoAck
;//mark:   I2C_Stop
I2C_Stop:
    CALL    I2C_BUSo0                   ; SCL=0, SDA=0
    CALL    I2C_SCLi_SDAo               ; SCL=1, SDA=0
    JMP     I2C_BusIn                   ; SCL=1, SDA=1

;*************************************************	
;   RamSelReg, 当前写的数据存放位置
;   PrgTmp5，PrgTmp6   设备地址  7位，10位    ，  B0 - 0 写数据， B0-1 读数据
;   Prgtmp1,  写的字节数
;   Prgtmp2,  EPROM 地址，单字节
;//TODO:I2C_WritePageData
I2C_WritePageData:
    BC      PrgTmp5,0               ; 如果设备地址未位为1，则校正为0

	CALL	I2C_Start
	MOV		A,PrgTmp5               ; 写EPROM 设备地址
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

    MOV     A,PrgTmp5
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag
    JMP     _I2C_WritePage_ByteAddr

	MOV		A,PrgTmp6               ; 10位地址 后面一个字节
	CALL	I2C_WriteCommand    	; 设备地址,使用tmp3,tmp4
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_WritePage_ByteAddr:
	MOV		A,Prgtmp2
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

_I2C_WritePageLoop:
	MOV		A,R0
	CALL	I2C_WriteCommand
	JBC		P_SDA,B_SDA
	JMP		_E2ErrorNoAck

	INC		RamSelReg
	DJZ		Prgtmp1
	JMP		_I2C_WritePageLoop	

	JMP		I2C_Stop                ; 优化代码
endif
endm

M_I2CSlaver201911  macro
;**********************************************************
;    M_I2CSlaver201911           ; I2C 主控程序
;**********************************************************
;  2019.11.6 更新，I2C Slaver , Master,支持7bit,10bit地址格式
;     06-写设备地址， 07-读设备地址
;*****************************************
;使用 I2C Slaver 且注意：
;   由于存在 列表，需要将 宏放在程序开始位置
;   将 IntPortEnd 放在 main开始
;*****************************************
    I2CSMask		equ     (1<<SlaverSCL) + (1<<SlaverSDA) 

C_Slaver_SCLi_SDAo  equ     C_SlaverBusOut  + (1<<SlaverSCL)
C_Slaver_SCLo_SDAi  equ     C_SlaverBusOut  + (1<<SlaverSDA)
C_Slaver_BusIn      equ     C_SlaverBusOut  + I2CSMask

            C_ChkDevAddr               ==   1      
            C_GetBroad1Byte            ==   C_ChkDevAddr         +  1      
            C_ChkAddrByte2             ==   C_GetBroad1Byte      +  1      
            C_GetByteAddr              ==   C_ChkAddrByte2       +  1      
            C_WriteByte                ==   C_GetByteAddr        +  1      
            C_PreTxByte                ==   C_WriteByte          +  1      
            C_TxByte                   ==   C_PreTxByte          +  1      
            C_ReadAck                  ==   C_TxByte             +  1      
            C_TxAckRcvByte             ==   C_ReadAck            +  1      
            C_RcvByte                  ==   C_TxAckRcvByte       +  1      
            C_TxACK                    ==   C_RcvByte            +  1      


;//todo: IntPort                               ;此为查询方式处理。I2C 协议，避免 maskter设备速度过快有些中断漏掉
IntPort:
	MOV		A,I2CS_Port
	XOR		A,SystemFlag
	AND		A,@I2CSMask
	MOV		IntTemp,A                        ; IntTemp为 端口当前检测到的变化位
	XOR		SystemFlag,A                     ; SystemFlag 为端口当前值
 
    JBS     SystemFlag,F_SDAInput
    JMP     ChkStartEnd 

    JBS     SystemFlag,SlaverSCL            ; 在 SCL 高电平时
    JMP     ChkStartEnd    

	JBS		IntTemp,SlaverSDA               ; SDA 变化了
	JMP		ChkStartEnd
	
	JBS		SystemFlag,SlaverSDA
    JMP     _Step_RcvDevAddr                ; SDA 由高变低为 START,  GetStart:
    JMP     _Step_GetStop

ChkStartEnd:
NextOpration:
;//mark: 命令表
    MOV     A,I2CStep
    ADD     PC,A
    JMP     IntPortEnd                      ; 等待接收 START ，或 STOP 空闲操作，只用于接收 START,STOP
    JMP     Step_ChkDevAddr                 ;  
    JMP     Step_GetBroad1Byte              ; 广播地址后第一字节， 01
    JMP     Step_ChkAddrByte2               ; 10B 地址，第2字节
    JMP     Step_GetByteAddr                ;  
    JMP     Step_WriteByte                  ;  
    JMP     Step_PreTxByte                  ;  
    JMP     Step_TxByte                     ;  
    JMP     Step_ReadAck                    ;    
    JMP     Step_TxAckRcvByte               ;  
    JMP     Step_RcvByte                    ;  
    JMP     Step_TxACK                      ;  



;*****************************************************************************************    
_Step_RcvDevAddr:                          ; 接收到 START 后进行的操作
    MOV     A,@C_ChkDevAddr
    MOV     StepBak,A

	MOV     A,@8
	MOV     CLKS,A

    MOV     A,@C_RcvByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;*****************************************************************************************    
Step_ChkDevAddr:                          ; 当前接收到的字节为 设备地址ADDR
    MOV     A,Data
    AND     A,@0xFE
    XOR     A,@0x06
    JBS     StatusReg,ZeroFlag
    JMP     _Step_Chk10BitAddr 


; 接收到对设备地址操作，
    JBC     Data,0
    JMP     _Step_DevAddrOk
;*****************************************************************************************    
;            通过广播地址写设备地址， 00 - 01 - 【A1】【A2】
    BS      SystemFlag,F_WDevAddr           ; 相比 Slaver程序，只是这里做了 **修改2**
    MOV     A,@C_GetBroad1Byte              ; 设备地址为 00，广播地址
PreSetTxAckRcvByte:
    MOV     StepBak,A
    MOV     A,@C_TxAckRcvByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;********************************************************
Step_GetBroad1Byte:
    MOV     A,@DevAddrByte
    MOV     DataPtr,A
    JMP     _Step_PreWriteByte

;*****************************************************************************************    
_Step_Chk10BitAddr:
    MOV     A,Data
    AND     A,@0xFE
    XOR     A,DevAddrByte                   ; 接收到第一个设备地址字节
    JBS     StatusReg,ZeroFlag
    JMP     Error_DevAddrDiff

    MOV     A,Data                          ; 高7位地址是相 同的
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag              ; 检查高5位是不是 F0
    JMP     _Step_7BitAddr                  ; 是7位地址 ,则进入接收内部地址

    JBS     Data,0                          ; 第一个设备地址高5位是 F0
    JMP     $+4
    JBS     SystemFlag,F_AddrMarried        ; 第一个设备地址 是10位，且最低位是1-读
    JMP     Error_DevAddrDiff               ; 接收到10位地址，并不是自己的，
    JMP     _Step_DevAddrOk                 ; 10位地址已经校验，需要读数据

    MOV     A,@C_ChkAddrByte2               ; 进入接收10位地址 第二个字节
    JMP     PreSetTxAckRcvByte

Step_ChkAddrByte2:                        ; 检测10bit地址第2个字节
    MOV     A,Data
    XOR     A,DevAddrByte+1
    JBS     StatusReg,ZeroFlag
    JMP     Error_DevAddrDiff

    BS      SystemFlag,F_AddrMarried        ; 检测到设备地址 是10位地址，相同
    JMP     _Step_WriteByteAddr

_Step_7BitAddr:                             ; 接收到地址是7bit地址
    JBC     Data,0
    JMP     _Step_DevAddrOk                 ; 读操作 ，7bit地址，读我操作
_Step_WriteByteAddr:
    MOV     A,@C_GetByteAddr                ; 向我写数据
    JMP     PreSetTxAckRcvByte

;*****************************************************************************************    
Step_GetByteAddr:                           ; 接收到的是RAM地址
    MOV     A,Data 
    ADD     A,@DataBuf
    MOV     DataPtr,A                       ; 设定数据指针
_Step_PreWriteByte:
    MOV     A,@C_WriteByte                  ; 
	JMP     PreSetTxAckRcvByte              ; 接收到一个字节后，进入 Step06_WriteByte （向我写一个数据）
	
Step_WriteByte:                             ; 当前进入写数据操作
    MOV     A,DataPtr
    MOV     RamSelReg,A                     ; 置数据指针
    MOV     A,Data
    MOV     R0,A                            ; 保存数据

    CALL    ChkDataPtrOverflow
    JMP     _Step_PreWriteByte
;*****************************************************************************************    
_Step_DevAddrOk:            ;设备地址正确，从我读数据
    MOV     A,@C_PreTxByte
    MOV     StepBak,A
    MOV     A,@C_TxAck
    MOV     I2CStep,A
    JMP     IntPortEnd

Step_PreTxByte:
	MOV     A,@8                            ; 操作为读命令，向主设备发送第一个数据
	MOV     CLKS,A
    MOV     A,DataPtr
    MOV     RamSelReg,A
    MOV     A,R0
    MOV     Data,A                          ; 获得当前指针数据

    CALL    ChkDataPtrOverflow

    MOV     A,@C_TxByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;*****************************************
Step_TxByte:                                ; 发送一个字节过程
    JBS     IntTemp,SlaverSCL               ; SCL发生变化时
    JMP     IntPortEnd

	JBC		SystemFlag,SlaverSCL
	JMP		_Step_TxByte_DatEnd

	RLC		Data
    JBC     StatusReg,CarryFlag             ; 发送数据
    JMP     _SlaverSDA_1
    JMP     _SlaverSDA_0

_Step_TxByte_DatEnd:
	DJZ		CLKS
	JMP		IntPortEnd    
    INC     I2CStep
    JMP     IntPortEnd    
;*****************************************
Step_ReadAck:
    JBS     IntTemp,SlaverSCL
    JMP     IntPortEnd
    
	JBS		SystemFlag,SlaverSCL
	JMP		SDAInput                        ; SCL 为低电平，改变 SDA为输入
	JBC		SystemFlag,SlaverSDA            ; SCL 为高电平，
	JMP		_Step_GetNoAck                  ; SDA 为高电平，则读到为 NO_ACK
    JMP     Step_PreTxByte                  ; SDA 为低电平，则读到 RX_ACK ，准备发送下个数据

;*****************************************
Step_TxAckRcvByte:
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化时
    JMP     IntPortEnd

	JBS		SystemFlag,SlaverSCL            ; 
	JMP		_SlaverSDA_0                    ; 发送ACK

    INC     I2CStep
	MOV     A,@8
	MOV     CLKS,A
    JMP     IntPortEnd

Step_RcvByte:                               ; 接收一个字节过程
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化
    JMP     IntPortEnd
    
	JBS		SystemFlag,SlaverSCL
	JMP		FirstClkInput                   ; SCL为低电平，改变端口方向
    
	BC		StatusReg,CarryFlag             ; SCL为高电平，读入数据，保存在DATA中
	JBC		SystemFlag,SlaverSDA
	BS		StatusReg,CarryFlag             ; SCL为高电平，读入数据，保存在DATA中
	RLC		Data
	
	DJZ		CLKS
	JMP		IntPortEnd

    JMP     _ReturnStep
;*****************************************
Step_TxACK:                                 ; 发送 TX_ACK 过程
    JBS     IntTemp,SlaverSCL               ; SCL 发生变化时
    JMP     IntPortEnd

	JBS		SystemFlag,SlaverSCL            ; 
	JMP		_SlaverSDA_0

_ReturnStep:   
    MOV     A,StepBak                       ; SCL为高电平时，返回操作
    MOV     I2CStep,A
    JMP     NextOpration
;***************************************** 
ChkDevAddrError:
    JBC     DevAddrByte,0
    BC      DevAddrByte,0

    MOV     A,DevAddrByte
    AND     A,@0xF0
    JBC     StatusReg,ZeroFlag
    JMP     _DevAddrError                   ; 高4位为0，则为保留地址，不允许

    COMA    DevAddrByte
    AND     A,@0xF8
    JBC     StatusReg,ZeroFlag
    JMP     _DevAddrError                   ; 高5位 = F8，保留地址
    BC      StatusReg,CarryFlag
    RET    

_DevAddrError:
    BS      StatusReg,CarryFlag
    RET    


ChkDataPtrOverflow:                         ; 地址加1 ，检测地址溢出
    INC     DataPtr                         ; 数据指针向后移一个

    MOV     A,@DataBufEnd+1                 ; 153B RAM最大2F，大于2F，重置BUF
    SUB     A,DataPtr
    MOV     A,@DataBuf                      ; 数据指针大于等于0X30，重新设定数据指针
    JBC     StatusReg,CarryFlag
    MOV     DataPtr,A
    RET
;*****************************************
FirstClkInput:                              ; SCL 为变为低电平时
    JBS     CLKS,3
    JMP     IntPortEnd
SDAInput:
_SlaverSDA_1:
    MOV     A,@C_Slaver_BusIn               ; SCL, SDA 设置为输入
	IOW		I2CS_Port
    BS      SystemFlag,F_SDAInput
	JMP		IntPortEnd

_SlaverSDA_0:
    MOV     A,@C_Slaver_SCLi_SDAo           ; SCL 为输入， SDA 为输出
	IOW		I2CS_Port
	BC		I2CS_Port,SlaverSDA    
    BC      SystemFlag,F_SDAInput
    JMP     IntPortEnd
;*****************************************
_Step_GetStop:                              ; SDA 由低变高为 STOP
    BS      SystemFlag,F_DataValid          ; 接收到STOP ，处理这一组数据
_Step_GetNoAck:                             ; 读我结束
Error_DevAddrDiff:      
    CLR     I2CStep
    BC      SystemFlag,F_AddrMarried        ; 10位地址匹配取消
    JMP     _SlaverSDA_1
;*****************************************
endm