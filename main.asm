; RF24L01无线收发模块 , 接收端 2020.02.11, 
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

_ResetTable5:           ; 发送信道
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xB1       ; 信道码 01      
    RETL    @0xB2       ; 信道码 02      
    RETL    @0xB3       ; 信道码 03      
    RETL    @0x05       ; RF-CH      


_ResetTable1:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0xA1       ; 信道码 01      
    RETL    @0xA2       ; 信道码 02      
    RETL    @0xA3       ; 信道码 03      
    RETL    @0x02       ; RF-CH      
    RETL    @0x00       ; 接收信道数, 无用
    RETL    @0x01       ; 发送信道数
    RETL    @0x02       ; 设置开关数

_ResetTable2:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x34       ; 信道码 01      
    RETL    @0x43       ; 信道码 02      
    RETL    @0x10       ; 信道码 03      
    RETL    @0x00       ; RF-CH      

_ResetTable3:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x01       ; 节点1，
    RETL    @0x01       ; 按键值=1

_ResetTable4:
    MOV     A,PrgTmp2
    ADD     PC,A
    RETL    @0x08       ; 节点8，
    RETL    @0x02       ; 按键值=2



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
;//MARK: 写EPROM成功列表
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
;//MARK: 读EPROM成功列表
    C_ReadEp_ChannelNums    ==  00  ;OK
    C_ReadEp_RxChannel      ==  01  ;OK
    C_ReadEp_RxCode4B       ==  02  ;ok
    C_READEP_TxChananeNums  ==  03  ;ok  读 Tx ChannelNums准备转发
    C_ReadEp_MyNode         ==  04  ;ok 转发填充我的节点
    C_ReadEp_SWNodeNums     ==  05  ;ok
    C_ReadEp_SWCode2B       ==  06  ;OK
    C_ReadEp_Cfg_RxChannel  ==  07  ;
    C_ReadEp_TxCode4B       ==  08
    C_ReadEp_TxCodeSwInfo   ==  09  ;
    C_ReadEp_Sleep          ==  10  ; 启动后读开机参数，是否需要写EP测试数据
    C_ReadEp_RelaySWAddr    ==  11  ; 读 I2C开关地址，3B,4B,5B等2B

_ReadSucessTable:
    MOV     A,Ep_Mode
    ADD     PC,A
    JMP     _ReadChannelNumsOk      ;00   
    JMP     _TxMyNode_ReadEp        ;01   C_ReadEp_RxChannel      ==  02
    JMP     _RxCode4B               ;02   C_ReadEp_RxCode4B       ==  03
    JMP     NextSWInfo              ;03   C_READEP_TxChananeNums 读转发NUMS
    JMP     _RcvTrans_MyNode        ;04   填充我的节点
    JMP     _ChkNextSWNum           ;05   
    JMP     _RcvTrans_SW2B          ;06   读SW CODE 2B
    JMP     ConfigRcv_SetSW         ;07
    JMP     _TxCode4B               ;08
    JMP     ConfigRcv_ChkDataRecover;09
    JMP     _McuReset_Sleep         ;10
    JMP     _RelaySWAddr            ;11
;*************************************************
;//MARK: 读EPROM失败列表
; _ReadFailTable:
;    M_LEDOFF
    ; JMP     ResetKeyCnt

;*************************************************
;//MARK: 发送数据 - 列表

    ; C_TxData_Trans      ==  0       ;ok  向上下游转发开关信息
    ; C_RX2TX_Config      ==  1       ;
    ; C_TxData_MyNode     ==  2

_SetTxDataTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _RcvTrans_SetData       ; 
    JMP     _TxMyNode_SetData       ;
    JMP     _ConfigRcv_ReturnTable  ;

; 发送数据成功后处理
_TxDataEndTable:                    
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _NextSWNums
    JMP     _Tx2Rx
    JMP     _ConfigRcv_SaveTable

; 发送数据失败处理
_TxFailTable:                       
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _NextSWNums
    JMP     PresetRxTrans_LedOff
    JMP     PresetRxTrans_LedOff
