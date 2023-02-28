//
//  AppDelegate.m
//  PK2GUI
//
//  Created by 森田 晃平 on 2013/05/18.
//  Copyright (c) 2013年 森田 晃平. All rights reserved.
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>

@implementation AppDelegate {
    NSTask *_task;
    NSPipe *_pipe;
    NSString *_chipType;
    NSString *_hexPath;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (NSString *)loadArgument {
    NSMutableString *argument = [NSMutableString string];
    if (!_chipType) {
        [self pushInitButton:nil];
        if (!_chipType) {
            return nil;
        }
    }
    [argument appendFormat:@"-P%@ ", _chipType];
    if (exPowerButton.state) {
        [argument appendString:@"-W "];
    }
    if (powerButton.state) {
        [argument appendString:@"-T "];
    }
    if (!mclrButton.state) {
        [argument appendString:@"-R "];
    }
    return argument;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.window makeKeyAndOrderFront:nil];
    return NO;
}

- (void)launchPICkit2:(NSString *)argument {
    _task  = [[NSTask alloc] init];
    _pipe  = [[NSPipe alloc] init];
    fieldOfCommand.stringValue = argument;
    [_task setCurrentDirectoryPath:[NSBundle mainBundle].resourcePath];
    [_task setLaunchPath: @"/bin/bash"];
    [_task setStandardOutput: _pipe];
    [_task setArguments:[NSArray arrayWithObjects:@"-lc", [@"./pk2cmd " stringByAppendingString:argument], nil]];
    [_task launch];
}

- (IBAction)pushInitButton:(id)sender {
    if (exPowerButton.state) {
        [self launchPICkit2:@"-W -P"];
    } else {
        [self launchPICkit2:@"-P"];
    }
    NSData *data = [[_pipe fileHandleForReading] readDataToEndOfFile];
    _chipType = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _chipType = [_chipType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([_chipType isEqualToString:@"Auto-Detect: No known part found."]) {
        _chipType = nil;
        fieldOfChipType.stringValue = @"";
        NSRunAlertPanel(@"Warnning", @"Auto-Detect:No known part found!", @"OK", nil, nil);
    } else {
        _chipType = [_chipType stringByReplacingOccurrencesOfString:@"Auto-Detect: Found part " withString:@""];
        _chipType = [[_chipType componentsSeparatedByString:@"."] objectAtIndex:0];
        fieldOfChipType.stringValue = _chipType;
    }
}

- (IBAction)pushPowerOrMclrButton:(id)sender {
    NSString *argument = [self loadArgument];
    if (argument) {
        [self launchPICkit2:argument];
    }
}

- (IBAction)pushSelectHexButton:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = [NSArray arrayWithObjects:@"hex", @"Hex", nil];
    [openPanel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton && openPanel.URL.isFileURL) {
            _hexPath = openPanel.URL.path;
            fieldOfHexFilePath.stringValue = _hexPath;
        }
    }];
}

- (IBAction)pushWriteHexButton:(id)sender {
    if (!_hexPath) {
        return;
    }
    NSMutableString *argument = [NSMutableString stringWithString:[self loadArgument]];
    if (argument) {
        [argument appendFormat:@"-M -F%@", _hexPath];
        [self launchPICkit2:argument];
        NSData *data = [[_pipe fileHandleForReading] readDataToEndOfFile];
        NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        replyStr = [replyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([replyStr rangeOfString:@"Errors"].location != NSNotFound) {
            NSRunAlertPanel(@"Warnning", @"Program Errors!", @"OK", nil, nil);
        }
        
    }
    NSLog(@"%@", argument);
}

- (void)windowShouldClose:(id)sender
{
    NSLog(@"should close");
    exit(0);
}

@end
