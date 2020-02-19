;    RF24L01    发送端模块  
;    2020.02,19,   chksum: 50D6,睡眠前设置24L01 掉电模式,增加睡眠LED亮

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
; 恢复参数表

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
    RETL    @5          ; 系统参数
    RETL    @4          ; 接收参数
    RETL    @4          ; 发送参数1
    RETL    @4          ; 发送参数2

_ResetParamTable:
    DECA    SetMode
    ADD     PC,A
    JMP     _ResetTable1
    JMP     _ResetTable2
    JMP     _ResetTable3

_ResetTable4:           ; EP = 0x40
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xB1       ; 信道码 01      
    RETL    @0xB2       ; 信道码 02      
    RETL    @0xB3       ; 信道码 03      
    RETL    @0x05       ; RF-CH      

_ResetTable3:           ; EP = 0x30
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xA1       ; 信道码 01      
    RETL    @0xA2       ; 信道码 02      
    RETL    @0xA3       ; 信道码 03      
    RETL    @0x02       ; RF-CH     

_ResetTable2:           ; EP = 0x23
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x01       ; MyNode        RF-CH      
    RETL    @0x02       ; MaxNode       设置节点数
    RETL    @0x01       ; TxChannelNums 发送信道数
    RETL    @0x02       ; SWNums        设置开关数

_ResetTable1:           ; EP = 0x02
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x00       ; 系统标志位    
    RETL    @0x34       ; 信道码 01      
    RETL    @0x43       ; 信道码 02      
    RETL    @0x10       ; 信道码 03      
    RETL    @0x00       ; RF-CH      

;************************************************************************
_ConfigKeyChkTable:     ; 长按键3秒后，是否对短按键进行检查
    MOV     A,SetMode
    ADD     PC,A
    JMP     _ConfigKeyChk_SetNode
    JMP     _ConfigKeyChkEnd            ; 设置 SW INFO不检查按键
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
;//MARK: 写EPROM成功列表

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
;//MARK: 写EPROM失败列表
; _SaveFailTable:
;     JMP     ChkSlep

;*************************************************
;//MARK: 读EPROM成功列表
    C_ReadEp_ChannelNums    ==  00  ; ok
    C_ReadEp_RxCode4B       ==  01  ;
    C_ReadEp_Cfg_TxData     ==  02  ; ok
    C_ReadEp_TxCode4B       ==  03  ; ok
    C_READEP_TxChananeNums  ==  04  ;  读 Tx ChannelNums准备转发
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
;//MARK: 读EPROM失败列表
; _ReadFailTable:
;     JMP     ChkSlep

;*************************************************
;//MARK: 发送数据 - 列表

    C_TxData_Config     ==  0       ; 向下游发送设置信息
    C_RX2TX_Config      ==  1       ; 收到设置节点，转发送返回
    C_TxData_SWInfo     ==  2       ; ok 发送转发数据包

; 发送代码表
_TxCodeAddrTable:                   
    ADD     PC,A
    RETL    @C_E2Addr_Config        ; 
    RETL    @0                      ; 
    RETL    @0                      ;

_SetTxDataTable:
    MOV     A,SPI_Mode              ; 设置要发送的数据
    ADD     PC,A
    JMP     _TxData_SetData         ; 
    JMP     ConfigRcv_SetNode       ;
    JMP     _TxTrans_SetData        ;

; 发送数据成功后处理
_TxDataEndTable:                    
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _TxData2RxData
    JMP     ConfigRcv_SaveFlag 
    JMP     _TxTrans_TxEnd

; 发送数据失败处理
_TxFailTable:                       
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     QuitToIdle              ; 发送 设置节点，开关信息，请求下游信道 失败
    JMP     QuitToIdle
    JMP     _TxTrans_TxError
;*************************************************
;//MARK: 设置时间
    ; ms 按键弹起计数按键数等待时间 1秒
    ; 保存EProm等待时间           1秒
    ; 读  EProm等待时间           1秒
    C_KeyUpTime     ==      30  ; ms    
    C_WaitEpTime    ==      10 ; ms
    C_Error_OnLedTime==     2  ; ms 发送开关信息，有没有发送成功，亮灯1秒

    ; SPI 发送数据等待时间， 320ms 
    C_SpiTxTime     ==      30  ; ms

    ; 等待用户按键时间  15秒
    C_WaitKeyTime   ==      30  ; 0.5s,

    ; 操作成功，闪LED时间 3秒
    C_FlashSucessTime==     6   ; 0.5s
