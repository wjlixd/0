;    RF24L01    ���Ͷ�ģ��  
;    2020.02,19,   chksum: 50D6,˯��ǰ����24L01 ����ģʽ,����˯��LED��

include	"option.h"
if MCU == 0
include	"ConstDef.h"
include "public.h"
include	"PortDef.h"
else
include	"F734_ConstDef.h"
include "F734_public.h"
include	"F734_PortDef.h"
endif
include	"RamDef.h"
include	"Mini4X8LED.H"
include "macro.h"

    ORG     0
    JMP     McuReset
;************************************************************************
; �ָ�������

_ResetAddrTable:
    DECA    SetMode
    ADD     PC,A
    RETL    @C_E2Addr_Flag
    RETL    @C_E2Addr_MyNode
    RETL    @C_EpAddr_TxChannel
    RETL    @C_EpAddr_TxChannel+0x10

_ResetSizeTable:
    DECA    SetMode
    ADD     PC,A
    RETL    @5          ; ϵͳ����
    RETL    @4          ; ���ղ���
    RETL    @4          ; ���Ͳ���1
    RETL    @4          ; ���Ͳ���2

_ResetParamTable:
    DECA    SetMode
    ADD     PC,A
    JMP     _ResetTable1
    JMP     _ResetTable2
    JMP     _ResetTable3

_ResetTable4:           ; EP = 0x40
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xB1       ; �ŵ��� 01      
    RETL    @0xB2       ; �ŵ��� 02      
    RETL    @0xB3       ; �ŵ��� 03      
    RETL    @0x05       ; RF-CH      

_ResetTable3:           ; EP = 0x30
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xA1       ; �ŵ��� 01      
    RETL    @0xA2       ; �ŵ��� 02      
    RETL    @0xA3       ; �ŵ��� 03      
    RETL    @0x02       ; RF-CH     

_ResetTable2:           ; EP = 0x23
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x01       ; MyNode        RF-CH      
    RETL    @0x02       ; MaxNode       ���ýڵ���
    RETL    @0x01       ; TxChannelNums �����ŵ���
    RETL    @0x02       ; SWNums        ���ÿ�����

_ResetTable1:           ; EP = 0x02
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x00       ; ϵͳ��־λ    
    RETL    @0x34       ; �ŵ��� 01      
    RETL    @0x43       ; �ŵ��� 02      
    RETL    @0x10       ; �ŵ��� 03      
    RETL    @0x00       ; RF-CH      

;************************************************************************
_ConfigKeyChkTable:     ; ������3����Ƿ�Զ̰������м��
    MOV     A,SetMode
    ADD     PC,A
    JMP     _ConfigKeyChk_SetNode
    JMP     _ConfigKeyChkEnd            ; ���� SW INFO����鰴��
    JMP     _ConfigKeyChk_Code

_ConfigTable:
    MOV     A,SetMode
    ADD     PC,A
    JMP     _ConfigRxNode
    JMP     _ConfigTxSWNode
    JMP     _ConfigTxChannelCode

_ChannelNum_EpTable:
    MOV     A,SetMode
    ADD     PC,A
    RETL    @C_E2Addr_MaxNode
    RETL    @C_E2Addr_SWNums
    RETL    @C_E2Addr_TxChannelNums

;*************************************************
;//MARK: дEPROM�ɹ��б�

    C_SaveEp_Reset      ==      00  ;OK
    C_SaveEp_TxCode     ==      01  ;ok
    C_SaveEp_ChannelNums==      02  ;ok
    C_SaveEp_TData      ==      03
    C_SaveEp_RData      ==      04
    C_SaveEp_RNode      ==      05
    C_SaveEp_Flag       ==      06

_SaveSucessTable:
    MOV     A,Ep_Mode
    ADD     PC,A
    JMP     _ConfirmResetSaveOk     ; 00
    JMP     _Config_Save_ChannelNums; 01
    JMP     FlashSucess             ; 02
    JMP     _SetTxData_SaveTData    ; 03
    JMP     _SetRxData_SaveRData    ; 04
    JMP     _SaveRNode              ; 05
    JMP     ConfigRcv_SaveMyNode    ; 06
