//
//  TFDeviceHardware.m
//  StealthAssist
//
//  Created by Tyler Fox on 1/5/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation TFDeviceHardware

+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

@end