;*************************************************
;//MARK: 接收数据 - 列表 
    C_Tx2Rx_Code4B      ==  0
    C_RxData_Config     ==  1       ; 接收设置信息
; 接收码表
_RxCodeAddrTable:                   
    ADD     PC,A
    RETL    @0
    RETL    @C_E2Addr_Config    

_RxWaitTimeTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    RETL    @C_QuitTime
    RETL    @1            ; 接收模式等待1秒后，处理按键

; 接收超时表
_RxTimeOverTable: 
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     QuitToIdle    ; 
    JMP     _RxData_GetData       ; 没接收到信息，按键处理

; 接收数据成功表
_RxDataEndTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _ConfigRxData           ; 接收到转发信息处理
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
    RETL    @C_E2Addr_MaxNode       ; 设置节点，
    RETL    @C_E2Addr_SWNums        ; 设置开关
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
    JMP     _Config_SaveNode    ; 设置节点，保存最大节点
    JMP     FlashSucess         ; 设置开关，不用保存数据
    JMP     _Config_SaveTxCode  ; TxChannel，保存返回数据

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
    JMP     TxData                  ;5  按一次键，发送我的节点信息
    JMP     SaveEpromData           ;6 
    JMP     ReadEpromData           ;7 
    JMP     WaitRx2TxEnd            ;8  接收模式转换为发送模式，等待32ms
    JMP     WaitTxDataEnd           ;9  等待发送完成，IRQ=0 时，发送完成
    JMP     WaitRxDataReturn        ;10 等待接收数据，IRQ=0 ，则收到数据


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

    CALL    SetEp_TxChannelNums         ; tx Nums 设置EP地址
    MOV     A,@C_READEP_TxChananeNums
    JMP     PresetReadEp
_IdleChkTxNums:                         ; Tx Nums 读到 ChannelNums中
    MOV     A,@C_MaxChannel
    SUB     A,ChannelNums
    JBC     StatusReg,CarryFlag
    JMP     QuitToIdle                  ; 信道数超过6个，出错

    MOV     A,ChannelNums
    JBC     StatusReg,ZeroFlag
    JMP     QuitToIdle                  ; 没设置过， TX 信道数为0

    CLR     ErrorCnt
_IdleNextTxChannel:
;************** 发送过程 *************************************************
    MOV     A,@C_TxData_SWInfo
    JMP     PresetTxNums                ; 根据 ChannelNums 设置发送参数 A

_TxTrans_SetData:                       ; 接着填充数据包                B
    MOV     A,@0xFF                     ; 请求下游InfoSN增加
    MOV     RF_MaxNode,A
    MOV     A,@C_KeyNodeType            ; 发送数据类型
    MOV     RF_InfoType,A
    CALL    GetKeyValue
    MOV     SW_KeyValue,A               ; 发送键值
    CALL    SetEp_SWNode
    MOV     A,@C_ReadEp_SWNode          ; 把MyNode 读到 SWNode ，       C
    JMP     PresetReadEp                ; 然后发送数据包,等待发送结果   

_TxTrans_TxError:
    INC     ErrorCnt                    ; 溢出超时错误计数   送失败   - D
_TxTrans_TxEnd:
    DJZ     ChannelNums                 ;                  发送成功   - D
    JMP     _IdleNextTxChannel
;*************************************************************************
    MOV     A,ErrorCnt
    JBC     StatusReg,ZeroFlag
    JMP     QuitToIdle                  ; 发送全部发送成功

    BS      P_LED,B_LED                 ; 发送部分成功，LED亮 30ms
    MOV     A,@C_WaitTimeOver
    MOV     TRMode,A
    MOV     A,@C_Error_OnLedTime
    CALL    SetQuitTime_ms
    JMP     main
;*************************************************************************



;*************************************************************************
;  超时，或长按键退出
Key3sTimeoutToIdle:                 ; 长按3秒退出，超时退出
    JBS     IntKeyValue,B_KeyDown3s
    JMP     WaitTimeOver
;//MARK:  QuitToIdle   
QuitToIdle:
    BC      P_LED,B_LED
    CALL    SetKeyUpTime        ; 设置睡眠等待时间
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
    MOV     A,@0x00                 ; 掉电模式
    CALL    SetSPI_CONFIG