;*************************************************
;//MARK: дEPROMʧ���б�
; _SaveFailTable:
;     JMP     ChkSlep

;*************************************************
;//MARK: ��EPROM�ɹ��б�
    C_ReadEp_ChannelNums    ==  00  ; ok
    C_ReadEp_RxCode4B       ==  01  ;
    C_ReadEp_Cfg_TxData     ==  02  ; ok
    C_ReadEp_TxCode4B       ==  03  ; ok
    C_READEP_TxChananeNums  ==  04  ;  �� Tx ChannelNums׼��ת��
    C_ReadEp_SWNode         ==  05  ; OK
    C_ReadEp_Sleep          ==  06  ; OK

 
_ReadSucessTable:
    MOV     A,Ep_Mode
    ADD     PC,A
    JMP     _ConfigTable            ;0
    JMP     _RxCode4B               ;1 C_ReadEp_RxCode4B       ==  03
    JMP     _SetTxDataEnd           ;2 
    JMP     _TxCode4B               ;3
    JMP     _IdleChkTxNums          ;4 
    JMP     _SetTxDataEnd           ;5
    JMP     _McuReset_Sleep         ;6


;*************************************************
;//MARK: ��EPROMʧ���б�
; _ReadFailTable:
;     JMP     ChkSlep

;*************************************************
;//MARK: �������� - �б�

    C_TxData_Config     ==  0       ; �����η���������Ϣ
    C_RX2TX_Config      ==  1       ; �յ����ýڵ㣬ת���ͷ���
    C_TxData_SWInfo     ==  2       ; ok ����ת�����ݰ�

; ���ʹ����
_TxCodeAddrTable:                   
    ADD     PC,A
    RETL    @C_E2Addr_Config        ; 
    RETL    @0                      ; 
    RETL    @0                      ;

_SetTxDataTable:
    MOV     A,SPI_Mode              ; ����Ҫ���͵�����
    ADD     PC,A
    JMP     _TxData_SetData         ; 
    JMP     ConfigRcv_SetNode       ;
    JMP     _TxTrans_SetData        ;

; �������ݳɹ�����
_TxDataEndTable:                    
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _TxData2RxData
    JMP     ConfigRcv_SaveFlag 
    JMP     _TxTrans_TxEnd

; ��������ʧ�ܴ���
_TxFailTable:                       
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     QuitToIdle              ; ���� ���ýڵ㣬������Ϣ�����������ŵ� ʧ��
    JMP     QuitToIdle
    JMP     _TxTrans_TxError
;*************************************************
;//MARK: ����ʱ��
    ; ms ������������������ȴ�ʱ�� 1��
    ; ����EProm�ȴ�ʱ��           1��
    ; ��  EProm�ȴ�ʱ��           1��
    C_KeyUpTime     ==      30  ; ms    
    C_WaitEpTime    ==      10 ; ms
    C_Error_OnLedTime==     2  ; ms ���Ϳ�����Ϣ����û�з��ͳɹ�������1��

    ; SPI �������ݵȴ�ʱ�䣬 320ms 
    C_SpiTxTime     ==      30  ; ms

    ; �ȴ��û�����ʱ��  15��
    C_WaitKeyTime   ==      30  ; 0.5s,

    ; �����ɹ�����LEDʱ�� 3��
    C_FlashSucessTime==     6   ; 0.5s
;*************************************************
;//MARK: �������� - �б� 
    C_Tx2Rx_Code4B      ==  0
    C_RxData_Config     ==  1       ; ����������Ϣ
; �������
_RxCodeAddrTable:                   
    ADD     PC,A
    RETL    @0
    RETL    @C_E2Addr_Config    

_RxWaitTimeTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    RETL    @C_QuitTime
    RETL    @1            ; ����ģʽ�ȴ�1��󣬴�����

; ���ճ�ʱ��
_RxTimeOverTable: 
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     QuitToIdle    ; 
    JMP     _RxData_GetData       ; û���յ���Ϣ����������

; �������ݳɹ���
_RxDataEndTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _ConfigRxData           ; ���յ�ת����Ϣ����
    JMP     _RxData_GetData       ;
;*************************************************
DefaultDevAddr:  
    RETL    @0xC0       
_ChannelMaskTable:    
    ADD     PC,A
    RETL    @0B00000001
    RETL    @0B00000011;
    RETL    @0B00000111;
    RETL    @0B00001111;
    RETL    @0B00011111;
    RETL    @0B00111111;


_KeyScanTable:
    ADD     PC,A
    RETL    @0x00       ;0000 0000   ;
    RETL    @0x00       ;0000 0001   ;
    RETL    @0x00       ;0000 0010   ;
    RETL    @0x00       ;0000 0011   ;
    RETL    @0x01       ;0000 0100   ; 1
    RETL    @0x03       ;0000 0101   ; 3
    RETL    @0x00       ;0000 0110   ;
    RETL    @0x00       ;0000 0111   ;
    RETL    @0x02       ;0000 1000   ; 2
    RETL    @0x00       ;0000 1001   ;
    RETL    @0x04       ;0000 1010   ; 4
    RETL    @0x00       ;0000 1011   ;
    RETL    @0x00       ;0000 1100   ;
    RETL    @0x00       ;0000 1101   ;
    RETL    @0x00       ;0000 1110   ;
    RETL    @0x00       ;0000 1111   ;


_Ep_NumsTable:
    MOV     A,SetMode
    ADD     PC,A
    RETL    @C_E2Addr_MaxNode       ; ���ýڵ㣬
    RETL    @C_E2Addr_SWNums        ; ���ÿ���
    RETL    @C_E2Addr_TxChannelNums ; TxChannel

GetMaxNums:
    MOV     A,SetMode
    ADD     PC,A
    RETL    @C_MaxCH
    RETL    @C_MaxSWNum
    RETL    @C_MaxChannel
GetInfoType:
    MOV     A,SetMode
    ADD     PC,A
    RETL    @C_NodeType
    RETL    @C_SWType
    RETL    @C_RFType

_ConfigSetTxData:
    MOV     A,SetMode
    ADD     PC,A
    JMP     SetTX_Node
    JMP     SetTx_SW
    JMP     SetTx_MyChannel

_TxDataSaveTable:
    MOV     A,SetMode
    ADD     PC,A
    JMP     _Config_SaveNode    ; ���ýڵ㣬�������ڵ�
    JMP     FlashSucess         ; ���ÿ��أ����ñ�������
    JMP     _Config_SaveTxCode  ; TxChannel�����淵������

;******************************************
main:
    WDTC
    CALL    SoftTimer

    C_IdleModeCode      ==  0 
    C_ConfirmReset      ==  1 
    C_WaitBlinkEnd      ==  2 
    C_WaitTimeOver      ==  3 
    C_PreTxData         ==  4 
    C_TxData            ==  5 
    C_SaveEpromData     ==  6 
    C_ReadEpromData     ==  7 
    C_WaitRx2TxEnd      ==  8 
    C_WaitTxDataEnd     ==  9 
    C_WaitRxDataReturn  ==  10 


;//TODO: main
_mainTable:    
    MOV     A,TRMode
    ADD     PC,A
    JMP     IdleModeCode            ;0 
    JMP     ConfirmReset            ;1 
    JMP     WaitBlinkEnd            ;2  
    JMP     WaitTimeOver            ;3 
    JMP     PreTxData               ;4  
    JMP     TxData                  ;5  ��һ�μ��������ҵĽڵ���Ϣ
    JMP     SaveEpromData           ;6 
    JMP     ReadEpromData           ;7 
    JMP     WaitRx2TxEnd            ;8  ����ģʽת��Ϊ����ģʽ���ȴ�32ms
    JMP     WaitTxDataEnd           ;9  �ȴ�������ɣ�IRQ=0 ʱ���������
    JMP     WaitRxDataReturn        ;10 �ȴ��������ݣ�IRQ=0 �����յ�����


