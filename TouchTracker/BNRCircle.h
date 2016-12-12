//
//  BNRCircle.h
//  TouchTracker
//
//  Created by zhk on 16/5/5.
//  Copyright © 2016年 zhk. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BNRCircle : NSObject<NSCoding>
@property(nonatomic) CGPoint point1;
@property(nonatomic) CGPoint point2;
@property(nonatomic,strong) UIColor* color;
-(instancetype)initWithpoint:(CGPoint)p1 :(CGPoint)p2 color:(UIColor*)color;
@end
