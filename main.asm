; RF24L01�����շ�ģ�� , ���ն� 2020.02.11, 
;   153  chksum: otp: 2A5D-4M   , 2A87-8M
include	"option.h"
include	"ConstDef.h"
include "public.h"
include	"PortDef.h"
include	"RamDef.h"
include	"Mini4X8LED.H"
include "macro.h"




    ORG     0
    JMP     McuReset
_EpAddrTable:
    MOV     A,SetMode
    ADD     PC,A
    RETL    @C_EpAddr_SWI2c-0x10
    RETL    @C_EpAddr_SWNodeKey-0x10
    RETL    C_EpAddr_TxChannel-0x10

_EpSizeTable:
     MOV     A,SetMode
     ADD     PC,A
     RETL    @2
     RETL    @2
     RETL    @4

_BitTable:
    ADD     PC,A
    RETL    @1<<0
    RETL    @1<<1
    RETL    @1<<2
    RETL    @1<<3
    RETL    @1<<4
    RETL    @1<<5
    RETL    @1<<6
    RETL    @1<<7

_RxChannelTable:
    DECA    SetMode
    ADD     PC,A
    JMP     _ResetTable1
    JMP     _ResetTable2
    JMP     _ResetTable3
    JMP     _ResetTable4

_ResetTable5:           ; �����ŵ�
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xB1       ; �ŵ��� 01      
    RETL    @0xB2       ; �ŵ��� 02      
    RETL    @0xB3       ; �ŵ��� 03      
    RETL    @0x05       ; RF-CH      


_ResetTable1:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xA1       ; �ŵ��� 01      
    RETL    @0xA2       ; �ŵ��� 02      
    RETL    @0xA3       ; �ŵ��� 03      
    RETL    @0x02       ; RF-CH      
    RETL    @0x00       ; �����ŵ���, ����
    RETL    @0x01       ; �����ŵ���
    RETL    @0x02       ; ���ÿ�����

_ResetTable2:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x34       ; �ŵ��� 01      
    RETL    @0x43       ; �ŵ��� 02      
    RETL    @0x10       ; �ŵ��� 03      
    RETL    @0x00       ; RF-CH      

_ResetTable3:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x01       ; �ڵ�1��
    RETL    @0x01       ; ����ֵ=1

_ResetTable4:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x08       ; �ڵ�8��
    RETL    @0x02       ; ����ֵ=2



_ResetAddrTable:
    DECA    SetMode
    ADD     PC,A
    RETL    @C_EpAddr_RxChannel
    RETL    @C_E2Addr_Config
    RETL    @C_EpAddr_SWNodeKey
    RETL    @C_EpAddr_SWNodeKey+0x10
    RETL    @C_EpAddr_TxChannel

_ResetSizeTable:
    DECA    SetMode
    ADD     PC,A
    RETL    @7
    RETL    @4
    RETL    @2
    RETL    @2
    RETL    @4


;*************************************************
;//MARK: дEPROM�ɹ��б�
    C_SaveEp_I2CSW      ==      00
    C_SaveEp_Reset      ==      01
    C_SaveEp_UpCode     ==      02  ;OK
    C_SaveEp_SWNodeKey  ==      03
    C_SaveEp_ChannelNums==      04
    C_SaveEp_DownCode   ==      05
    C_SaveEp_RData      ==      06
    C_SaveEp_TData      ==      07
_SaveSucessTable:
    MOV     A,Ep_Mode
    ADD     PC,A
    JMP     TimeSpaceRcv                    ;00
    JMP     _ConfirmResetSaveOk             ;01 
    JMP     ConfigRcv_RxChannel1            ;02 
    JMP     ConfigRcv_SaveTxChannelNums     ;03 
    JMP     FlashSucess                     ;04 
    JMP     _RxDownCodeSaveNum              ;05 
    JMP     _SetRxData_SaveRData            ;06 
    JMP     _SetTxData_SaveTData            ;07 

