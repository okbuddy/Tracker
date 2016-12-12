//
//  BNRLine.h
//  TouchTracker
//
//  Created by zhk on 16/5/2.
//  Copyright © 2016年 zhk. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BNRLine : NSObject<NSCoding>
@property(nonatomic) CGPoint begin;
@property(nonatomic) CGPoint end;
@property(nonatomic) float width;

@property(nonatomic,strong) UIColor* color;

@end
