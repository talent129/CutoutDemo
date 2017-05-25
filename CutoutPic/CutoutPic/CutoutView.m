//
//  CutoutView.m
//  CutoutPic
//
//  Created by mac on 17/5/25.
//  Copyright © 2017年 cai. All rights reserved.
//

#import "CutoutView.h"

@implementation CutoutView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //裁剪圆形
    //获取上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    //绘制一个图形到上下文中
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
    
    CGContextAddPath(ref, path.CGPath);
    
    //执行裁剪
    CGContextClip(ref);
    
    //加载要剪裁的图片
    UIImage *image = [UIImage imageNamed:@"girl"];
    
    //把要裁剪的图片绘制到当前上下文中
    [image drawAtPoint:CGPointZero];
    
}

@end