;//MARK: Slep睡眠 
    BC      P_COL1,B_COL1           ; 按键0，接收按键唤醒

    M_Sleep

    MOV     A,@0x3F                 ; 待机1模式
    CALL    SetSPI_CONFIG

    JBS     TRFlagReg,F_DisSlepLed
    BC      P_LED,B_LED

    JMP     QuitToIdle    
;******************************************************** 
;//TODO: SetEp 设置EP地址
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
;[ A ] - eprom地址
; RamSelReg
SetEp_1Byte:
    MOV     Buf_EpAddr,A
    MOV     A,@1
    MOV     Buf_RamSize,A
    RET
;************************************************
;  根据 ChannelNums 设置 Ep TxChannel code 地址 - 4B
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
; 设置把 Eprom 地址读写到 ChannelNums - 1B 中  
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
; 发送数据前准备
; Pre_TxData:
    CALL    GetKeyValue
    MOV     SetMode,A                   ; 保存设置模式
    XOR     A,@C_KeyValueRst
    JBC     StatusReg,ZeroFlag
    JMP     ResetSystemParam            ; 

    CALL    _ChannelNum_EpTable
    CALL    SetEp_ChannelNums
    MOV     A,@C_ReadEp_ChannelNums     ; 1 - MyNode/SWNums/TxNums读到ChannelNums
    JMP     PresetReadEp

; _ReadChannelNumsOk:                   ; 长按3秒， K1 - 进入接收模式，设置MyNode ，收到MyNode后返回信息，正确后保存MyNode
;     JMP     _ConfigTable              ;  K2 按一键 K1 - 发送设置节点， 

;*****************************************************
; 读完成 ChannelNums , SetMode = 0
_ConfigRxNode:                          ; 没按键时，进行设置 MyNode 模式
    MOV     A,@C_RxData_Config
    JMP     PresetRxData                ; 接收模式，设置config参数后 --A
_RxData_GetData:
    MOV     A,@C_PreTxData              ;  等待 15秒
    CALL    ResetQuitTime_Mode          ; 
PreTxData:
    JBC     P_IRQ,B_IRQ
    JMP     TxData

    CALL    ReadSpiData                 ; 从SPI缓冲区读数据

    BC      EpNum,F_RFail
    CALL    SetEp_RData
    MOV     A,@C_SaveEp_RNode           ;保存测试数据
    JBC     TRFlagReg,F_EpTRData
    JMP     PresetSaveEp
_SaveRNode:

    MOV     A,@C_NodeType
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag          ; 接收到 设置节点
    JMP     QuitToIdle
;************************************************
;  返回接收到的数据
    MOV     A,@C_RX2TX_Config           ; RX to TX
    JMP     PresetRx2Tx
ConfigRcv_SetNode:
    INC     RF_InfoType
    JMP     _SetTxDataEnd

ConfigRcv_SaveFlag:
    BS      TRFlagReg,F_DisSetNode      ; 将标志保存EPROM
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
    JMP     _Config_Save_ChannelNums+1  ; MyNode - ChannelNum - 保存EP
;************************************************
; 读完成 ChannelNums , SetMode = 1,2
_ConfigTxChannelCode:                   ; 发送我的信道码
_ConfigTxSWNode:                        ; 发送开关码
    MOV     A,@C_TxData
    CALL    ResetQuitTime_Mode          ; 
TxData:
    CALL    FLed_SlowBlink
    CALL    ChkKeyDown
    JBS     StatusReg,CarryFlag
    JMP     Key3sTimeoutToIdle          ; 长按3秒退出，超时退出 

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
    JMP     QuitToIdle                  ; TxChannelNum >=5 ,不能再设置，直接退出
; 长按3秒，再短按键后，进入， 设置TX数据模式          **** A ****
    MOV     A,@C_TxData_Config          ; 设置 config 通道
    JMP     PresetTxData
_TxData_SetData:                        ; 设置数据开始
    CALL    GetInfoType
    MOV     RF_InfoType,A
    JMP     _ConfigSetTxData            ; 填充发送数据包 ,等待发送完成
;************************************************
; 填充数据包部分， 由SetMode 确定数据种类             **** B ****
;//MARK: SetTX_Node 设置节点
SetTX_Node:     ; 传输最大节点号给接收端
    CALL    SetEp_MaxNode               ; 设置 最大节点值
    JMP     $+4
