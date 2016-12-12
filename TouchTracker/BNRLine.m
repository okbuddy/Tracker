//
//  BNRLine.m
//  TouchTracker
//
//  Created by zhk on 16/5/2.
//  Copyright © 2016年 zhk. All rights reserved.
//

#import "BNRLine.h"

@implementation BNRLine
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    _begin=[aDecoder decodeCGPointForKey:@"begin"];
    _end=[aDecoder decodeCGPointForKey:@"end"];
    _width=[aDecoder decodeFloatForKey:@"width"];
    _color=[aDecoder decodeObjectForKey:@"color"];
    
    return  self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:_begin forKey:@"begin"];
    [aCoder encodeCGPoint:_end forKey:@"end"];
    [aCoder encodeFloat:_width forKey:@"width"];
    [aCoder encodeObject:_color forKey:@"color"];

}
@end