include "com.asm"
;************************************************
GetKeyValue:
    CALL    ClearKeyFlag
    MOV     A,IntKeyValue
    AND     A,@C_KeyValueMask
    RET
;************************************************
;//MARK: IdleModeCode
IdleModeCode:
    CALL    ChkKeyDown
    JBS     StatusReg,CarryFlag
    JMP     _IdleChkKey3s

    CALL    SetEp_TxChannelNums         ; tx Nums ����EP��ַ
    MOV     A,@C_READEP_TxChananeNums
    JMP     PresetReadEp
_IdleChkTxNums:                         ; Tx Nums ���� ChannelNums��
    MOV     A,@C_MaxChannel
    SUB     A,ChannelNums
    JBC     StatusReg,CarryFlag
    JMP     QuitToIdle                  ; �ŵ�������6��������

    MOV     A,ChannelNums
    JBC     StatusReg,ZeroFlag
    JMP     QuitToIdle                  ; û���ù��� TX �ŵ���Ϊ0

    CLR     ErrorCnt
_IdleNextTxChannel:
;************** ���͹��� *************************************************
    MOV     A,@C_TxData_SWInfo
    JMP     PresetTxNums                ; ���� ChannelNums ���÷��Ͳ��� A

_TxTrans_SetData:                       ; ����������ݰ�                B
    MOV     A,@0xFF                     ; ��������InfoSN����
    MOV     RF_MaxNode,A
    MOV     A,@C_KeyNodeType            ; ������������
    MOV     RF_InfoType,A
    CALL    GetKeyValue
    MOV     SW_KeyValue,A               ; ���ͼ�ֵ
    CALL    SetEp_SWNode
    MOV     A,@C_ReadEp_SWNode          ; ��MyNode ���� SWNode ��       C
    JMP     PresetReadEp                ; Ȼ�������ݰ�,�ȴ����ͽ��   

_TxTrans_TxError:
    INC     ErrorCnt                    ; �����ʱ�������   ��ʧ��   - D
_TxTrans_TxEnd:
    DJZ     ChannelNums                 ;                  ���ͳɹ�   - D
    JMP     _IdleNextTxChannel
;*************************************************************************
    MOV     A,ErrorCnt
    JBC     StatusReg,ZeroFlag
    JMP     QuitToIdle                  ; ����ȫ�����ͳɹ�

    BS      P_LED,B_LED                 ; ���Ͳ��ֳɹ���LED�� 30ms
    MOV     A,@C_WaitTimeOver
    MOV     TRMode,A
    MOV     A,@C_Error_OnLedTime
    CALL    SetQuitTime_ms
    JMP     main
;*************************************************************************



;*************************************************************************
;  ��ʱ���򳤰����˳�
Key3sTimeoutToIdle:                 ; ����3���˳�����ʱ�˳�
    JBS     IntKeyValue,B_KeyDown3s
    JMP     WaitTimeOver
;//MARK:  QuitToIdle   
QuitToIdle:
    BC      P_LED,B_LED
    CALL    SetKeyUpTime        ; ����˯�ߵȴ�ʱ��
_SaveFailTable:
_ReadFailTable:    
    CLR     TRMode
    CALL    ClearKeyFlag
ChkSlep:    
    DJZA    QuitTime
    JMP     main
    JBS     IntKeyValue,B_KeyUp
    JMP     main
    JBS     TRFlagReg,F_EnSlep
    JMP     main

    JBS     TRFlagReg,F_DisSlepLed
    BS      P_LED,B_LED

    BC      P_CE,B_CE
    MOV     A,@0x00                 ; ����ģʽ
    CALL    SetSPI_CONFIG
