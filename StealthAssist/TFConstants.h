//
//  TFConstants.h
//  StealthAssist
//
//  Created by Tyler Fox on 3/30/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#ifndef TF_CONSTANTS_H
#define TF_CONSTANTS_H

typedef NS_ENUM(NSInteger, TFDisplayState) {
    TFDisplayStateOff = 0,
    TFDisplayStateOn,
    TFDisplayStateBlinking
};

typedef NS_ENUM(NSInteger, TFV1Mode) {
    TFV1ModeUnknown = 0,
    TFV1ModeAllBogeys,
    TFV1ModeLogic,
    TFV1ModeAdvancedLogic,
    TFV1ModeKKaCustomSweeps,
    TFV1ModeKaCustomSweeps,
    TFV1ModeKKaPhoto,
    TFV1ModeKaPhoto
};

#define kBandKaFrequencyUpperEnd        40000 // in MHz
#define kBandKaFrequencyLowerEnd        27000 // in MHz
#define kBandKFrequencyUpperEnd         27000 // in MHz
#define kBandKFrequencyLowerEnd         18000 // in MHz
#define kBandKuFrequencyUpperEnd        18000 // in MHz
#define kBandKuFrequencyLowerEnd        12000 // in MHz
#define kBandXFrequencyUpperEnd         12000 // in MHz
#define kBandXFrequencyLowerEnd          8000 // in MHz

typedef NS_ENUM(NSInteger, TFBand) {
    TFBandNone = 0,
    TFBandLaser,
    TFBandKa,
    TFBandK,
    TFBandX
};

typedef NS_ENUM(NSInteger, TFDirection) {
    TFDirectionUnknown = 0,
    TFDirectionAhead,
    TFDirectionSide,
    TFDirectionBehind
};

#endif /* TF_CONSTANTS_H */
