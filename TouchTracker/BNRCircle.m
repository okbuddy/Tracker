//
//  BNRCircle.m
//  TouchTracker
//
//  Created by zhk on 16/5/5.
//  Copyright © 2016年 zhk. All rights reserved.
//

#import "BNRCircle.h"

@implementation BNRCircle
-(instancetype)initWithpoint:(CGPoint)p1 :(CGPoint)p2 color:(UIColor *)color
{
    self=[super init];
    _point1=p1;
    _point2=p2;
    _color=color;
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    _point1=[aDecoder decodeCGPointForKey:@"point1"];
    _point2=[aDecoder decodeCGPointForKey:@"point2"];
    _color=[aDecoder decodeObjectForKey:@"color"];
    
    return  self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:_point1 forKey:@"point1"];
    [aCoder encodeCGPoint:_point2 forKey:@"point2"];
    [aCoder encodeObject:_color forKey:@"color"];
    
}
@end
