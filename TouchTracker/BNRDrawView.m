//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by zhk on 16/5/2.
//  Copyright © 2016年 zhk. All rights reserved.
//

#import "BNRDrawView.h"
#import "BNRLine.h"
#import "BNRCircle.h"
#import <Accelerate/Accelerate.h>
#import "GzColors.h"


#define CIRCLE 0
#define LINE 1
#define CURVE 2

@interface BNRDrawView()<UIGestureRecognizerDelegate>
@property(nonatomic,strong) UIPanGestureRecognizer* pan;

@property(nonatomic)        CGPoint currentDot;
@property(nonatomic,strong) NSMutableDictionary* currentLines;
@property(nonatomic,strong) NSMutableDictionary* currentPoints;

@property(nonatomic,strong) NSMutableArray* finishedCurves;
@property(nonatomic,strong) NSMutableArray* finishedLines;
@property(nonatomic,strong) NSMutableArray* finishedCircles;

@property(nonatomic,weak) BNRLine* selectedLine;

@property(nonatomic) int type;
@property(nonatomic) UIColor* color;

@end
@implementation BNRDrawView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentLines=[[NSMutableDictionary alloc]init];
        _currentPoints=[[NSMutableDictionary alloc]init];
        
        _finishedCircles=[NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForSaving:@"finishedCircles"]];
        _finishedLines=[NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForSaving:@"finishedLines"]];
        _finishedCurves=[NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForSaving:@"finishedCurves"]];
        if (!_finishedCircles) {
            _finishedCircles=[[NSMutableArray alloc]init];

        }
        if (!_finishedLines) {
            _finishedLines=[[NSMutableArray alloc]init];

        }
        if (!_finishedCurves) {
            _finishedCurves=[[NSMutableArray alloc]init];

        }
        
        _color=[UIColor blackColor];
        self.backgroundColor=[UIColor grayColor];
        self.multipleTouchEnabled=YES;
        _type=LINE;
        //different types and differevt colors
        NSArray* a=@[@"line",@"circle",@"curve"];
        NSArray* b=@[@"white",@"red",@"green",@"blue",@"yellow"];
        UISegmentedControl* seg1=[[UISegmentedControl alloc]initWithItems:a];
        seg1.frame=CGRectMake(0, 20, 150, 50);
        seg1.tintColor=[UIColor lightGrayColor];
        seg1.backgroundColor=[UIColor whiteColor];
        [seg1 addTarget:self action:@selector(changetype:) forControlEvents:UIControlEventValueChanged];
        UISegmentedControl* seg2=[[UISegmentedControl alloc]initWithItems:b];
        seg2.frame=CGRectMake(0, 70, 250, 50);
        seg2.tintColor=[UIColor lightGrayColor];
        seg2.backgroundColor=[UIColor whiteColor];
        [seg2 addTarget:self action:@selector(changecolor:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:seg1];
        [self addSubview:seg2];
        //add the UIGestureRecognizer doubletap
        UITapGestureRecognizer* doubleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubletap:)];
        doubleTap.numberOfTapsRequired=2;
        doubleTap.delaysTouchesBegan=YES;
        [self addGestureRecognizer:doubleTap];
        //add the UIGestureRecognizer singletap
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        tap.delaysTouchesBegan=YES;
        [tap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:tap];
        //add the UIGestureRecognizer longpress
        UILongPressGestureRecognizer* press=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:press];
        //add the UIGestureRecognizer pan
        _pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        _pan.cancelsTouchesInView=NO;
        _pan.delegate=self;
        [self addGestureRecognizer:_pan];
        //add the UIGestureRecognizer swipe
        UISwipeGestureRecognizer* swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(choose:)];
        swipe.numberOfTouchesRequired=2;
        swipe.direction=UISwipeGestureRecognizerDirectionDown;
        swipe.delegate=self;
        [_pan requireGestureRecognizerToFail:swipe];
        [self addGestureRecognizer:swipe];
        //
//        UITapGestureRecognizer* tt=[[UITapGestureRecognizer alloc]init];
//        tt.numberOfTouchesRequired=2;
//        [tt delaysTouchesBegan];
//        [self addGestureRecognizer:tt];
    }
    return self;
}
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIGestureRecognizer  Delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;

}


#pragma mark - UITapGestureRecognizer action
-(void)doubletap:(UITapGestureRecognizer*)tap
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.currentLines removeAllObjects];
    
    [self.currentPoints removeAllObjects];
    [self.finishedCircles removeAllObjects];
    [self.finishedCurves removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}