;*************************************************
;//MARK: Time 设置时间
    ; ms 按键弹起计数按键数等待时间 1秒
    ; 保存EProm等待时间           1秒
    ; 读  EProm等待时间           1秒
    C_WaitEpTime    ==      5   ; ms 

    C_KeyUpTime     ==      30  ; ms    

    ; SPI 发送数据等待时间， 320ms 
    C_SpiTxTime     ==      10  ; ms

    ; 等待用户按键时间  15秒
    C_WaitKeyTime   ==      30  ; 0.5s,

    ; 操作成功，闪LED时间 3秒
    C_FlashSucessTime==     6   ; 0.5s

;//MARK: 接收数据 - 列表 
;
    ; C_RxData_Trans      ==  0       ; 接收转发
    ; C_RxData_Config     ==  1       ; 接收设置信息
    ; C_Tx2Rx_Code4B      ==  2


    C_Trans_Data        ==  0       ; 接收  - 转发数据;  SPI_Mode = 0
    C_SetDn_Data        ==  1       ; 与下游通信， SPI_Mode = 1
    C_SetUp_Data        ==  2       ; 与上游通信， SPI_Mode = 2


; 接收超时表
; _RxTimeOverTable: 
    ; MOV     A,SPI_Mode
    ; ADD     PC,A
    ; JMP     IdleModeCode_LedOff     ; 没接收到信息，按键处理
    ; JMP     PresetRxTrans_LedOff    ; 
    ; JMP     PresetRxTrans_LedOff    ; 

; 接收数据成功表
_RxDataEndTable:
    MOV     A,SPI_Mode
    ADD     PC,A
    JMP     _IdleRcvTrans           ; 接收到转发信息处理
    JMP     _RxDownCodeEnd          ; 接收到
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
;     JMP     IdlePress2Key           ; 设置节点号
;     JMP     IdlePress3Key           ; 设置开关信息
;     JMP     IdlePress4Key           ; 接收发送码，发送接收码
;     JMP     IdlePress5Key           ; 发送接收码，接收发送码


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
    JMP     ConfigRcv_SaveMyNode      ; 保存节点号 
    JMP     ConfigRcv_SaveSW        ; 保存开关信息
    JMP     ConfigRcv_SaveTxChannelNums

;*************************************************
_SaveFailTable:
    MOV     A,Ep_Mode
    JBC     StatusReg,ZeroFlag
    JMP     PresetRxTrans           ; 操作I2C开关失败，恢复接收模式
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
    JMP     TxData                  ;3  按一次键，发送我的节点信息
    JMP     SaveEpromData           ;4
    JMP     ReadEpromData           ;5
    JMP     WaitTxDataEnd           ;6  发送完成，转为接收模式
    JMP     WaitRxDataReturn        ;7
    JMP     CompEpromData           ;8
    JMP     WaitRx2TxEnd            ;9
    JMP     WaitTimeOver_NoLed      ;10 等待超时，LED不变，接收模式
; 转发结束，比较节点是否与我的节点信息，相同，如果2字节相同，则继电器动作

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
    MOV     A,@C_ReadEp_ChannelNums ; 1 - MyNode/SWNums/TxNums读到ChannelNums
    JMP     PresetReadEp
; _ReadChannelNumsOk:  转到

_IdleChkKey3s:
    JBC     IntKeyValue,B_KeyDown3s
    JMP     ResetSystemParam
    JMP     CheckRxIRQ              ; 检测 IRQ
;************************************************
;//MARK: Trans 接收到开关信息处理
_IdleRcvTrans:
    MOV     A,@C_KeyNodeType
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag      ; 数据类型 开关节点相同
    JMP     PresetRxTrans           ; 类型错，重新接收

    JZA     RF_MyNode
    JMP     $+3                     ;
    INC     InfoSN                  ; RF_InfoSN = 0xFF,则为开关节点发送的信息， InFo +1
    JMP     $+7    

    MOV     A,InfoSN
    XOR     A,RF_InfoSN
    JBC     StatusReg,ZeroFlag
    JMP     PresetRxTrans_LedOff              ; 信息序号相同，已经处理过了。不再处理

; 以下是信息转发
    MOV     A,RF_InfoSN             
    MOV     InfoSN,A                ; 信息码保存
    MOV     A,RF_MyNode
    MOV     MyNode,A                ; 将上游NODE 保存在MyNode中

    MOV     A,@C_E2Addr_TxChannelNums
    CALL    SetEp_ChannelNums
    MOV     A,@C_READEP_TxChananeNums
    JMP     PresetReadEp

