
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
   chksum:    

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
    RETL    @0xF0             ; 12λ
    RETL    @0xB0
    ; RETL    @0xF0   + (1<<1)    ; 10λ��ַ��ʽ�� ��2λ
    ; RETL    @0x38               ; 10λ��ַ��ʽ�� ��8λ
 

_KeyBitMask:
    MOV     A,PrgTmp1
    ADD     PC,A
    RETL    @1<<B_Key1
    RETL    @1<<B_Key2
    RETL    @1<<B_Key3
    RETL    @1<<B_Key4
    RETL    @1<<B_Key5

_TurnOnRelay:
    BC      StatusReg,CarryFlag         ; �رռ̵���
    RLCA    PrgTmp1
    ADD     PC,A
    BS      P_RLY1,B_RLY1
    RET
    BS      P_RLY2,B_RLY2
    RET    
    BS      P_RLY3,B_RLY3
    RET
    BS      P_RLY4,B_RLY4
    RET        
    BS      P_RLY5,B_RLY5
    RET    

; �ر�ĳ���̵���
_TurnOffRelay:
    BC      StatusReg,CarryFlag         ; �رռ̵���
    RLCA    PrgTmp1
    ADD     PC,A
    BC      P_RLY1,B_RLY1
    RET
    BC      P_RLY2,B_RLY2
    RET    
    BC      P_RLY3,B_RLY3
    RET
    BC      P_RLY4,B_RLY4
    RET        
    BC      P_RLY5,B_RLY5
    RET    


_KeyScanTable:
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



;**********************************************************
;    M_I2CSlaver202003           ; I2C ���س���
;**********************************************************
;  2020.03.01 ���£�I2C Slaver , Master,֧��7bit,10bit��ַ��ʽ
;    ��I2C��ַ�趨Ϊ��Χ  C_RelayNum
;
;     06-д�豸��ַ�� 07-���豸��ַ
;*****************************************
;ʹ�� I2C Slaver ��ע�⣺
;   ���ڴ��� �б���Ҫ�� ����ڳ���ʼλ��
;   �� IntPortEnd ���� main��ʼ
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


;//todo: IntPort                               ;��Ϊ��ѯ��ʽ����I2C Э�飬���� maskter�豸�ٶȹ�����Щ�ж�©��
IntPort:
	MOV		A,I2CS_Port
	XOR		A,SystemFlag
	AND		A,@I2CSMask
	MOV		IntTemp,A                        ; IntTempΪ �˿ڵ�ǰ��⵽�ı仯λ
	XOR		SystemFlag,A                     ; SystemFlag Ϊ�˿ڵ�ǰֵ
 
    JBS     SystemFlag,F_SDAInput
    JMP     ChkStartEnd 

    JBS     SystemFlag,SlaverSCL            ; �� SCL �ߵ�ƽʱ
    JMP     ChkStartEnd    

	JBS		IntTemp,SlaverSDA               ; SDA �仯��
	JMP		ChkStartEnd
	
	JBS		SystemFlag,SlaverSDA
    JMP     _Step_RcvDevAddr                ; SDA �ɸ߱��Ϊ START,  GetStart:
    JMP     _Step_GetStop

ChkStartEnd:
NextOpration:
;//mark: �����
    MOV     A,I2CStep
    ADD     PC,A
    JMP     IntPortEnd                      ; �ȴ����� START ���� STOP ���в�����ֻ���ڽ��� START,STOP
    JMP     Step_ChkDevAddr                 ;  
    JMP     Step_GetBroad1Byte              ; �㲥��ַ���һ�ֽڣ� 01
    JMP     Step_ChkAddrByte2               ; 10B ��ַ����2�ֽ�
    JMP     Step_GetByteAddr                ;  
    JMP     Step_WriteByte                  ;  
    JMP     Step_PreTxByte                  ;  
    JMP     Step_TxByte                     ;  
    JMP     Step_ReadAck                    ;    
    JMP     Step_TxAckRcvByte               ;  
    JMP     Step_RcvByte                    ;  
    JMP     Step_TxACK                      ;  



;*****************************************************************************************    
_Step_RcvDevAddr:                          ; ���յ� START ����еĲ���
    MOV     A,@C_ChkDevAddr
    MOV     StepBak,A

	MOV     A,@8
	MOV     CLKS,A

    MOV     A,@C_RcvByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;*****************************************************************************************    
Step_ChkDevAddr:                          ; ��ǰ���յ����ֽ�Ϊ �豸��ַADDR
    MOV     A,Data
    AND     A,@0xFE
    XOR     A,@0x06
    JBS     StatusReg,ZeroFlag
    JMP     _Step_Chk10BitAddr 