;//MARK: Slep˯�� 
    BC      P_COL1,B_COL1           ; ����0�����հ�������

    M_Sleep

    MOV     A,@0x3F                 ; ����1ģʽ
    CALL    SetSPI_CONFIG

    JBS     TRFlagReg,F_DisSlepLed
    BC      P_LED,B_LED

    JMP     QuitToIdle    
;******************************************************** 
;//TODO: SetEp ����EP��ַ
SetEp_MaxNode:
    MOV     A,@RF_MaxNode
    MOV     Buf_RamAddr,A
    MOV     A,@C_E2Addr_MaxNode
    JMP     SetEp_1Byte    

SetEp_SWNode:
    MOV     A,@SW_Node
    JMP     $+2
SetEp_MyNode:
    MOV     A,@RF_MyNode
    MOV     Buf_RamAddr,A
    MOV     A,@C_E2Addr_MyNode

;************************************************
;[ A ] - eprom��ַ
; RamSelReg
SetEp_1Byte:
    MOV     Buf_EpAddr,A
    MOV     A,@1
    MOV     Buf_RamSize,A
    RET
;************************************************
;  ���� ChannelNums ���� Ep TxChannel code ��ַ - 4B
SetEpParam_TxCode:
    SWAPA   ChannelNums
    ADD     A,@C_EpAddr_TxChannel-0x10
;//TODO: SetEpParamCh0
SetEpParamCh0:
    MOV     Buf_EpAddr,A
    MOV     A,@C_ChannelSize        ;+1
    MOV     Buf_RamSize,A           ;+2
    MOV     A,@RF_Data
    MOV     Buf_RamAddr,A
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
SetEp_TxChannelNums:
    MOV     A,@C_E2Addr_TxChannelNums
; ���ð� Eprom ��ַ��д�� ChannelNums - 1B ��  
SetEp_ChannelNums:
    MOV     Buf_EpAddr,A                ; +0
    MOV     A,@ChannelNums              ; +1
    MOV     Buf_RamAddr,A               ; +2
    MOV     A,@1                        ; +3
    MOV     Buf_RamSize,A
    RET
;************************************************
ClrFailFlag:
    BC      EpNum,F_TFail
    BC      EpNum,F_RFail
    RET
;************************************************



;************************************************
_IdleChkKey3s:
    JBS     IntKeyValue,B_KeyDown3s
    JMP     ChkSlep
; ��������ǰ׼��
; Pre_TxData:
    CALL    GetKeyValue
    MOV     SetMode,A                   ; ��������ģʽ
    XOR     A,@C_KeyValueRst
    JBC     StatusReg,ZeroFlag
    JMP     ResetSystemParam            ; 

    CALL    _ChannelNum_EpTable
    CALL    SetEp_ChannelNums
    MOV     A,@C_ReadEp_ChannelNums     ; 1 - MyNode/SWNums/TxNums����ChannelNums
    JMP     PresetReadEp

; _ReadChannelNumsOk:                   ; ����3�룬 K1 - �������ģʽ������MyNode ���յ�MyNode�󷵻���Ϣ����ȷ�󱣴�MyNode
;     JMP     _ConfigTable              ;  K2 ��һ�� K1 - �������ýڵ㣬 

;*****************************************************
; ����� ChannelNums , SetMode = 0
_ConfigRxNode:                          ; û����ʱ���������� MyNode ģʽ
    MOV     A,@C_RxData_Config
    JMP     PresetRxData                ; ����ģʽ������config������ --A
_RxData_GetData:
    MOV     A,@C_PreTxData              ;  �ȴ� 15��
    CALL    ResetQuitTime_Mode          ; 
