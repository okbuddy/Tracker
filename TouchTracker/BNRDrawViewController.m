//
//  BNRDrawViewController.m
//  TouchTracker
//
//  Created by zhk on 16/5/2.
//  Copyright © 2016年 zhk. All rights reserved.
//

#import "BNRDrawViewController.h"
#import "BNRDrawView.h"

@implementation BNRDrawViewController
-(void)loadView
{
    self.view=[[BNRDrawView alloc]initWithFrame:CGRectZero];
}
@end
