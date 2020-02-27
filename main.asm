
include "defmcu.h"
include	"option.h"
include "public.h"
include	"PortDef.h"
include "macro.h"
include	"RamDef.h"
include	"ConstDef.h"
include	"Mini4X8LED.H"
;****************************************************************

/*       
   chksum:    Relay4Board
0�� 5A0B  - 0  - ʹ�õ��̵���ģ�飬EPROMѡ��ַ���޾��� ,С�̵�����HF49FD����̵���, SRD-05VDC-SL-C
1�� 73D2  - 1    ʹ��4�̵���ģ�飬 EPROMѡ��ַ�������� , �ϰ汾PCB -2018
2�� 73D4  - 2  - ʹ��4�̵���ģ�飬 EPROMѡ��ַ�������� ���°汾PCB -2019
3�� C113  - 3  - ʹ�õ��̵���ģ�飬IO�˿�ѡ��ַ���޾���, SOP14 
4�� 4D52  - 4  - ʹ�õ��̵���ģ�飬IO�˿�ѡ��ַ���޾���, SOP8  

5�� 588A  - 0    ʹ�õ��̵���ģ�飬EPROMѡ��ַ���޾��� ,��̵���,    PCB�汾 2019.05.10 SlaverSDA/SlaverSCL��λ����    

	OTP ѡ�
	Target Power    	:    Using ICE
	RCOUT				:    P64
	Setup Time  		:    18ms
	OSC  				:    IRC
	CLKS   				:    2Clocks
	ENWDT				:    Disable 
	ResetEN  			:    Disable 
*/


;//todo: ��ʼ
	ORG  	0x00
	JMP 	McuRst  ; 0
	NOP
	NOP
	NOP                                                                                                                                                    
	NOP
	NOP
	NOP
	NOP
    ORG     0x08
	reti
DefaultContrast:
	RETL	@3
DefaultDevAddr:
GroupID:                        ; Ĭ�� OPT3 ��ʼֵ
    RETL    @0xB0             ; 12λ
    RETL    @0xFF
    ; RETL    @0xF0   + (1<<1)    ; 10λ��ַ��ʽ�� ��2λ
    ; RETL    @0x38               ; 10λ��ַ��ʽ�� ��8λ
 

_KeyBitMask:
    ADD     PC,A
    RETL    @1<<B_Key1
    RETL    @1<<B_Key2
    RETL    @1<<B_Key3
    RETL    @1<<B_Key4
    RETL    @1<<B_Key5

;*****************************************
;//todo: main
IntPortEnd:
main:
	WDTC
    CALL    SoftTimer
	JBS		SystemFlag,F_DataValid
	JMP		IntPort
	
	BC		SystemFlag,F_DataValid               ; I2C���߽��յ� �̵���״̬�ı����������
    JBC     SystemFlag,F_WDevAddr
    CALL    UpdatDevAddr

    C_CtrlMask    ==   0x01
    
	MOV     A,CtrlByte
    CLR     CtrlByte
    AND     A,@C_CtrlMask
    ADD     PC,A
    JMP     main                                ; 0
    JMP     RelayAction                         ; 1
    
    M_I2CSlaver201911

;//todo: McuRst
McuRst:
	DISI
	ClrRam

	InitPort20181204
    DISI

	MOV     A,I2CS_Port
	AND		A,@I2CSMask
	MOV		SystemFlag,A            			;�𶯺����ȶ� I2C �˿����ݣ���ʼ��
    BS      SystemFlag,F_SDAInput
    MOV     A,@0xA0
    MOV     PrgTmp5,A
    MOV     A,@0xFF
    MOV     PrgTmp6,A

if  0
    I2CWaitTime ==  0x20

    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A

    MOV     A,@0xF2
    MOV     PrgTmp5,A
    MOV     A,@0x39
    MOV     PrgTmp6,A

    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@1
    MOV     Prgtmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    CALL    I2C_WritePageData

 
    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@1
    MOV     Prgtmp2,A
    MOV     A,@0x20
    MOV     RamSelReg,A
    CALL    I2C_ReadPageData
    JMP     $
endif

if  Relay4Board<3
    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@C_E2Addr_DevAddr
    MOV     PrgTmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    CALL    I2C_ReadPageData                      ; ���EPROM�Ƿ������ݣ����EPROM��ַ��ȷ��ʹ��EPROM�������OPT�˿�

    CALL    ChkDevAddrError
    JBS     StatusReg,CarryFlag
    JMP     main
_EpromError:
    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A
endif

if Relay4Board == 3                                          ; 153B  SOP14 ��װ
    CLR     DevAddrByte
    JBC     Port6,2
    BS      DevAddrByte,1

    JBC     Port6,3
    BS      DevAddrByte,2

    JBC     Port6,4
    BS      DevAddrByte,3

    JBC     Port6,5
    BS      DevAddrByte,4

    JBC     Port6,6
    BS      DevAddrByte,5

    JBC     Port6,7
    BS      DevAddrByte,6

    JBC     Port5,0
    BS      DevAddrByte,7

endif

if Relay4Board == 4                        
	CALL	GroupID
	MOV	    DevAddrByte,A

    JBC     Port6,2
    BS      DevAddrByte,1

    JBC     Port6,3
    BS      DevAddrByte,2

    JBC     Port6,4
    BS      DevAddrByte,3   
endif
    JMP     main


RelayAction:
	JBC		RelayStatus,F_RlyOn
	BS		Relay1Port,Relay_B1
	JBS		RelayStatus,F_RlyOn
	BC		Relay1Port,Relay_B1