PreTxData:
    JBC     P_IRQ,B_IRQ
    JMP     TxData

    CALL    ReadSpiData                 ; ��SPI������������

    BC      EpNum,F_RFail
    CALL    SetEp_RData
    MOV     A,@C_SaveEp_RNode           ;�����������
    JBC     TRFlagReg,F_EpTRData
    JMP     PresetSaveEp
_SaveRNode:

    MOV     A,@C_NodeType
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag          ; ���յ� ���ýڵ�
    JMP     QuitToIdle
;************************************************
;  ���ؽ��յ�������
    MOV     A,@C_RX2TX_Config           ; RX to TX
    JMP     PresetRx2Tx
ConfigRcv_SetNode:
    INC     RF_InfoType
    JMP     _SetTxDataEnd

ConfigRcv_SaveFlag:
    BS      TRFlagReg,F_DisSetNode      ; ����־����EPROM
    MOV     A,TRFlagReg
    MOV     ChannelNums,A
    MOV     A,@C_E2Addr_Flag
    CALL    SetEp_ChannelNums
    MOV     A,@C_SaveEp_Flag
    JMP     PresetSaveEp

ConfigRcv_SaveMyNode:
    MOV     A,RF_MaxNode
    MOV     ChannelNums,A
    MOV     A,@C_E2Addr_MyNode
    JMP     _Config_Save_ChannelNums+1  ; MyNode - ChannelNum - ����EP
;************************************************
; ����� ChannelNums , SetMode = 1,2
_ConfigTxChannelCode:                   ; �����ҵ��ŵ���
_ConfigTxSWNode:                        ; ���Ϳ�����
    MOV     A,@C_TxData
    CALL    ResetQuitTime_Mode          ; 
TxData:
    CALL    FLed_SlowBlink
    CALL    ChkKeyDown
    JBS     StatusReg,CarryFlag
    JMP     Key3sTimeoutToIdle          ; ����3���˳�����ʱ�˳� 

    JMP     _ConfigKeyChkTable

_ConfigKeyChk_SetNode:
    JBC     TRFlagReg,F_DisSetNode
    JMP     QuitToIdle
_ConfigKeyChk_Code:
    CALL    GetKeyValue
    XOR     A,SetMode
    JBS     StatusReg,ZeroFlag
    JMP     QuitToIdle

_ConfigKeyChkEnd:
    CALL    GetMaxNums
    SUB     A,ChannelNums
    JBC     StatusReg,CarryFlag
    JMP     QuitToIdle                  ; TxChannelNum >=5 ,���������ã�ֱ���˳�
; ����3�룬�ٶ̰����󣬽��룬 ����TX����ģʽ          **** A ****
    MOV     A,@C_TxData_Config          ; ���� config ͨ��
    JMP     PresetTxData
_TxData_SetData:                        ; �������ݿ�ʼ
    CALL    GetInfoType
    MOV     RF_InfoType,A
    JMP     _ConfigSetTxData            ; ��䷢�����ݰ� ,�ȴ��������
;************************************************
; ������ݰ����֣� ��SetMode ȷ����������             **** B ****
;//MARK: SetTX_Node ���ýڵ�
SetTX_Node:     ; �������ڵ�Ÿ����ն�
    CALL    SetEp_MaxNode               ; ���� ���ڵ�ֵ
    JMP     $+4
;//MARK: SetTx_SW ���ÿ�����Ϣ
SetTx_SW:       ; ���� �ҵĽڵ�ţ���ֵ
    CALL    GetKeyValue
    MOV     RF_KeyValue,A               ; ���ü�ֵ
    CALL    SetEp_MyNode

    MOV     A,@C_ReadEp_Cfg_TxData
    JMP     PresetReadEp

;//���÷����ŵ���ֻ��Ҫ������
SetTx_MyChannel:
    MOV     A,@0xFF                     ; ���ؽڵ㣬�����ͣ����շ����յ� FF��������
    MOV     RF_MaxNode,A                ;
    JMP     _SetTxDataEnd
