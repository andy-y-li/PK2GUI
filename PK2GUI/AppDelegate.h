//
//  AppDelegate.h
//  PK2GUI
//
//  Created by 森田 晃平 on 2013/05/18.
//  Copyright (c) 2013年 森田 晃平. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSTextField *fieldOfChipType;
    IBOutlet NSButton *powerButton;
    IBOutlet NSButton *mclrButton;
    IBOutlet NSTextField *fieldOfHexFilePath;
}

- (IBAction)pushInitButton:(id)sender;
- (IBAction)pushPowerOrMclrButton:(id)sender;
- (IBAction)pushSelectHexButton:(id)sender;
- (IBAction)pushWriteHexButton:(id)sender;
@property (assign) IBOutlet NSWindow *window;

@end