-(void)singleTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    //selected line
    CGPoint p=[tap locationInView:self];
    self.selectedLine=[self lineAtPoint:p];
    //UIMenuController
    if (self.selectedLine) {
        [self becomeFirstResponder];
        UIMenuController* menu=[UIMenuController sharedMenuController];
        [menu setTargetRect:CGRectMake(p.x, p.y, 2, 2) inView:self];
        UIMenuItem* item=[[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine)];
        menu.menuItems=@[item];
        [menu setMenuVisible:YES animated:YES];
    }
    else [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [self setNeedsDisplay];
}
-(void)deleteLine
{
    [self.finishedLines removeObjectIdenticalTo:self.selectedLine];
    [self setNeedsDisplay];
}
-(BNRLine*)lineAtPoint:(CGPoint)point
{
    for (BNRLine* line in self.finishedLines) {
        CGPoint begin=line.begin;
        CGPoint end=line.end;
        for (float i=0; i<=1.0; i+=0.05) {
            float x=begin.x+i*(end.x-begin.x);
            float y=begin.y+i*(end.y-begin.y);
            if (hypotf(x-point.x, y-point.y)<20.0) {
                return line;
            }
        }
    }
    return nil;
}
-(void)longPress:(UILongPressGestureRecognizer*)press
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (press.state==UIGestureRecognizerStateBegan) {
        CGPoint p=[press locationInView:self];
        self.selectedLine=[self lineAtPoint:p];
        if (self.selectedLine) {
            [self.currentLines removeAllObjects];
        }
    } else {
        if (press.state==UIGestureRecognizerStateEnded) {
            NSLog(@"longPress is end!!");
            self.selectedLine=nil;
        }
    }
    [self setNeedsDisplay];
}
-(void)moveLine:(UIPanGestureRecognizer*)pan
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (!self.selectedLine) {
        CGPoint point=[pan velocityInView:self];
        float velocity=hypotf(point.x, point.y);
        NSLog(@"%f",velocity);
        if (velocity>300) {
            for (NSValue*key in self.currentLines) {
                BNRLine* line=self.currentLines[key];
                line.width=velocity/30.0;
            }
        }
        if (pan.state==UIGestureRecognizerStateEnded) {
            NSLog(@"NO  pan is end");
            pan.cancelsTouchesInView=NO;
        }
        return;
    }
    pan.cancelsTouchesInView=YES;
    if (pan.state==UIGestureRecognizerStateChanged) {
        CGPoint p=[pan translationInView:self];
        CGPoint begin=self.selectedLine.begin;
        CGPoint end=self.selectedLine.end;
        begin.x+=p.x;
        begin.y+=p.y;
        end.x+=p.x;
        end.y+=p.y;
        self.selectedLine.begin=begin;
        self.selectedLine.end=end;
        
        [self setNeedsDisplay];
        [pan setTranslation:CGPointZero inView:self];

    }
    if (pan.state==UIGestureRecognizerStateEnded) {
        NSLog(@"NO  pan is end");
        pan.cancelsTouchesInView=NO;
    }
}

#pragma mark - switch
-(void)changetype:(UISegmentedControl*)sender
{
    long index=sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.type=LINE;
            break;
        case 1:
            self.type=CIRCLE;
            break;
        case 2:
            self.type=CURVE;
            break;
        default:
            break;
    }
}
-(void)changecolor:(UISegmentedControl*)sender
{
    long index=sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.color=[UIColor whiteColor];
            break;
        case 1:
            self.color=[UIColor redColor];
            break;
        case 2:
            self.color=[UIColor greenColor];
            break;
        case 3:
            self.color=[UIColor blueColor];
            break;
        case 4:
            self.color=[UIColor yellowColor];
            break;
        default:
            break;
    }
}

#pragma mark - draw path