;************************************************  ���ݰ���ɣ��������ݣ��ȴ����ͽ���
_TxData2RxData:                         ;ת��Ϊ����ģʽ**** C ****
    MOV     A,@C_Tx2Rx_Code4B
    JMP     PresetTx2Rx                 ; R1 ������ɣ�תΪ����ģʽ

_ConfigRxData:                          ; �յ�������Ϣ 
    CALL    GetInfoType                 ; �������ͼ�� **** D ****
    ADD     A,@1
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag
    JMP     QuitToIdle                  ; ���ʹ�����
    JMP     _TxDataSaveTable            ; ������ͬ������
;************************************************
;��ͬ���������ͣ��ֱ���                            **** E ****
_Config_SaveTxCode:                     ; ���� SetMode = 2 ,���������ŵ���
    INC     ChannelNums
    CALL    SetEpParam_TxCode

    MOV     A,@C_SaveEp_TxCode   ; дEP��� ��WaitWriteTxNum
    JMP     PresetSaveEp
                                        ; ���� SetMode = 1 ,���ÿ��ؽڵ㣬���ݲ����棬NUMS�����棬ֱ��ת �ɹ� **** G ****
_Config_SaveNode:                       ; ���� SetMode = 0 ,���ýڵ�+1��׼������
    INC     ChannelNums

_Config_Save_ChannelNums:               ; 
    CALL    _ChannelNum_EpTable
    CALL    SetEp_ChannelNums
    MOV     A,@C_SaveEp_ChannelNums     ;              **** F **** ���� ChannelNums ��ת�ɹ� **** G ****
    JMP     PresetSaveEp
;************************************************
;  ���Ͷˣ�  ϵͳ������ʼ��
;         RxChannelNums = 0
;         TxChannelNums = 0
;         MyNode        = 1
;         MaxNode       = 2
;************************************************
;//TODO: ResetSystemParam
ResetSystemParam:
    MOV     A,@C_ConfirmReset
    CALL    ResetQuitTime_Mode
;************************************************
ConfirmReset:
    CALL    FLed_SlowBlink
    CALL    ChkKeyDown
    JBC     StatusReg,CarryFlag
    JMP     QuitToIdle                  ; �˳�������ģʽ

    JBS     IntKeyValue,B_KeyDown3s
    JMP     WaitTimeOver                ; ��ʱ�˵� PresetRxData

    CALL    GetKeyValue
    XOR     A,@C_KeyValueRst
    JBS     StatusReg,ZeroFlag
    JMP     QuitToIdle

    MOV     A,@4
    MOV     SetMode,A
_ConfirmResetNext:
    CALL    _ResetSizeTable
    MOV     PrgTmp1,A
    MOV     A,@RF_Data
    MOV     RamSelReg,A
    CLR     PrgTmp2

    CALL    _ResetParamTable
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

; ;************************************************
;***************************************************
;    1A 2B 3C 4D 5E 09 CB
;     |           |  |  +---------- CHKSUM 
;     |           |  +------------- �ŵ���  RF_Data
;     +-----------+---------------- ��ַ��Ϣ   
;//TODO:  SetTRAddrParam - ���õ�ַ����
;******************************************
;//TODO: SetSPIDataParam -  ���� SPI д���ݳ��� 
SetSPIDataParam:
    MOV     A,@PLOAD_WIDTH_SET
    JMP     $+2
SetTRAddrParam:                 ; 5���ֽ�
    MOV     A,@TX_ADR_WIDTH
    MOV     PrgTmp1,A

    MOV     A,@RF_Data
    MOV     RamSelReg,A
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
    JBC     RF_Data+1,0
    BS      TRFlagReg,F_EnSlep

    JBS     RF_Data+1,1
    BS      TRFlagReg,F_EpTRData

    JBC     RF_Data+1,2
    BS      TRFlagReg,F_DisSlepLed

    JBC     RF_Data+2,F_DisSetNode
    BS      TRFlagReg,F_DisSetNode
    JMP     QuitToIdle