;*************************************************
;//MARK: ��EPROM�ɹ��б�
    C_ReadEp_ChannelNums    ==  00  ;OK
    C_ReadEp_RxChannel      ==  01  ;OK
    C_ReadEp_RxCode4B       ==  02  ;ok
    C_READEP_TxChananeNums  ==  03  ;ok  �� Tx ChannelNums׼��ת��
    C_ReadEp_MyNode         ==  04  ;ok ת������ҵĽڵ�
    C_ReadEp_SWNodeNums     ==  05  ;ok
    C_ReadEp_SWCode2B       ==  06  ;OK
    C_ReadEp_Cfg_RxChannel  ==  07  ;
    C_ReadEp_TxCode4B       ==  08
    C_ReadEp_TxCodeSwInfo   ==  09  ;
    C_ReadEp_Sleep          ==  10  ; ������������������Ƿ���ҪдEP��������
    C_ReadEp_RelaySWAddr    ==  11  ; �� I2C���ص�ַ��3B,4B,5B��2B

_ReadSucessTable:
    MOV     A,Ep_Mode
    ADD     PC,A
    JMP     _ReadChannelNumsOk      ;00   
    JMP     _TxMyNode_ReadEp        ;01   C_ReadEp_RxChannel      ==  02
    JMP     _RxCode4B               ;02   C_ReadEp_RxCode4B       ==  03
    JMP     NextSWInfo              ;03   C_READEP_TxChananeNums ��ת��NUMS
    JMP     _RcvTrans_MyNode        ;04   ����ҵĽڵ�
    JMP     _ChkNextSWNum           ;05   
    JMP     _RcvTrans_SW2B          ;06   ��SW CODE 2B
    JMP     ConfigRcv_SetSW         ;07
    JMP     _TxCode4B               ;08
    JMP     ConfigRcv_ChkDataRecover;09
    JMP     _McuReset_Sleep         ;10
    JMP     _RelaySWAddr            ;11
;*************************************************
;//MARK: ��EPROMʧ���б�
; _ReadFailTable:
;    M_LEDOFF
    ; JMP     ResetKeyCnt

;*************************************************
;//MARK: �������� - �б�

    ; C_TxData_Trans      ==  0       ;ok  ��������ת��������Ϣ
    ; C_RX2TX_Config      ==  1       ;
    ; C_TxData_MyNode     ==  2

_SetTxDataTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _RcvTrans_SetData       ; 
    JMP     _TxMyNode_SetData       ;
    JMP     _ConfigRcv_ReturnTable  ;

; �������ݳɹ�����
_TxDataEndTable:                    
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _NextSWNums
    JMP     _Tx2Rx
    JMP     _ConfigRcv_SaveTable

; ��������ʧ�ܴ���
_TxFailTable:                       
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _NextSWNums
    JMP     PresetRxTrans_LedOff
    JMP     PresetRxTrans_LedOff
;*************************************************
;//MARK: Time ����ʱ��
    ; ms ������������������ȴ�ʱ�� 1��
    ; ����EProm�ȴ�ʱ��           1��
    ; ��  EProm�ȴ�ʱ��           1��
    C_WaitEpTime    ==      5   ; ms 

    C_KeyUpTime     ==      30  ; ms    

    ; SPI �������ݵȴ�ʱ�䣬 320ms 
    C_SpiTxTime     ==      10  ; ms

    ; �ȴ��û�����ʱ��  15��
    C_WaitKeyTime   ==      30  ; 0.5s,

    ; �����ɹ�����LEDʱ�� 3��
    C_FlashSucessTime==     6   ; 0.5s

;//MARK: �������� - �б� 
;
    ; C_RxData_Trans      ==  0       ; ����ת��
    ; C_RxData_Config     ==  1       ; ����������Ϣ
    ; C_Tx2Rx_Code4B      ==  2


    C_Trans_Data        ==  0       ; ����  - ת������;  SPI_Mode = 0
    C_SetDn_Data        ==  1       ; ������ͨ�ţ� SPI_Mode = 1
    C_SetUp_Data        ==  2       ; ������ͨ�ţ� SPI_Mode = 2


; ���ճ�ʱ��
; _RxTimeOverTable: 
    ; MOV     A,SPI_Mode
    ; ADD     PC,A
    ; JMP     IdleModeCode_LedOff     ; û���յ���Ϣ����������
    ; JMP     PresetRxTrans_LedOff    ; 
    ; JMP     PresetRxTrans_LedOff    ; 