-(UIColor*)setcolor:(BNRLine*)line
{
    UIColor* color;
    float sin=(line.end.y-line.begin.y)/hypotf((line.end.x-line.begin.x), (line.end.y-line.begin.y));
    float cos=(line.end.x-line.begin.x)/hypotf((line.end.x-line.begin.x), (line.end.y-line.begin.y));
    vFloat vf=vasinf(_mm_set1_ps(sin));
    float f[4];
    _mm_store1_ps(f, vf);
    float degree=f[0];
    float interval=2*M_PI/3;
    if (sin>=-0.5&&cos>=0.0) {
        float interval1=degree+M_PI/6;
        float interval2=interval-interval1;
        color=[UIColor colorWithRed:interval2/interval green:interval1/interval blue:0 alpha:1];
        
    } else
    if (sin>=-0.5&&cos<0.0) {
        float interval1=degree+M_PI/6;
        float interval2=interval-interval1;
        color=[UIColor colorWithRed:0 green:interval1/interval blue:interval2/interval alpha:1];
    }
    else
    {
        if (cos>=0) {
            float interval1=degree+M_PI/2+M_PI/6;
            float interval2=interval-interval1;
            color=[UIColor colorWithRed:interval1/interval green:0 blue:interval2/interval alpha:1];

        } else {
            float interval1=-M_PI/6-degree;
            float interval2=interval-interval1;
            color=[UIColor colorWithRed:interval1/interval green:0 blue:interval2/interval alpha:1];
        }
    }
    return color;
}
-(void)drawRect:(CGRect)rect
{
    
    //line
        for (BNRLine* line in self.finishedLines) {
            [line.color set];
            [self drawline:line];
        }
        for (NSValue* key in self.currentLines) {
            BNRLine* line=self.currentLines[key];
            [line.color set];
            [self drawline:self.currentLines[key]];
        }
    if (self.selectedLine) {
        [[UIColor whiteColor] set];
        [self drawline:self.selectedLine];
    }
   //circle
        for (BNRCircle* circle in self.finishedCircles) {
            [circle.color setStroke];
            [self drawcircle:circle.point1 :circle.point2];
        }
        [self.color setStroke];
        NSMutableArray* a=[[NSMutableArray alloc]init];
        for (NSValue*key in self.currentPoints) {
            [a addObject:self.currentPoints[key]];
        }
        if (a.count==2) {
            [self drawcircle:CGPointFromString(a[0]) :CGPointFromString(a[1])];
        }
    //curve
    if (self.finishedCurves.count==0) {
        return;
    }
    UIColor* c=self.finishedCurves[0];
    [c set];
    for ( int i=1;i<[self.finishedCurves count]-1;++i) {
        CGPoint dot1=CGPointFromString(self.finishedCurves[i]);
        if ([self.finishedCurves[i+1] isKindOfClass:[UIColor class]]) {
            UIColor* c=self.finishedCurves[i+1];
            [c set];
            ++i;
            continue;
        }
        CGPoint dot2=CGPointFromString(self.finishedCurves[i+1]);
        CGPoint dot3=CGPointMake((dot1.x+dot2.x)/2, (dot1.y+dot2.y)/2);
        
        [self drawdot:dot1:dot2:dot3];
    }
   
    
}
-(void)drawline:(BNRLine*)line
{
    UIBezierPath* path=[[UIBezierPath alloc]init];
    path.lineWidth=line.width;
    path.lineCapStyle=kCGLineCapRound;
    
    [path moveToPoint:line.begin];
    [path addLineToPoint:line.end];
    [path stroke];
}
-(void)drawdot:(CGPoint)dot1 :(CGPoint)dot2 :(CGPoint)dot3
{
    UIBezierPath* path=[[UIBezierPath alloc]init];
    path.lineWidth=10;
    path.lineCapStyle=kCGLineCapRound;
    [path moveToPoint:dot1];
    [path addQuadCurveToPoint:dot2 controlPoint:dot3];
    [path stroke];
}
-(void)drawcircle:(CGPoint)point1 :(CGPoint)point2
{
    NSLog(@"%@",NSStringFromSelector(_cmd));

    UIBezierPath* path=[[UIBezierPath alloc]init];
    path.lineWidth=10;
    CGPoint center=CGPointMake((point1.x+point2.x)/2, (point1.y+point2.y)/2);
    CGFloat radius=hypotf(point1.x-point2.x, point1.y-point2.y)/(2*sqrtf(2));
    CGPoint begin=CGPointMake(center.x+radius, center.y);
    [path moveToPoint:begin];
    [path addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    [path stroke];
}
#pragma mark - touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self.type==LINE) {
        for (UITouch* touch in touches) {
            NSValue* key=[NSValue valueWithNonretainedObject:touch];
            BNRLine* line=[[BNRLine alloc]init];
            line.begin=[touch locationInView:self];
            line.end=line.begin;
            line.width=10;
            line.color=[UIColor blackColor];
            self.currentLines[key]=line;
        }
    } else {
        if (self.type==CIRCLE) {
            for (UITouch* touch in touches) {
                if ([self.currentPoints count]==2) {
                    return;
                }
                NSValue* key=[NSValue valueWithNonretainedObject:touch];
                CGPoint point=[touch locationInView:self];
                self.currentPoints[key]=NSStringFromCGPoint(point);
            }
        } else {
            self.currentDot=[[touches anyObject] locationInView:self];
            [self.finishedCurves addObject:self.color];
            [self.finishedCurves addObject:NSStringFromCGPoint(self.currentDot)];


        }
    }
    
    [self setNeedsDisplay];
    
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
     NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self.type==LINE) {
        for (UITouch* touch in touches) {
            NSValue* key=[NSValue valueWithNonretainedObject:touch];
            BNRLine* line=self.currentLines[key];
            line.end=[touch locationInView:self];
            line.color=[self setcolor:line];
        }
    } else {
        if (self.type==CIRCLE) {
            for (UITouch* touch in touches) {
                NSValue* key=[NSValue valueWithNonretainedObject:touch];
                if (self.currentPoints[key]==nil) {
                    continue;
                }
                CGPoint point=[touch locationInView:self];
                self.currentPoints[key]=NSStringFromCGPoint(point);
            }
        } else {
            self.currentDot=[[touches anyObject] locationInView:self];
            [self.finishedCurves addObject:NSStringFromCGPoint(self.currentDot)];

        }
    }
    [self setNeedsDisplay];
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
     NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self.type==LINE) {
        for (UITouch* touch in touches) {
            NSValue* key=[NSValue valueWithNonretainedObject:touch];
            BNRLine* line=self.currentLines[key];
            [self.finishedLines addObject:line];
            [self.currentLines removeObjectForKey:key];
        }
    } else {
        if (self.type==CIRCLE) {
            for (UITouch* touch in touches) {
                NSValue* key=[NSValue valueWithNonretainedObject:touch];
                if (self.currentPoints[key]==nil) {
                    continue;
                }
//                NSMutableArray* a=[[NSMutableArray alloc]init];
//                for (NSValue*key in self.currentPoints) {
//                    [a addObject:self.currentPoints[key]];
//                }
                NSArray* a=[self.currentPoints allValues];
                [self.currentPoints removeAllObjects];
                if (a.count==2) {
                    BNRCircle* circle=[[BNRCircle alloc]initWithpoint:CGPointFromString(a[0]) :CGPointFromString(a[1]) color:self.color];
                    [self.finishedCircles addObject:circle];
                }
                
            }
        } else {
            self.currentDot=[[touches anyObject] locationInView:self];
            [self.finishedCurves addObject:NSStringFromCGPoint(self.currentDot)];
        }
    }
    [self setNeedsDisplay];
    
    
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.currentLines removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark - choose color implementation