if (Relay4Board==1) ||(Relay4Board==2)
	JBC		RelayStatus,F_RlyOn1
	BS		Relay2Port,Relay_B2
	JBS		RelayStatus,F_RlyOn1
	BC		Relay2Port,Relay_B2

	JBC		RelayStatus,F_RlyOn2
	BS		Relay3Port,Relay_B3
	JBS		RelayStatus,F_RlyOn2
	BC		Relay3Port,Relay_B3

	JBC		RelayStatus,F_RlyOn3
	BS		Relay4Port,Relay_B4
	JBS		RelayStatus,F_RlyOn3
	BC		Relay4Port,Relay_B4
endif
    JMP     main


;***************************************** 
; ���豸ͨ��06,07��ַ�޸����豸��ַ����Ҫ������EPROM��
UpdatDevAddr:
if  Relay4Board<3
    BC      SystemFlag,F_WDevAddr
    CLR     CtrlByte
    MOV     A,@DevAddrByte+1
    SUB     A,DataPtr
    JBS     StatusReg,CarryFlag
    RET

    MOV     A,@0xA0
    MOV     PrgTmp5,A
    MOV     A,@0xFF
    MOV     PrgTmp6,A

    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@C_E2Addr_DevAddr
    MOV     PrgTmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    JMP     I2C_WritePageData      ; ����
else
    RET
endif
;***************************************** 

    M_I2CMaster201911



;//TODO: SoftTimer
SoftTimer:
    MOV     A,TCC
    XOR     A,TRFlagReg
    AND     A,@1<<F_16ms
    JBC     StatusReg,ZeroFlag
    RET
    XOR     TRFlagReg,A

    INC     Cnt16ms

    MOV     A,Cnt16ms
    XOR     A,Cnt16msBak
    AND     A,@1<<(IRC8M+1)
    JBS     StatusReg,ZeroFlag
    JMP     _Timer32ms

    MOV     A,Cnt16ms
    XOR     A,Cnt16msBak
    AND     A,@1<<(IRC8M+3)
    JBS     StatusReg,ZeroFlag
    JMP     _Timer250ms

    MOV     A,Cnt16ms
    XOR     A,Cnt16msBak
    AND     A,@1<<(IRC8M+5)
    JBC     StatusReg,ZeroFlag
    RET
_Timer500ms:
    XOR     Cnt16msBak,A

    BS      TRFlagReg,F_500ms
    JBC     TRFlagReg,F_QuitTime32ms
    RET

    DJZA    QuitTime                    ; QuitTime =1 ʱֹͣ��
    MOV     QuitTime,A
    RET

_Timer250ms:
    XOR     Cnt16msBak,A
    BS      TRFlagReg,F_250ms
    RET

_Timer32ms:
    XOR     Cnt16msBak,A

    JBS     TRFlagReg,F_QuitTime32ms
    JMP     $+3
    DJZA    QuitTime                    ; QuitTime =1 ʱֹͣ��
    MOV     QuitTime,A

    ; M_SingleKeyNoCont20190821
;**********32ms�жϣ�����ɨ��*****************
;  32ms �ж�һ�Σ�����ɨ��   256/16384= 1/64	
; IntKeyValue    B7 6 5 4 3 2 1 0
;                   |       |____KeyPin
;                   +____________KeyLast
;*******************************************
;**********25ms�жϣ�����ɨ��*****************
;  25ms �ж�һ�Σ�����ɨ��   256/16384= 1/64	
;*******************************************
;  ����������ʹ�� 3��RAM 
	KeyVibrate		==		10     ; 300MS

;//TODO: KeyScan
    MOV     A,KeyStep
    ADD     PC,A
    JMP     _KeyScanStep1
    JMP     _KeyScanStep2
    JMP     _KeyScanStep3
    JMP     _KeyScanStep4
    JMP     _KeyScanStep5
    JMP     _KeyConfirmStep1
    JMP     _KeyConfirmStep2
    JMP     _KeyConfirmStep3
    JMP     _KeyConfirmStep4
    JMP     _KeyConfirmStep5
_KeyResetStep:
    CLR     KeyStep

_KeyScanStep1:
_KeyScanStep2:
_KeyScanStep3:
_KeyScanStep4:
_KeyScanStep5:
    BC      KeyCodeCurrent,B_Key1
    JBS     P_IN1,B_IN1
    BS      KeyCodeCurrent,B_Key1

    CALL    _KeyBitMask
    MOV     PrgTmp1,A

    MOV     A,KeyCodeCurrent
    XOR     A,KeyCodeLast
    AND     A,PrgTmp1
    JBC     StatusReg,ZeroFlag
    JMP     _KeyNextStep
    XOR     KeyCodeLast,A

    MOV     A,Key1Cnt
    ADD     A,KeyStep
    MOV     RamSelReg,A

    MOV     A,@KeyVibrate
    MOV     R0,A
_KeyNextStep:
    INC     KeyStep
    RET

_KeyConfirmStep1:
_KeyConfirmStep2:
_KeyConfirmStep3:
_KeyConfirmStep4:
_KeyConfirmStep5:

    MOV     A,KeyStep
    ADD     A,@Key1Cnt-5
    MOV     RamSelReg,A
    MOV     A,R0
    JBC     StatusReg,ZeroFlag
    JMP     _KeyNextStep

    MOV     A,R0
    ADD     A,@0xFF
    MOV     R0,A
    JBS     StatusReg,ZeroFlag
    RET

    MOV     A,KeyStep
    SUB     A,@5
    CALL    _KeyBitMask
    MOV     PrgTmp1,A
    AND     A,KeyCodeLast
    JBS     StatusReg,ZeroFlag
    RET

    MOV     A,PrgTmp1
    OR      KeyFlagReg,A
    RET