; �������ݳɹ���
_RxDataEndTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _IdleRcvTrans           ; ���յ�ת����Ϣ����
    JMP     _RxDownCodeEnd          ; ���յ�
    JMP     ConfigRcv_GetData       ;


;*************************************************
GetMaxNums:
    DECA    SetMode
    ADD     PC,A
    RETL    @C_MaxChannelNumber
    RETL    @C_MaxSWNum
    RETL    @C_MaxTxChannelNum
    RETL    @C_MaxTxChannelNum


     

GetInfoType:
    DECA    SetMode
    ADD     PC,A
    RETL    @C_NodeType
    RETL    @C_SWType
    RETL    @C_RFType

_ConfigRcv_ReturnTable:
    DECA    SetMode
    ADD     PC,A
    JMP     ConfigRcv_SetNode
    JMP     ConfigRcv_SetSW
    JMP     ConfigRcv_RxChannel

   C_MaxKeyCnt  ==   5
; _IdleKeyCntTable:
;     DECA    SetMode
;     ADD     PC,A
;     JMP     IdlePress2Key           ; ���ýڵ��
;     JMP     IdlePress3Key           ; ���ÿ�����Ϣ
;     JMP     IdlePress4Key           ; ���շ����룬���ͽ�����
;     JMP     IdlePress5Key           ; ���ͽ����룬���շ�����


_ChannelNum_EpTable:
    DECA    SetMode
    ADD     PC,A
    RETL    @C_E2Addr_MyNode
    RETL    @C_E2Addr_SwNodeNums
    RETL    @C_E2Addr_TxChannelNums
    RETL    @C_E2Addr_TxChannelNums

_ConfigRcv_SaveTable:
    DECA    SetMode
    ADD     PC,A
    JMP     ConfigRcv_SaveMyNode      ; ����ڵ�� 
    JMP     ConfigRcv_SaveSW        ; ���濪����Ϣ
    JMP     ConfigRcv_SaveTxChannelNums

;*************************************************
_SaveFailTable:
    MOV     A,Ep_Mode
    JBC     StatusReg,ZeroFlag
    JMP     PresetRxTrans           ; ����I2C����ʧ�ܣ��ָ�����ģʽ
_ReadFailTable:
ResetKeyCnt:
    CLR     SetMode
    CLR     TRMode
main:
    WDTC
    CALL    SoftTimer


    C_ConfirmReset      ==  1
    C_WaitBlinkEnd      ==  2
    C_TxData            ==  3
    C_SaveEpromData     ==  4
    C_ReadEpromData     ==  5
    C_WaitTxDataEnd     ==  6
    C_WaitRxDataReturn  ==  7 
    C_CompEpromData     ==  8
    C_WaitRx2TxEnd      ==  9
    C_WaitTimeOver      ==  10
;//TODO: main
_mainTable:    
    MOV     A,TRMode
    ADD     PC,A
    JMP     IdleModeCode            ;0
    JMP     ConfirmReset            ;1
    JMP     WaitBlinkEnd            ;2 
    JMP     TxData                  ;3  ��һ�μ��������ҵĽڵ���Ϣ
    JMP     SaveEpromData           ;4
    JMP     ReadEpromData           ;5
    JMP     WaitTxDataEnd           ;6  ������ɣ�תΪ����ģʽ
    JMP     WaitRxDataReturn        ;7
    JMP     CompEpromData           ;8
    JMP     WaitRx2TxEnd            ;9
    JMP     WaitTimeOver_NoLed      ;10 �ȴ���ʱ��LED���䣬����ģʽ
; ת���������ȽϽڵ��Ƿ����ҵĽڵ���Ϣ����ͬ�����2�ֽ���ͬ����̵�������

    C_MaxMode   ==   $-_mainTable-2
;    M_I2CMaster201911
include "com.asm"
;******************************************
;//MARK: IdleModeCode
IdleModeCode:
    MOV     A,SetMode
    JBC     StatusReg,ZeroFlag
    JMP     $+5

    JBS     IntKeyValue,B_KeyUp
    BS      P_LED,B_LED
    JBC     IntKeyValue,B_KeyUp
    BC      P_LED,B_LED

    CALL    ChkKeyDown
    JBS     StatusReg,CarryFlag
    JMP     _IdleChkKeyUp

    INC     SetMode
    MOV     A,@C_KeyUpTime
    MOV     KeyTime,A
    JMP     main