-(void)choose:(UISwipeGestureRecognizer*)swipe
{
    NSLog(@"%@",NSStringFromSelector(_cmd));

    if (!self.wePopoverController) {
        
        ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
        self.wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        
        
        [self.wePopoverController presentPopoverFromRect:CGRectMake(0, 70, 250, 50)
                                                  inView:self
                                permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                                animated:YES];
        
    } else {
        [self.wePopoverController dismissPopoverAnimated:YES];
        self.wePopoverController = nil;
    }
    
}

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor{
    self.color = [GzColors colorFromHex:hexColor];
    [self.wePopoverController dismissPopoverAnimated:YES];
    self.wePopoverController = nil;
}
#pragma mark - save the data
-(NSString*)pathForSaving:(NSString*)str
{
    NSArray* directory=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* str1=directory[0];
    NSString* path=[str1 stringByAppendingPathComponent:str];
    return path;
}
-(BOOL)saveTheData
{
    BOOL a=[NSKeyedArchiver archiveRootObject:self.finishedCircles toFile:[self pathForSaving:@"finishedCircles"]];
    BOOL b=[NSKeyedArchiver archiveRootObject:self.finishedLines toFile:[self pathForSaving:@"finishedLines"]];
    BOOL c=[NSKeyedArchiver archiveRootObject:self.finishedCurves toFile:[self pathForSaving:@"finishedCurves"]];
    return a&b&c;
    
}

@end
