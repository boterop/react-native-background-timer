//
//  RNBackgroundTimer.m
//  react-native-background-timer
//
//  Created by IjzerenHein on 06-09-2016.
//  Copyright (c) ATO Gear. All rights reserved.
//

@import UIKit;
#import "RNBackgroundTimer.h"

@implementation RNBackgroundTimer {
    UIBackgroundTaskIdentifier bgTask;
    int delay;
    NSMutableDictionary<NSNumber *, dispatch_block_t> *timeoutBlocks;
    NSMutableDictionary<NSNumber *, NSNumber *> *timeoutTasks;
}

RCT_EXPORT_MODULE()

- (instancetype)init
{
    if ((self = [super init])) {
        timeoutBlocks = [NSMutableDictionary new];
        timeoutTasks = [NSMutableDictionary new];
        bgTask = UIBackgroundTaskInvalid;
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents { return @[@"backgroundTimer", @"backgroundTimer.timeout"]; }

- (void) _start
{
    [self _stop];
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"RNBackgroundTimer" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    UIBackgroundTaskIdentifier thisBgTask = bgTask;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self bridge] != nil && thisBgTask == bgTask) {
            [self sendEventWithName:@"backgroundTimer" body:[NSNumber numberWithInt:(int)thisBgTask]];
        }
    });
}

- (void) _stop
{
    if (bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}

RCT_EXPORT_METHOD(start:(double)_delay
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    delay = _delay;
    [self _start];
    resolve([NSNumber numberWithBool:YES]);
}

RCT_EXPORT_METHOD(stop:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self _stop];
    resolve([NSNumber numberWithBool:YES]);
}

RCT_EXPORT_METHOD(setTimeout:(int)timeoutId
                     timeout:(double)timeout
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSNumber *key = @(timeoutId);
    [self clearTimeout:timeoutId resolver:^(__unused id result) {} rejecter:^(__unused NSString *code, __unused NSString *message, __unused NSError *error) {}];
    __block UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"RNBackgroundTimer" expirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:task];
        task = UIBackgroundTaskInvalid;
        [self->timeoutBlocks removeObjectForKey:key];
        [self->timeoutTasks removeObjectForKey:key];
    }];
    dispatch_block_t timeoutBlock = dispatch_block_create(0, ^{
        [self->timeoutBlocks removeObjectForKey:key];
        [self->timeoutTasks removeObjectForKey:key];
        if ([self bridge] != nil) {
            [self sendEventWithName:@"backgroundTimer.timeout" body:[NSNumber numberWithInt:timeoutId]];
        }
        [[UIApplication sharedApplication] endBackgroundTask:task];
    });
    self->timeoutBlocks[key] = timeoutBlock;
    self->timeoutTasks[key] = @(task);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, MAX(0, timeout) * NSEC_PER_MSEC), dispatch_get_main_queue(), timeoutBlock);
    resolve([NSNumber numberWithBool:YES]);
}

RCT_EXPORT_METHOD(clearTimeout:(int)timeoutId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSNumber *key = @(timeoutId);
    dispatch_block_t timeoutBlock = timeoutBlocks[key];
    if (timeoutBlock) {
        dispatch_block_cancel(timeoutBlock);
        [timeoutBlocks removeObjectForKey:key];
        NSNumber *taskNumber = timeoutTasks[key];
        if (taskNumber) {
            UIBackgroundTaskIdentifier task = (UIBackgroundTaskIdentifier)taskNumber.integerValue;
            [[UIApplication sharedApplication] endBackgroundTask:task];
            [timeoutTasks removeObjectForKey:key];
        }
    }
    resolve([NSNumber numberWithBool:YES]);
}

@end