NextSWInfo:
    MOV     A,ChannelNums
    JBC     StatusReg,ZeroFlag
    JMP     ChkSWNode               ; 没设置过，不能转发

    JMP     PresetTxData            ; 设置发送信道

_RcvTrans_SetData:
    MOV     A,MyNode                ; 上游节点
    XOR     A,RF_MyNode             ; 下游节点
    JBC     StatusReg,ZeroFlag
    JMP     _NextSWNums             ; 不向上游发送

; 设置发送数据
    CALL    SetEp_MyNode            ; 把 EP MyNode 读到 RF_Data+3    
    MOV     A,@C_ReadEp_MyNode      ; 1 - 保存上游接收码
    JMP     PresetReadEp

_RcvTrans_MyNode:
    MOV     A,InfoSN
    MOV     RF_InfoSN,A
    JMP     _SetTxDataEnd

; 发送结束，不管是重发超时，还是发送成功，都要减 NUMS
_NextSWNums:
    DEC     ChannelNums
    JMP     NextSWInfo
;************************************************
ChkSWNode:
    MOV     A,@C_ConfigSWInfo
    MOV     SetMode,A               ; 设置从设置参数中读 SW Info

    MOV     A,@C_E2Addr_SwNodeNums
    CALL    SetEp_ChannelNums
    MOV     A,@C_ReadEp_SWNodeNums
    JMP     PresetReadEp

_ChkNextSWNum:
    MOV     A,ChannelNums
    JBC     StatusReg,ZeroFlag
    JMP     PresetRxTrans           ; 所有SW节点检查完成

    CALL    SetEpParam_ChannelNums  ; 从节点，键值表读 2节点
    MOV     A,@C_ReadEp_SWCode2B
    JMP     PresetReadEp

_RcvTrans_SW2B:
    MOV     A,RF_Data               ; 从节点，键值表读的节点
    XOR     A,RF_SWNode             ; 与收到的信息，节点号比较
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
;RF_Data = 0, 设置本地继电器
    JBS     RelayStatus,0
    BC      P_Relay,B_Relay
    JBC     RelayStatus,0
    BS      P_Relay,B_Relay
    JMP     TimeSpaceRcv

    CLR     SetMode                 ; 准备读 SW I2C地址
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
; 根据 ChannelNums 设置  I2CADDR /TX CODE/ SW CODE /
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
; 把 EP MyNode 读到 RF_Data+3    
SetEp_MyNode:
    MOV     A,@C_E2Addr_MyNode
    MOV     Buf_EpAddr,A                ; +1
    MOV     A,@RF_MyNode                ; +2
    JMP     SetEp_ChannelNums + 2
;************************************************
; 设置把 Eprom 地址读写到 ChannelNums - 1B 中  
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
; 设置 Tmp1,RamSelReg 设置读写 SPI 寄存器 3B ，7B
SetTRAddrParam:
    MOV     A,@TX_ADR_WIDTH
    JMP     SetSPIDataParam+1
SetSPIDataParam:
    MOV     A,@PLOAD_WIDTH_DATA     ; 7个字节
    MOV     PrgTmp1,A

    MOV     A,@RF_Data
    MOV     RamSelReg,A
    RET
;************************************************
;//MARK: ReadChannelNumsOk 读 MyNode/SW Nums/TX Nums
_ReadChannelNumsOk:
    CALL    GetMaxNums
    SUB     A,ChannelNums
    JBC     StatusReg,CarryFlag
    JMP     ResetKeyCnt

    INC     SPI_Mode                ; 与下游通信， SPI_Mode = 1

    MOV     A,SetMode
    XOR     A,@C_MaxKeyCnt-1
    JBC     StatusReg,ZeroFlag
    JMP     IdlePress5Key

;//MARK: 设置2/3/4键
IdlePress2Key:                      ; 接收发送来的节点号，然后保存
IdlePress3Key:                      ; 接收发送来的开关节点号，键值
IdlePress4Key:                      ; 发送我的接收信道码，CH给发送方
    INC     SPI_Mode                ; 与上游通信， SPI_Mode = 2
    JMP     PresetRxData
