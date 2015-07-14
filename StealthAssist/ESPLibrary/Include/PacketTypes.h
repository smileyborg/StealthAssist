//
//  PacketTypes.h
//  Valentine
//
//  Created by Amadeus Consulting on 2/26/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//
#import "ESPPacket.h"



typedef enum Byte_t{
    reqVersion = 0x01,
    respVerion = 0x02,
    reqSerialNumber = 0x03,
    respSerialNumber = 0x04,
    reqUserBytes = 0x11,
    respUserBytes = 0x12,
    reqWriteUserBytes = 0x13,
    reqFactoryDefault = 0x14,
    reqWriteSweepDefinition = 0x15,
    reqAllSweepDefinitions = 0x16,
    respSweepDefiniton = 0x17,
    reqSetSweepstoDefault = 0x18,
    reqMaxSweepIndex = 0x19,
    respMaxSweepIndex = 0x20,
    respSweepWriteResult = 0x21,
    reqSweepSections = 0x22,
    respSweepSections = 0x23,
    infDisplayData = 0x31,
    reqTurnOffMainDisplay = 0x32,
    reqTurnOnMainDisplay = 0x33,
    reqMuteOn = 0x34,
    reqMuteOff = 0x35,
    reqChangeMode = 0x36,
    reqStartAlertData = 0x41,
    reqStopAlertData = 0x42,
    respAlertData = 0x43,
    respDataReceived = 0x61,
    reqBatteryVoltage = 0x62,
    respBatteryVoltage = 0x63,
    respUnsupportedPacket = 0x64,
    respRequestNotProcessed = 0x65,
    infV1Busy = 0x66,
    respDataError = 0x67,
    reqSavvyStatus = 0x71,
    respSavvyStatus = 0x72,
    reqVehicleSpeed = 0x73,
    respVehicleSpeed = 0x74,
    reqOverrideThumbwheel = 0x75,
    reqSetSavvyUnmuteEnable = 0x76,
    reqBADPACKET = 0xAA
}PacketType;