; ���յ����豸��ַ������
    JBC     Data,0
    JMP     _Step_DevAddrOk
;*****************************************************************************************    
;            ͨ���㲥��ַд�豸��ַ�� 00 - 01 - ��A1����A2��
    BS      SystemFlag,F_WDevAddr           ; ��� Slaver����ֻ���������� **�޸�2**
    MOV     A,@C_GetBroad1Byte              ; �豸��ַΪ 00���㲥��ַ
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
    MOV     A,Data                          ; ��7λ��ַ���� ͬ��
    AND     A,@0xF8
    XOR     A,@0xF0
    JBS     StatusReg,ZeroFlag              ; ����5λ�ǲ��� F0
    JMP     _Step_7BitAddr                  ; ��7λ��ַ ,���������ڲ���ַ

    MOV     A,Data
    AND     A,@0xFE
    XOR     A,DevAddrByte                   ; ���յ���һ���豸��ַ�ֽڱ�����ͬ
    JBS     StatusReg,ZeroFlag
    JMP     Error_DevAddrDiff

    JBS     Data,0                          ; ��һ���豸��ַ��5λ�� F0
    JMP     $+4
    JBS     SystemFlag,F_AddrMarried        ; ��һ���豸��ַ ��10λ�������λ��1-��
    JMP     Error_DevAddrDiff               ; ���յ�10λ��ַ���������Լ��ģ�
    JMP     _Step_DevAddrOk                 ; 10λ��ַ�Ѿ�У�飬��Ҫ������

    MOV     A,@C_ChkAddrByte2               ; �������10λ��ַ �ڶ����ֽ�
    JMP     PreSetTxAckRcvByte

Step_ChkAddrByte2:                        ; ���10bit��ַ��2���ֽ�
    MOV     A,DevAddrByte+1
    ADD     A,@C_RelayNum
    SUB     A,Data
    JBC     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff

    MOV     A,DevAddrByte+1
    SUB     A,Data
    JBS     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff    
    ADD     A,@DataBuf
    MOV     DataPtr,A

    BS      SystemFlag,F_AddrMarried        ; ��⵽�豸��ַ ��10λ��ַ����ͬ
    JMP     _Step_WriteByteAddr

_Step_7BitAddr:                             ; ���յ���ַ��7bit��ַ
    MOV     A,DevAddrByte
    ADD     A,@C_RelayNum*2
    SUB     A,Data
    JBC     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff

    MOV     A,DevAddrByte
    SUB     A,Data
    JBS     StatusReg,CarryFlag
    JMP     Error_DevAddrDiff

    MOV     PrgTmp1,A
    BC      StatusReg,CarryFlag
    RRCA    PrgTmp1
    ADD     A,@DataBuf
    MOV     DataPtr,A

    JBC     Data,0
    JMP     _Step_DevAddrOk                 ; ������ ��7bit��ַ�����Ҳ���
_Step_WriteByteAddr:
    BC      SystemFlag,F_I2CRead            ; �޸�*******3 ����д��־
    MOV     A,@C_GetByteAddr                ; ����д����
    JMP     PreSetTxAckRcvByte

;*****************************************************************************************    
Step_GetByteAddr:                           ; ���յ�����RAM��ַ
    MOV     A,Data 
    ADD     DataPtr,A                       ; �趨����ָ��
_Step_PreWriteByte:
    MOV     A,@C_WriteByte                  ; 
	JMP     PreSetTxAckRcvByte              ; ���յ�һ���ֽں󣬽��� Step06_WriteByte ������дһ�����ݣ�
	
Step_WriteByte:                             ; ��ǰ����д���ݲ���
    MOV     A,DataPtr
    MOV     RamSelReg,A                     ; ������ָ��
                               
    MOV     A,@~C_TurnsMask      ; �޸�******1���ﲻͬ
    AND     R0,A
    MOV     A,Data
    AND     A,@C_TurnsMask       ; ����ֻ�����4λ
    OR      R0,A                 ; ��������

    CALL    ChkDataPtrOverflow
    JMP     _Step_PreWriteByte
;*****************************************************************************************    
_Step_DevAddrOk:            ;�豸��ַ��ȷ�����Ҷ�����
    BS      SystemFlag,F_I2CRead            ; �޸�*******4 ����д��־

    MOV     A,@C_PreTxByte
    MOV     StepBak,A
    MOV     A,@C_TxAck
    MOV     I2CStep,A
    JMP     IntPortEnd