_IdleChkKeyUp:
    MOV     A,SetMode
    JBC     StatusReg,ZeroFlag
    JMP     _IdleChkKey3s

    DJZA    KeyTime
    JMP     main

    MOV     A,@2
    SUB     A,SetMode
    JBS     StatusReg,CarryFlag
    JMP     ResetKeyCnt

    MOV     A,SetMode
    SUB     A,@C_MaxKeyCnt
    JBS     StatusReg,CarryFlag
    JMP     ResetKeyCnt

    BS      TRFlagReg,F_Config
    DEC     SetMode
    CALL    _ChannelNum_EpTable
    CALL    SetEp_ChannelNums
    MOV     A,@C_ReadEp_ChannelNums ; 1 - MyNode/SWNums/TxNums����ChannelNums
    JMP     PresetReadEp
; _ReadChannelNumsOk:  ת��

_IdleChkKey3s:
    JBC     IntKeyValue,B_KeyDown3s
    JMP     ResetSystemParam
    JMP     CheckRxIRQ              ; ��� IRQ
;************************************************
;//MARK: Trans ���յ�������Ϣ����
_IdleRcvTrans:
    MOV     A,@C_KeyNodeType
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag      ; �������� ���ؽڵ���ͬ
    JMP     PresetRxTrans           ; ���ʹ����½���

    JZA     RF_MyNode
    JMP     $+3                     ;
    INC     InfoSN                  ; RF_InfoSN = 0xFF,��Ϊ���ؽڵ㷢�͵���Ϣ�� InFo +1
    JMP     $+7    

    MOV     A,InfoSN
    XOR     A,RF_InfoSN
    JBC     StatusReg,ZeroFlag
    JMP     PresetRxTrans_LedOff              ; ��Ϣ�����ͬ���Ѿ�������ˡ����ٴ���

; ��������Ϣת��
    MOV     A,RF_InfoSN             
    MOV     InfoSN,A                ; ��Ϣ�뱣��
    MOV     A,RF_MyNode
    MOV     MyNode,A                ; ������NODE ������MyNode��

    MOV     A,@C_E2Addr_TxChannelNums
    CALL    SetEp_ChannelNums
    MOV     A,@C_READEP_TxChananeNums
    JMP     PresetReadEp

NextSWInfo:
    MOV     A,ChannelNums
    JBC     StatusReg,ZeroFlag
    JMP     ChkSWNode               ; û���ù�������ת��

    JMP     PresetTxData            ; ���÷����ŵ�

_RcvTrans_SetData:
    MOV     A,MyNode                ; ���νڵ�
    XOR     A,RF_MyNode             ; ���νڵ�
    JBC     StatusReg,ZeroFlag
    JMP     _NextSWNums             ; �������η���

; ���÷�������
    CALL    SetEp_MyNode            ; �� EP MyNode ���� RF_Data+3    
    MOV     A,@C_ReadEp_MyNode      ; 1 - �������ν�����
    JMP     PresetReadEp

_RcvTrans_MyNode:
    MOV     A,InfoSN
    MOV     RF_InfoSN,A
    JMP     _SetTxDataEnd

; ���ͽ������������ط���ʱ�����Ƿ��ͳɹ�����Ҫ�� NUMS
_NextSWNums:
    DEC     ChannelNums
    JMP     NextSWInfo
;************************************************
ChkSWNode:
    MOV     A,@C_ConfigSWInfo
    MOV     SetMode,A               ; ���ô����ò����ж� SW Info

    MOV     A,@C_E2Addr_SwNodeNums
    CALL    SetEp_ChannelNums
    MOV     A,@C_ReadEp_SWNodeNums
    JMP     PresetReadEp

_ChkNextSWNum:
    MOV     A,ChannelNums
    JBC     StatusReg,ZeroFlag
    JMP     PresetRxTrans           ; ����SW�ڵ������

    CALL    SetEpParam_ChannelNums  ; �ӽڵ㣬��ֵ��� 2�ڵ�
    MOV     A,@C_ReadEp_SWCode2B
    JMP     PresetReadEp