ConfigRcv_GetData:
    CALL    GetInfoType
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag      ; 设置类型与接收到的类型相同
    JMP     PresetRxTrans_LedOff    ; 类型不同，退到 PresetRxData

;    MOV     A,@C_RX2TX_Config       ; RX to TX
    JMP     PresetRx2Tx

;_ConfigRcv_ReturnTable:
;************************************************
; 接收到的指令是  上游接收码，保存接收码
ConfigRcv_RxChannel:                ; 设置发送方地址，需要填充地址码，信道
    INCA    RF_MyNode
    JBC     StatusReg,ZeroFlag
    JMP     ConfigRcv_RxChannel1    ; 如果 上游CH=FF, 则不保存上游接收码, ChannelNums  不变

    INC     ChannelNums             ; ChannelNums + 1,保存代码

    CALL    SetEpParam_ChannelNums
    MOV     A,@C_SaveEp_UpCode      ; 1 - 保存上游接收码
    JMP     PresetSaveEp
;************************************************
; 读自已的接收码，准备发送
ConfigRcv_RxChannel1:   
    MOV     A,@C_EpAddr_RxChannel
    CALL    SetEpParamCh0
    MOV     A,@C_ReadEp_Cfg_RxChannel   ; 2 - 读自己接收码 4B
    JMP     PresetReadEp            

ConfigRcv_SetNode:                  ; 设置节点
ConfigRcv_SetSW:                    ; 设置开关信息
    INC     RF_InfoType
    JMP     _SetTxDataEnd
;保存参数
ConfigRcv_SaveSW:                   ; 设置开关信息，保存开关信息
    INC     ChannelNums
    CALL    SetEpParam_ChannelNums
    MOV     A,@C_SaveEp_SWNodeKey   ; 2 - 保存开关信息2B
    JMP     PresetSaveEp

ConfigRcv_SaveMyNode:
    MOV     A,RF_MyNode
    MOV     ChannelNums,A
    JMP     ConfigRcv_NumsChange    ; ChannelNums 改了，去保存

ConfigRcv_SaveTxChannelNums:        ; ChannelNums 加1了，检查有没有重复，如果有重复，再不保存，成功返回
    MOV     A,@2
    SUB     A,ChannelNums
    JBS     StatusReg,CarryFlag
    JMP     ConfigRcv_NumsChange    ; ChannelNums <2 ,直接保存，无重复

    CALL    SetEpParam_ChannelNums
    MOV     A,@C_ReadEp_TxCodeSwInfo; 把新保存的数据读到 RF_Data缓冲中,待比较
    JMP     PresetReadEp

ConfigRcv_ChkDataRecover:
    MOV     A,ChannelNums
    MOV     RF_InfoType,A           ; ChannelNums暂时保存

    DEC     ChannelNums             ; 把最新一组与以前组比较
    BC      TRFlagReg,F_FindSame    ;
_CompareNext:
    CALL    SetEpParam_ChannelNums
;    JMP     PresetCompEp
;//MARK: EPROM 比较数据进程
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
    JMP     _CompareEnd                         ; EPROM 正常，灯不闪

    DJZA    QuitTime
    JMP     main   
    JMP     _ReadFailTable

_CompareEnd:                                    ; 一组数据比较结束
    JBC     TRFlagReg,F_FindSame
    JMP     FlashSucess                         ; 发现有相同的，不保存 Nums,Nums不变化

    DJZ     ChannelNums
    JMP     _CompareNext

    MOV     A,RF_InfoType
    MOV     ChannelNums,A                       ; 恢复暂时的ChannelNums，进行保存

ConfigRcv_NumsChange:
    CALL    _ChannelNum_EpTable
    CALL    SetEp_ChannelNums
    MOV     A,@C_SaveEp_ChannelNums
    JMP     PresetSaveEp
;************************************************
;//MARK: 设置5键，发送我的节点，接收下游节点，并保存
IdlePress5Key:
;    MOV     A,@C_TxData_MyNode  ; 设置 config 通道
    JMP     PresetTxData

_TxMyNode_SetData:              ; 设置数据开始
    MOV     A,@C_TxData
    CALL    ResetQuitTime_Mode            ; 