Step_PreTxByte:
	MOV     A,@8                            ; ����Ϊ����������豸���͵�һ������
	MOV     CLKS,A
    MOV     A,DataPtr
    MOV     RamSelReg,A
    MOV     A,R0
    AND     A,@C_TurnsMask      ; �޸�******2���ﲻͬ     
    MOV     Data,A                          ; ��õ�ǰָ������

    CALL    ChkDataPtrOverflow

    MOV     A,@C_TxByte
    MOV     I2CStep,A
    JMP     IntPortEnd
;*****************************************
Step_TxByte:                                ; ����һ���ֽڹ���
    JBS     IntTemp,SlaverSCL               ; SCL�����仯ʱ
    JMP     IntPortEnd

	JBC		SystemFlag,SlaverSCL
	JMP		_Step_TxByte_DatEnd

	RLC		Data
    JBC     StatusReg,CarryFlag             ; ��������
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
	JMP		SDAInput                        ; SCL Ϊ�͵�ƽ���ı� SDAΪ����
	JBC		SystemFlag,SlaverSDA            ; SCL Ϊ�ߵ�ƽ��
	JMP		_Step_GetNoAck                  ; SDA Ϊ�ߵ�ƽ�������Ϊ NO_ACK
    JMP     Step_PreTxByte                  ; SDA Ϊ�͵�ƽ������� RX_ACK ��׼�������¸�����

;*****************************************
Step_TxAckRcvByte:
    JBS     IntTemp,SlaverSCL               ; SCL �����仯ʱ
    JMP     IntPortEnd

	JBS		SystemFlag,SlaverSCL            ; 
	JMP		_SlaverSDA_0                    ; ����ACK

    INC     I2CStep
	MOV     A,@8
	MOV     CLKS,A
    JMP     IntPortEnd

Step_RcvByte:                               ; ����һ���ֽڹ���
    JBS     IntTemp,SlaverSCL               ; SCL �����仯
    JMP     IntPortEnd
    
	JBS		SystemFlag,SlaverSCL
	JMP		FirstClkInput                   ; SCLΪ�͵�ƽ���ı�˿ڷ���
    
	BC		StatusReg,CarryFlag             ; SCLΪ�ߵ�ƽ���������ݣ�������DATA��
	JBC		SystemFlag,SlaverSDA
	BS		StatusReg,CarryFlag             ; SCLΪ�ߵ�ƽ���������ݣ�������DATA��
	RLC		Data
	
	DJZ		CLKS
	JMP		IntPortEnd

    JMP     _ReturnStep
;*****************************************
Step_TxACK:                                 ; ���� TX_ACK ����
    JBS     IntTemp,SlaverSCL               ; SCL �����仯ʱ
    JMP     IntPortEnd

	JBS		SystemFlag,SlaverSCL            ; 
	JMP		_SlaverSDA_0

_ReturnStep:   
    MOV     A,StepBak                       ; SCLΪ�ߵ�ƽʱ�����ز���
    MOV     I2CStep,A
    JMP     NextOpration
;***************************************** 
ChkDevAddrError:
    JBC     DevAddrByte,0
    BC      DevAddrByte,0

    MOV     A,DevAddrByte
    AND     A,@0xF0
    JBC     StatusReg,ZeroFlag
    JMP     _DevAddrError                   ; ��4λΪ0����Ϊ������ַ��������

    COMA    DevAddrByte
    AND     A,@0xF8
    JBC     StatusReg,ZeroFlag
    JMP     _DevAddrError                   ; ��5λ = F8��������ַ
    BC      StatusReg,CarryFlag
    RET    

_DevAddrError:
    BS      StatusReg,CarryFlag
    RET    


ChkDataPtrOverflow:                         ; ��ַ��1 ������ַ���
    INC     DataPtr                         ; ����ָ�������һ��

    MOV     A,@DataBufEnd+1                 ; 153B RAM���2F������2F������BUF
    SUB     A,DataPtr
    MOV     A,@DataBuf                      ; ����ָ����ڵ���0X30�������趨����ָ��
    JBC     StatusReg,CarryFlag
    MOV     DataPtr,A
    RET
;*****************************************
FirstClkInput:                              ; SCL Ϊ��Ϊ�͵�ƽʱ
    JBS     CLKS,3
    JMP     IntPortEnd
SDAInput:
_SlaverSDA_1:
    MOV     A,@C_Slaver_BusIn               ; SCL, SDA ����Ϊ����
	IOW		I2CS_Port
    BS      SystemFlag,F_SDAInput
	JMP		IntPortEnd