_RcvTrans_SW2B:
    MOV     A,RF_Data               ; �ӽڵ㣬��ֵ����Ľڵ�
    XOR     A,RF_SWNode             ; ���յ�����Ϣ���ڵ�űȽ�
    JBS     StatusReg,ZeroFlag
    JMP     _NextSWNodeKey

    MOV     A,RF_Data+1
    XOR     A,RF_SWNode+1
    JBC     StatusReg,ZeroFlag    
    JMP     _RelayChange

_NextSWNodeKey:
    DEC     ChannelNums
    JMP     _ChkNextSWNum     
;************************************************
;//MARK: RelayChange
_RelayChange:
    MOV     A,RF_Data+1
    AND     A,@7
    MOV     ChannelNums,A           ; ChannelNums = RF_Data+1
    CALL    _BitTable
    XOR     RelayStatus,A
    AND     A,RelayStatus
    BC      P_LED,B_LED
    JBS     StatusReg,ZeroFlag
    BS      P_LED,B_LED

    MOV     A,RF_Data+1
    JBS     StatusReg,ZeroFlag
    JMP     $+6
;RF_Data = 0, ���ñ��ؼ̵���
    JBS     RelayStatus,0
    BC      P_Relay,B_Relay
    JBC     RelayStatus,0
    BS      P_Relay,B_Relay
    JMP     TimeSpaceRcv

    CLR     SetMode                 ; ׼���� SW I2C��ַ
    CALL    SetEpParam_ChannelNums
    MOV     A,@C_ReadEp_RelaySWAddr
    JMP     PresetReadEp
_RelaySWAddr:
    MOV     A,RF_Data
    MOV     I2CAddr,A
    MOV     A,@1
    MOV     RF_Data,A

    MOV     A,ChannelNums
    CALL    _BitTable
    AND     A,RelayStatus
    JBC     StatusReg,ZeroFlag
    CLR     RF_Data+1

    CLR     Buf_EpAddr              ; EP ADDR = 0
    MOV     A,@C_SaveEp_I2CSW
    JMP     PresetSaveEp

;************************************************
; ���� ChannelNums ����  I2CADDR /TX CODE/ SW CODE /
SetEpParam_ChannelNums:
    SWAPA   ChannelNums
    MOV     Buf_EpAddr,A      

    CALL    _EpAddrTable
    ADD     Buf_EpAddr,A   
    CALL    _EpSizeTable
    JMP     SetEpParamCh0+2
;TODO: SetEpParamCh0
SetEpParamCh0:
    MOV     Buf_EpAddr,A        ; 
    MOV     A,@C_ChannelSize    ;+1    
    MOV     Buf_RamSize,A       ;+2
    MOV     A,@RF_Data
    MOV     Buf_RamAddr,A
    RET
;************************************************
; �� EP MyNode ���� RF_Data+3    
SetEp_MyNode:
    MOV     A,@C_E2Addr_MyNode
    MOV     Buf_EpAddr,A                ; +1
    MOV     A,@RF_MyNode                ; +2
    JMP     SetEp_ChannelNums + 2
;************************************************
; ���ð� Eprom ��ַ��д�� ChannelNums - 1B ��  
SetEp_ChannelNums:
    MOV     Buf_EpAddr,A                ; +0
    MOV     A,@ChannelNums              ; +1
    MOV     Buf_RamAddr,A               ; +2
    MOV     A,@1                        ; +3
    MOV     Buf_RamSize,A
    RET
;************************************************
SetEp_RData:
    MOV     A,@C_E2Addr_RData
    JMP     SetEp_TData+1
SetEp_TData:
    MOV     A,@C_E2Addr_TData
    MOV     Buf_EpAddr,A

    MOV     A,@PLOAD_WIDTH_SET+1    ; 8
    MOV     Buf_RamSize,A           ;+2
    MOV     A,@EpNum
    MOV     Buf_RamAddr,A
    INC     EpNum
    RET
;************************************************
; ���� Tmp1,RamSelReg ���ö�д SPI �Ĵ��� 3B ��7B
SetTRAddrParam:
    MOV     A,@TX_ADR_WIDTH
    JMP     SetSPIDataParam+1
SetSPIDataParam:
    MOV     A,@PLOAD_WIDTH_DATA     ; 7���ֽ�
    MOV     PrgTmp1,A

    MOV     A,@RF_Data
    MOV     RamSelReg,A
    RET