;************************************************
;  发送我的接收码
TxData:
    CALL    FLed_SlowBlink
    CALL    ChkKeyDown
    JBS     StatusReg,CarryFlag
    JMP     WaitTimeOverLedOff            ; 长按3秒退出，超时退出 

    MOV     A,@C_EpAddr_RxChannel
    CALL    SetEpParamCh0       ; 读通道码 4B
    MOV     A,@C_ReadEp_RxChannel
    JMP     PresetReadEp

_TxMyNode_ReadEp:
    MOV     A,@C_RFType
    MOV     RF_InfoType,A       ; 设置RF模式
    JMP     _SetTxDataEnd
;************************************************
; 数据发送完成，转为接收模式

_Tx2Rx:
;    MOV     A,@C_Tx2Rx_Code4B
    JMP     PresetTx2Rx

_RxDownCodeEnd:
    MOV     A,@C_RFType+1
    XOR     A,RF_InfoType
    JBS     StatusReg,ZeroFlag
    JMP     PresetRxTrans_LedOff                ; 类型错，重来

    INC     ChannelNums
    CALL    SetEpParam_ChannelNums
    MOV     A,@C_SaveEp_DownCode        ; 3 - 保存下游接收码
    JMP     PresetSaveEp

_RxDownCodeSaveNum:
    MOV     A,@4
    MOV     SetMode,A  
    JMP     ConfigRcv_SaveTxChannelNums ; 去处理 TxNums+1,检查重复，保存 ChannelNums
;************************************************
;//MARK:ResetSystemParam
; IDLE模式，长按3秒， 清除系统参数
ResetSystemParam:
    MOV     A,@C_ConfirmReset
    CALL    ResetQuitTime_Mode
;************************************************
ConfirmReset:
    CALL    FLed_SlowBlink
    CALL    ChkKeyDown
    JBC     StatusReg,CarryFlag
    JMP     PresetRxTrans_LedOff        ; 退出来接收模式

    JBS     IntKeyValue,B_KeyDown3s
    JMP     WaitTimeOverLedOff          ; 超时退到 PresetRxData

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

    MOV     A,@C_E2Addr_DevAddr                   ; 把 Sleep 设置读到 ChannelNums
    CALL    SetEpParamCh0
    MOV     A,@C_ReadEp_Sleep
    JMP     PresetReadEp
_McuReset_Sleep:
    JBS     RF_Data+2,1
    BS      TRFlagReg,F_EpTRData

;*************************************
FlashSucess:     ; Eprom保存，LED快闪3秒，返回PresetRxData
;*************************************
    MOV     A,@C_WaitBlinkEnd
    MOV     TRMode,A    

    MOV     A,@C_FlashSucessTime
    CALL    SetQuitTime_500ms
;*************************************
WaitBlinkEnd:
    MOV     A,@1<<B_LED
    JBC     TRFlagReg,F_250ms   ; 快闪
    XOR     P_LED,A
    BC      TRFlagReg,F_250ms
;//MARK: WaitTimeOver
WaitTimeOverLedOff:                 ; 等待超时,LED熄灭
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
    CLR     SPI_Mode                ; 转发数据， SPI_Mode = 0

    CLR     TRMode
    CLR     SetMode                 ;  = InfoSN 
    MOV     A,@1
    MOV     KeyTime,A               ;  = MyNode 在转发信息时使用，在此初始化

    CALL    ClearKeyFlag
;    MOV     A,@C_RxData_Trans
    JMP     PresetRxData
;*************************************
TimeSpaceRcv:
    MOV     A,@C_WaitTimeOver
    CALL    WaitTxTime_Mode
WaitTimeOver_NoLed:                 ; 等待超时,LED状态不变
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

    DJZA    QuitTime                    ; QuitTime =1 时停止减
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
    DJZA    QuitTime                    ; QuitTime =1 时停止减
    MOV     QuitTime,A

    ; M_SingleKeyNoCont20190821
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
	KeyVibrate		==		2
	KeyConfirm3s	==		120			;   长按键3秒产生持续按键

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
    BC		IntKeyValue,B_KeyDown3s			;按键变化后，清除3秒按键标志
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