_SlaverSDA_0:
    MOV     A,@C_Slaver_SCLi_SDAo           ; SCL Ϊ���룬 SDA Ϊ���
	IOW		I2CS_Port
	BC		I2CS_Port,SlaverSDA    
    BC      SystemFlag,F_SDAInput
    JMP     IntPortEnd
;*****************************************
_Step_GetStop:                              ; SDA �ɵͱ��Ϊ STOP
    BS      SystemFlag,F_DataValid          ; ���յ�STOP ��������һ������
_Step_GetNoAck:                             ; ���ҽ���
Error_DevAddrDiff:      
    CLR     I2CStep
    BC      SystemFlag,F_AddrMarried        ; 10λ��ַƥ��ȡ��
    JMP     _SlaverSDA_1
;*****************************************

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


    MOV     A,@C_DevBufSize
    MOV     PrgTmp1,A
    MOV     A,@C_E2Addr_DevAddr
    MOV     PrgTmp2,A
    MOV     A,@DevAddrByte
    MOV     RamSelReg,A
    CALL    I2C_ReadPageData                      ; ���EPROM�Ƿ������ݣ����EPROM��ַ��ȷ��ʹ��EPROM�������OPT�˿�

    CALL    ChkDevAddrError
    JBS     StatusReg,CarryFlag
    JMP     $+5
_EpromError:
    CALL    DefaultDevAddr
    MOV     DevAddrByte,A
    CALL    DefaultDevAddr+1
    MOV     DevAddrByte+1,A

;EPROM ����ɣ����õ���˿�״̬
    MOV     A,@MachineIO_Init
    IOW     Port6
    MOV     A,@MachineR_Init
    MOV     Port6,A

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
    JMP     UpdatDevAddr                    ; �����豸��ַ

    JBC     SystemFlag,F_I2CRead            ; ֻ����д�������
    JMP     main                            ; 
;���ݵ�ǰ���ݣ���õ�ǰ���õ��״̬ = tmp2
    MOV     A,@CtrlByte                     ; ���ݴ���
    MOV     RamSelReg,A
    CLR     PrgTmp1
    CLR     PrgTmp2                         ; ��ǰ�������״̬
_I2CSetSWLoop:
    MOV     A,R0
    AND     A,@C_TurnsMask
    JBC     StatusReg,ZeroFlag
    JMP     $+3

    CALL    _KeyBitMask
    OR      PrgTmp2,A

    INC     RamSelReg
    INC     PrgTmp1
    MOV     A,@C_RelayNum
    SUB     A,PrgTmp1
    JBS     StatusReg,CarryFlag
    JMP     _I2CSetSWLoop
;���ݵ�ǰ���ݣ���õ�ǰ���õ��״̬ = tmp2
    MOV     A,PrgTmp2
    XOR     A,EnKeyReg
    XOR     EnKeyReg,A          ; ���¿���״̬        1 
    MOV     PrgTmp2,A           ; ��Ҫ������λ
    OR      TxUartFlag,A        ; ���õ������λ����   2    

    CLR     PrgTmp1             ; ������ش���        3
_OnOffRelayLoop:
    BC      StatusReg,CarryFlag
    RRC     PrgTmp2
    JBS     StatusReg,CarryFlag
    JMP     _OnOffRelayNext

    CALL    _KeyBitMask
    AND     A,EnKeyReg
    JBC     StatusReg,ZeroFlag
    JMP     $+3

    CALL    _TurnOnRelay
    JMP     $+2

    CALL    _TurnOffRelay
_OnOffRelayNext:
    INC     PrgTmp1
    MOV     A,@C_RelayNum
    SUB     A,PrgTmp1
    JBS     StatusReg,CarryFlag
    JMP     _OnOffRelayLoop

    JMP     main

;*****************************************

RelayAction:
; 	JBC		RelayStatus,F_RlyOn
; 	BS		Relay1Port,Relay_B1
; 	JBS		RelayStatus,F_RlyOn
; 	BC		Relay1Port,Relay_B1
; if (Relay4Board==1) ||(Relay4Board==2)
; 	JBC		RelayStatus,F_RlyOn1
; 	BS		Relay2Port,Relay_B2
; 	JBS		RelayStatus,F_RlyOn1
; 	BC		Relay2Port,Relay_B2

; 	JBC		RelayStatus,F_RlyOn2
; 	BS		Relay3Port,Relay_B3
; 	JBS		RelayStatus,F_RlyOn2
; 	BC		Relay3Port,Relay_B3

; 	JBC		RelayStatus,F_RlyOn3
; 	BS		Relay4Port,Relay_B4
; 	JBS		RelayStatus,F_RlyOn3
; 	BC		Relay4Port,Relay_B4
; endif
    JMP     main


