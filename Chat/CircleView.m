//
//  CircleView.m
//  WeClub
//
//  Created by mitbbs on 13-7-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "CircleView.h"


@implementation CircleView

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
    //
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame text:(NSString *)text radius:(CGFloat)r {
    self = [self initWithFrame:frame];
    if(self) {
        self._text = text;
        self._r = r;
        if(text.length > 3) {
            self._fontSize = 10;
        }else {
            self._fontSize = 12;
        }
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    [self drawCircle:rect];
}

-(void)drawCircle:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, self._r * 0.15);
    CGFloat x =  rect.origin.x + rect.size.width - self._r - 0.5;
    CGFloat y = rect.origin.y + self._r + 0.5;
    CGContextAddArc(context, x, y, self._r, 0, 2*M_PI, YES);
    CGContextClosePath(context);
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    [self drawString:CGPointMake(x, y)];
    
}

-(void)drawString:(CGPoint)point {
    UIFont *font = [UIFont boldSystemFontOfSize:self._fontSize];
    CGSize subSize = [self._text sizeWithFont:font];
    CGFloat y = point.y - subSize.height / 2.0;
    CGFloat x = point.x - subSize.width / 2.0;
    [self._text drawAtPoint:CGPointMake(x, y) withFont:font];
}

-(void)changeText:(NSString *)strText{
    [self set_text:strText];
    [self setNeedsDisplay];
}

- (void)setStrFont:(CGFloat)font
{
    self._fontSize = font;
}

@end