;//MARK: SetTx_SW 设置开关信息
SetTx_SW:       ; 传输 我的节点号，键值
    CALL    GetKeyValue
    MOV     RF_KeyValue,A               ; 设置键值
    CALL    SetEp_MyNode

    MOV     A,@C_ReadEp_Cfg_TxData
    JMP     PresetReadEp

;//设置发送信道，只需要传类型
SetTx_MyChannel:
    MOV     A,@0xFF                     ; 开关节点，不发送，接收方接收到 FF，不保存
    MOV     RF_MaxNode,A                ;
    JMP     _SetTxDataEnd
;************************************************  数据包完成，发送数据，等待发送结束
_TxData2RxData:                         ;转换为接收模式**** C ****
    MOV     A,@C_Tx2Rx_Code4B
    JMP     PresetTx2Rx                 ; R1 发送完成，转为接收模式

_ConfigRxData:                          ; 收到返回信息 
    CALL    GetInfoType                 ; 返回类型检查 **** D ****
    ADD     A,@1
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag
    JMP     QuitToIdle                  ; 类型错，重来
    JMP     _TxDataSaveTable            ; 类型相同，保存
;************************************************
;不同的数据类型，分别处理。                            **** E ****
_Config_SaveTxCode:                     ; 类型 SetMode = 2 ,保存下游信道码
    INC     ChannelNums
    CALL    SetEpParam_TxCode

    MOV     A,@C_SaveEp_TxCode   ; 写EP完成 到WaitWriteTxNum
    JMP     PresetSaveEp
                                        ; 类型 SetMode = 1 ,设置开关节点，数据不保存，NUMS不保存，直接转 成功 **** G ****
_Config_SaveNode:                       ; 类型 SetMode = 0 ,设置节点+1，准备保存
    INC     ChannelNums

_Config_Save_ChannelNums:               ; 
    CALL    _ChannelNum_EpTable
    CALL    SetEp_ChannelNums
    MOV     A,@C_SaveEp_ChannelNums     ;              **** F **** 保存 ChannelNums 后。转成功 **** G ****
    JMP     PresetSaveEp
;************************************************
;  发送端：  系统参数初始化
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
    JMP     QuitToIdle                  ; 退出来接收模式

    JBS     IntKeyValue,B_KeyDown3s
    JMP     WaitTimeOver                ; 超时退到 PresetRxData

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
;     |           |  +------------- 信道号  RF_Data
;     +-----------+---------------- 地址信息   
;//TODO:  SetTRAddrParam - 设置地址参数
;******************************************
;//TODO: SetSPIDataParam -  设置 SPI 写数据长度 
SetSPIDataParam:
    MOV     A,@PLOAD_WIDTH_SET
    JMP     $+2
SetTRAddrParam:                 ; 5个字节
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

    MOV     A,@C_E2Addr_DevAddr                   ; 把 Sleep 设置读到 ChannelNums
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

    DJZA    QuitTime                    ; QuitTime =1 时停止减
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
    DJZA    QuitTime                    ; QuitTime =1 时停止减
    MOV     QuitTime,A

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
	KeyVibrate		==		4
	KeyConfirm3s	==		120			;   长按键3秒产生持续按键
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
    BS      PrgTmp1,B_Key4                  ; 获得扫描键值保存在 PrgTmp1中

    MOV     A,PrgTmp1
    CALL    _KeyScanTable
    MOV     PrgTmp1,A                       ;当前扫描码
    SWAP    PrgTmp1

    MOV     A,IntKeyValue
    AND     A,@C_ScanCodeMask               ; 与上次的扫描值比较
    XOR     A,PrgTmp1
	JBC		StatusReg,ZeroFlag
	JMP		_KeyConfirm

    MOV     A,@~C_ScanCodeMask              ; 按键改变了，保存键值
    AND     IntKeyValue,A
    MOV     A,PrgTmp1
    OR      IntKeyValue,A

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

    MOV     A,PrgTmp1
	JBC		StatusReg,ZeroFlag
	JMP		_KeyUp

    BS      IntKeyValue,B_KeyDown
	BC		IntKeyValue,B_KeyUp
	MOV		A,@KeyConfirm3s
	MOV		KeyDownCounter,A

    MOV     A,@~C_KeyValueMask              ; 按键改变了，保存键值
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
    BC      P_CE,B_CE               ; 读数据
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