;*************************************
;//TODO: SoftTimer
SoftTimer:
    MOV     A,TCC
    XOR     A,SystemFlag
    AND     A,@1<<F_16ms
    JBC     StatusReg,ZeroFlag
    RET
    XOR     SystemFlag,A

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
    BS      SystemFlag,F_32ms

    JBS     TRFlagReg,F_QuitTime32ms
    JMP     $+3
    DJZA    QuitTime                    ; QuitTime =1 ʱֹͣ��
    MOV     QuitTime,A

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
	KeyVibrate		==		4
	KeyConfirm3s	==		120			;   ������3�������������
	B_Key1			==		0
	B_Key2          ==      1
	B_Key3          ==      2
	B_Key4          ==      3
	; IntKeyValue		==		KeyBuf3
	; KeyCounter		==		KeyBuf3	+	1
	; KeyDownCounter	==		KeyBuf3	+	2
 
;//TODO: KeyScan
    CLR     PrgTmp1
    BS      P_COL1,B_COL1
    JBS     P_ROW1,B_ROW1
    BS      PrgTmp1,B_Key1
    JBS     P_ROW2,B_ROW2
    BS      PrgTmp1,B_Key2

    BC      P_COL1,B_COL1    
    JBS     P_ROW1,B_ROW1
    BS      PrgTmp1,B_Key3
    JBS     P_ROW2,B_ROW2
    BS      PrgTmp1,B_Key4                  ; ���ɨ���ֵ������ PrgTmp1��

    MOV     A,PrgTmp1
    CALL    _KeyScanTable
    MOV     PrgTmp1,A                       ;��ǰɨ����
    SWAP    PrgTmp1

    MOV     A,IntKeyValue
    AND     A,@C_ScanCodeMask               ; ���ϴε�ɨ��ֵ�Ƚ�
    XOR     A,PrgTmp1
	JBC		StatusReg,ZeroFlag
	JMP		_KeyConfirm

    MOV     A,@~C_ScanCodeMask              ; �����ı��ˣ������ֵ
    AND     IntKeyValue,A
    MOV     A,PrgTmp1
    OR      IntKeyValue,A

    MOV     A,@KeyVibrate
    MOV     KeyCounter,A    
    BC		IntKeyValue,B_KeyDown3s			;�����仯�����3�밴����־
    JMP     _KeyEnd
_KeyConfirm:
    MOV     A,KeyCounter
    JBC     StatusReg,ZeroFlag
    JMP     _KeyDownCount        	

    DEC     KeyCounter
    JBS     StatusReg,ZeroFlag
    JMP     _KeyEnd

    MOV     A,PrgTmp1
	JBC		StatusReg,ZeroFlag
	JMP		_KeyUp

    BS      IntKeyValue,B_KeyDown
	BC		IntKeyValue,B_KeyUp
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A

    MOV     A,@~C_KeyValueMask              ; �����ı��ˣ������ֵ
    AND     IntKeyValue,A
    SWAP    PrgTmp1
    DECA    PrgTmp1
    OR      IntKeyValue,A
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
    RET

ifdef EMUP
    BC      P_CE,B_CE               ; ������
    CLR     PrgTmp2

    MOV     A,@7
    CALL    TesetReadRW

    MOV     A,@3
    CALL    TesetReadRW

    INC     PrgTmp1
    MOV     A,@0x17
    MOV     PrgTmp2,A
    CALL    TesetReadRW+3

    JMP     $

TesetReadRW:
    MOV     PrgTmp1,A
    MOV     A,@RF_Data
    MOV     RamSelReg,A

    MOV     A,PrgTmp2
    BC      P_CSN,B_CSN    
    CALL    SPI_WRITEBYTE
    CALL    SPI_READBYTE
    BS      P_CSN,B_CSN
    MOV     R0,A    
    INC     RamSelReg
    INC     PrgTmp2
    DJZ     PrgTmp1
    JMP     $-9
    RET
endif