;************************************************
;//MARK: ReadChannelNumsOk �� MyNode/SW Nums/TX Nums
_ReadChannelNumsOk:
    CALL    GetMaxNums
    SUB     A,ChannelNums
    JBC     StatusReg,CarryFlag
    JMP     ResetKeyCnt

    INC     SPI_Mode                ; ������ͨ�ţ� SPI_Mode = 1

    MOV     A,SetMode
    XOR     A,@C_MaxKeyCnt-1
    JBC     StatusReg,ZeroFlag
    JMP     IdlePress5Key

;//MARK: ����2/3/4��
IdlePress2Key:                      ; ���շ������Ľڵ�ţ�Ȼ�󱣴�
IdlePress3Key:                      ; ���շ������Ŀ��ؽڵ�ţ���ֵ
IdlePress4Key:                      ; �����ҵĽ����ŵ��룬CH�����ͷ�
    INC     SPI_Mode                ; ������ͨ�ţ� SPI_Mode = 2
    JMP     PresetRxData
ConfigRcv_GetData:
    CALL    GetInfoType
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag      ; ������������յ���������ͬ
    JMP     PresetRxTrans_LedOff    ; ���Ͳ�ͬ���˵� PresetRxData

;    MOV     A,@C_RX2TX_Config       ; RX to TX
    JMP     PresetRx2Tx

;_ConfigRcv_ReturnTable:
;************************************************
; ���յ���ָ����  ���ν����룬���������
ConfigRcv_RxChannel:                ; ���÷��ͷ���ַ����Ҫ����ַ�룬�ŵ�
    INCA    RF_MyNode
    JBC     StatusReg,ZeroFlag
    JMP     ConfigRcv_RxChannel1    ; ��� ����CH=FF, �򲻱������ν�����, ChannelNums  ����

    INC     ChannelNums             ; ChannelNums + 1,�������

    CALL    SetEpParam_ChannelNums
    MOV     A,@C_SaveEp_UpCode      ; 1 - �������ν�����
    JMP     PresetSaveEp
;************************************************
; �����ѵĽ����룬׼������
ConfigRcv_RxChannel1:   
    MOV     A,@C_EpAddr_RxChannel
    CALL    SetEpParamCh0
    MOV     A,@C_ReadEp_Cfg_RxChannel   ; 2 - ���Լ������� 4B
    JMP     PresetReadEp            

ConfigRcv_SetNode:                  ; ���ýڵ�
ConfigRcv_SetSW:                    ; ���ÿ�����Ϣ
    INC     RF_InfoType
    JMP     _SetTxDataEnd
;�������
ConfigRcv_SaveSW:                   ; ���ÿ�����Ϣ�����濪����Ϣ
    INC     ChannelNums
    CALL    SetEpParam_ChannelNums
    MOV     A,@C_SaveEp_SWNodeKey   ; 2 - ���濪����Ϣ2B
    JMP     PresetSaveEp

ConfigRcv_SaveMyNode:
    MOV     A,RF_MyNode
    MOV     ChannelNums,A
    JMP     ConfigRcv_NumsChange    ; ChannelNums ���ˣ�ȥ����

ConfigRcv_SaveTxChannelNums:        ; ChannelNums ��1�ˣ������û���ظ���������ظ����ٲ����棬�ɹ�����
    MOV     A,@2
    SUB     A,ChannelNums
    JBS     StatusReg,CarryFlag
    JMP     ConfigRcv_NumsChange    ; ChannelNums <2 ,ֱ�ӱ��棬���ظ�

    CALL    SetEpParam_ChannelNums
    MOV     A,@C_ReadEp_TxCodeSwInfo; ���±�������ݶ��� RF_Data������,���Ƚ�
    JMP     PresetReadEp

ConfigRcv_ChkDataRecover:
    MOV     A,ChannelNums
    MOV     RF_InfoType,A           ; ChannelNums��ʱ����

    DEC     ChannelNums             ; ������һ������ǰ��Ƚ�
    BC      TRFlagReg,F_FindSame    ;
_CompareNext:
    CALL    SetEpParam_ChannelNums
