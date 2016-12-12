//
//  BNRDrawView.h
//  TouchTracker
//
//  Created by zhk on 16/5/2.
//  Copyright © 2016年 zhk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"
#import "ColorViewController.h"

@interface BNRDrawView :UIView<WEPopoverControllerDelegate, UIPopoverControllerDelegate, ColorViewControllerDelegate>

@property (nonatomic, strong) WEPopoverController *wePopoverController;
-(BOOL)saveTheData;

@end