;***************************************** 
; ���豸ͨ��06,07��ַ�޸����豸��ַ����Ҫ������EPROM��
UpdatDevAddr:
    BC      SystemFlag,F_WDevAddr
    MOV     A,@DevAddrByte+1
    SUB     A,DataPtr
    JBS     StatusReg,CarryFlag
    JMP     main

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
    CALL    I2C_WritePageData      ; ����
    JMP     main

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

; �͵�ƽ���  5* 320 = 1.5 ��
	Key0Vibrate		==		5     ; 1��λ=320ms,   5 = 1.5��
; �ߵ�ƽ���  8*320 = 1.8 ��
	Key1Vibrate		==		8     ; 1��λ=320ms,   8 = 1.8��

    C_VibMask       ==      0xF0
    C_TurnsMask     ==      0x0F    
;//TODO: KeyScan
    MOV     A,EnKeyReg
    JBC     StatusReg,ZeroFlag
    RET

    MOV     A,@C_RelayNum
    SUB     A,KeyStep
    JBS     StatusReg,CarryFlag
    MOV     A,KeyStep
    MOV     PrgTmp1,A                   ; Prgtmp1 = ��N�����
    ADD     A,@Key1Cnt
    MOV     RamSelReg,A                 ; RamSelReg = �Ĵ�����ַ

    ; MOV     A,PrgTmp1
    CALL    _KeyBitMask
    MOV     PrgTmp2,A                   ; Prgtmp2 = λ��־
    AND     A,EnKeyReg
    JBC     StatusReg,ZeroFlag
    JMP     $+3

    MOV     A,KeyStep
    JMP     _KeyScanTable
NextKeyStep:
    INC     KeyStep
    MOV     A,@2*C_RelayNum
    SUB     A,KeyStep
    JBC     StatusReg,CarryFlag
    CLR     KeyStep
    RET


_KeyScanStep1:
    BC      KeyCodeCurrent,B_Key1
    JBC     P_IN1,B_IN1
    BS      KeyCodeCurrent,B_Key1
    JMP     _ChkKeyChange
_KeyScanStep2:
    BC      KeyCodeCurrent,B_Key2
    JBC     P_IN2,B_IN2
    BS      KeyCodeCurrent,B_Key2
    JMP     _ChkKeyChange
_KeyScanStep3:
    BC      KeyCodeCurrent,B_Key3
    JBC     P_IN3,B_IN3
    BS      KeyCodeCurrent,B_Key3
    JMP     _ChkKeyChange
_KeyScanStep4:
    BC      KeyCodeCurrent,B_Key4
    JBC     P_IN4,B_IN4
    BS      KeyCodeCurrent,B_Key4
    JMP     _ChkKeyChange
_KeyScanStep5:
    BC      KeyCodeCurrent,B_Key5
    JBC     P_IN5,B_IN5
    BS      KeyCodeCurrent,B_Key5
_ChkKeyChange:

    CALL    NextKeyStep

    MOV     A,KeyCodeCurrent
    XOR     A,KeyCodeLast
    AND     A,PrgTmp2
    JBC     StatusReg,ZeroFlag
    RET
    XOR     KeyCodeLast,A

    MOV     A,@~C_VibMask
    AND     R0,A

    MOV     A,KeyCodeLast
    AND     A,PrgTmp2
    JBS     StatusReg,ZeroFlag
    JMP     $+4

    MOV     A,@Key0Vibrate<<4
    OR      R0,A
    RET

    MOV     A,@Key1Vibrate<<4
    OR      R0,A
    RET

_KeyConfirmStep1:
_KeyConfirmStep2:
_KeyConfirmStep3:
_KeyConfirmStep4:
_KeyConfirmStep5:

    CALL    NextKeyStep

    MOV     A,R0
    AND     A,@C_VibMask
    JBC     StatusReg,ZeroFlag
    RET

    MOV     A,@0x10                     ; ��ⶶ���� ��1
    SUB     A,R0
    MOV     R0,A
    AND     A,@C_VibMask
    JBS     StatusReg,ZeroFlag
    RET

    MOV     A,KeyCodeLast
    AND     A,PrgTmp2
    JBS     StatusReg,ZeroFlag          ; �˿��ɸ߱�͵�ƽʱ������
    RET

    DEC     R0
    MOV     A,R0
    AND     A,@C_TurnsMask
    JBS     StatusReg,ZeroFlag          ; ���ת������ 0
    RET 

    MOV     A,PrgTmp2
    OR      TxUartFlag,A                ; ���÷���UART��־

    JMP     _TurnOffRelay