;    JMP     PresetCompEp
;//MARK: EPROM �Ƚ����ݽ���
PresetCompEp:
    MOV     A,@C_CompEpromData
    MOV     TRMode,A
    CALL    SetWriteEpWaitTime
CompEpromData:
    MOV     A,Buf_EpAddr
    MOV     PrgTmp2,A
    MOV     A,Buf_RamAddr
    MOV     RamSelReg,A
    MOV     A,Buf_RamSize
    MOV     PrgTmp1,A
    CALL    I2C_CompPageData
    JBS     StatusReg,CarryFlag
    JMP     _CompareEnd                         ; EPROM �������Ʋ���

    DJZA    QuitTime
    JMP     main   
    JMP     _ReadFailTable

_CompareEnd:                                    ; һ�����ݱȽϽ���
    JBC     TRFlagReg,F_FindSame
    JMP     FlashSucess                         ; ��������ͬ�ģ������� Nums,Nums���仯

    DJZ     ChannelNums
    JMP     _CompareNext

    MOV     A,RF_InfoType
    MOV     ChannelNums,A                       ; �ָ���ʱ��ChannelNums�����б���

ConfigRcv_NumsChange:
    CALL    _ChannelNum_EpTable
    CALL    SetEp_ChannelNums
    MOV     A,@C_SaveEp_ChannelNums
    JMP     PresetSaveEp
;************************************************
;//MARK: ����5���������ҵĽڵ㣬�������νڵ㣬������
IdlePress5Key:
;    MOV     A,@C_TxData_MyNode  ; ���� config ͨ��
    JMP     PresetTxData

_TxMyNode_SetData:              ; �������ݿ�ʼ
    MOV     A,@C_TxData
    CALL    ResetQuitTime_Mode            ; 
;************************************************
;  �����ҵĽ�����
TxData:
    CALL    FLed_SlowBlink
    CALL    ChkKeyDown
    JBS     StatusReg,CarryFlag
    JMP     WaitTimeOverLedOff            ; ����3���˳�����ʱ�˳� 

    MOV     A,@C_EpAddr_RxChannel
    CALL    SetEpParamCh0       ; ��ͨ���� 4B
    MOV     A,@C_ReadEp_RxChannel
    JMP     PresetReadEp

_TxMyNode_ReadEp:
    MOV     A,@C_RFType
    MOV     RF_InfoType,A       ; ����RFģʽ
    JMP     _SetTxDataEnd
;************************************************
; ���ݷ�����ɣ�תΪ����ģʽ

_Tx2Rx:
;    MOV     A,@C_Tx2Rx_Code4B
    JMP     PresetTx2Rx

_RxDownCodeEnd:
    MOV     A,@C_RFType+1
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag
    JMP     PresetRxTrans_LedOff                ; ���ʹ�����

    INC     ChannelNums
    CALL    SetEpParam_ChannelNums
    MOV     A,@C_SaveEp_DownCode        ; 3 - �������ν�����
    JMP     PresetSaveEp

_RxDownCodeSaveNum:
    MOV     A,@4
    MOV     SetMode,A  
    JMP     ConfigRcv_SaveTxChannelNums ; ȥ���� TxNums+1,����ظ������� ChannelNums
;************************************************
;//MARK:ResetSystemParam
; IDLEģʽ������3�룬 ���ϵͳ����
ResetSystemParam:
    MOV     A,@C_ConfirmReset
    CALL    ResetQuitTime_Mode
;************************************************
ConfirmReset:
    CALL    FLed_SlowBlink
    CALL    ChkKeyDown
    JBC     StatusReg,CarryFlag
    JMP     PresetRxTrans_LedOff        ; �˳�������ģʽ

    JBS     IntKeyValue,B_KeyDown3s
    JMP     WaitTimeOverLedOff          ; ��ʱ�˵� PresetRxData

    MOV     A,@5
    MOV     SetMode,A
_ConfirmResetNext:
    CALL    _ResetSizeTable
    MOV     PrgTmp1,A
    MOV     A,@RF_Data
    MOV     RamSelReg,A
    CLR     PrgTmp2

    CALL    _RxChannelTable
    MOV     R0,A
    INC     PrgTmp2
    INC     RamSelReg
    DJZ     PrgTmp1
    JMP     $-5
    
    CALL    _ResetAddrTable
    MOV     Buf_EpAddr,A
    CALL    _ResetSizeTable
    MOV     Buf_RamSize,A
    MOV     A,@RF_Data
    MOV     Buf_RamAddr,A

    MOV     A,@C_SaveEp_Reset
    JMP     PresetSaveEp
_ConfirmResetSaveOk:
    DJZ     SetMode
    JMP     _ConfirmResetNext
    JMP     FlashSucess
;************************************************
;//MARK: LedBlink
LedSlowBlink:
    JBS     TRFlagReg,F_500ms
    RET
    BC      TRFlagReg,F_500ms
    MOV     A,@1<<B_LED
    XOR     P_LED,A
    RET

LedQuickBlink:
    JBS     TRFlagReg,F_250ms
    RET
    BC      TRFlagReg,F_250ms
    MOV     A,@1<<B_LED
    XOR     P_LED,A
    RET

;***************************************************
;//TODO: McuReset
McuReset:
    DISI
    CLRRAM
    InitPort20191229

    MOV     A,@C_E2Addr_DevAddr                   ; �� Sleep ���ö��� ChannelNums
    CALL    SetEpParamCh0
    MOV     A,@C_ReadEp_Sleep
    JMP     PresetReadEp
_McuReset_Sleep:
    JBS     RF_Data+2,1
    BS      TRFlagReg,F_EpTRData

;*************************************
FlashSucess:     ; Eprom���棬LED����3�룬����PresetRxData
;*************************************
    MOV     A,@C_WaitBlinkEnd
    MOV     TRMode,A    

    MOV     A,@C_FlashSucessTime
    CALL    SetQuitTime_500ms
;*************************************
WaitBlinkEnd:
    MOV     A,@1<<B_LED
    JBC     TRFlagReg,F_250ms   ; ����
    XOR     P_LED,A
    BC      TRFlagReg,F_250ms
;//MARK: WaitTimeOver
WaitTimeOverLedOff:                 ; �ȴ���ʱ,LEDϨ��
    DJZA    QuitTime
    JMP     main
PresetRxTrans_LedOff:
_RxTimeOverTable:
    BC      P_LED,B_LED
;//MARK:    PresetRxTrans
PresetRxTrans:
    MOV     A,@0xA0
    MOV     I2CAddr,A

    BC      TRFlagReg,F_Config
    CLR     SPI_Mode                ; ת�����ݣ� SPI_Mode = 0

    CLR     TRMode
    CLR     SetMode                 ;  = InfoSN 
    MOV     A,@1
    MOV     KeyTime,A               ;  = MyNode ��ת����Ϣʱʹ�ã��ڴ˳�ʼ��

    CALL    ClearKeyFlag
;    MOV     A,@C_RxData_Trans
    JMP     PresetRxData
;*************************************
TimeSpaceRcv:
    MOV     A,@C_WaitTimeOver
    CALL    WaitTxTime_Mode
WaitTimeOver_NoLed:                 ; �ȴ���ʱ,LED״̬����
    DJZA    QuitTime
    JMP     main
    JMP     PresetRxTrans
;*************************************
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

    DJZA    KeyTime
    MOV     KeyTime,A

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
	KeyVibrate		==		2
	KeyConfirm3s	==		120			;   ������3�������������

	; IntKeyValue		==		KeyBuf3
	; KeyCounter		==		KeyBuf3	+	1
	; KeyDownCounter	==		KeyBuf3	+	2
 	SingleKeyMask 	==    	1<<Key_B
;//TODO: KeyScan
	MOV		A,IntKeyValue
	XOR		A,KeyPort
	AND		A,@SingleKeyMask
	JBC		StatusReg,ZeroFlag
	JMP		_KeyConfirm

	MOV		A,@SingleKeyMask
	XOR		IntKeyValue,A
    MOV     A,@KeyVibrate
    MOV     KeyCounter,A    
    BC		IntKeyValue,B_KeyDown3s			;�����仯�����3�밴����־
    JMP     _KeyEnd
_KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     _KeyDownCount        	

    DJZ     KeyCounter
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

    DJZ     KeyDownCounter
	JMP		_KeyEnd

	BS		IntKeyValue,B_KeyDown3s
_KeyEnd:    
    RET
