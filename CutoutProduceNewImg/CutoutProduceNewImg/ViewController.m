//
//  ViewController.m
//  CutoutProduceNewImg
//
//  Created by mac on 17/5/25.
//  Copyright © 2017年 cai. All rights reserved.
//

#import "ViewController.h"

#define SCREEN_Width    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_Height   ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIImageView *ringImgView;

@end

@implementation ViewController

#pragma mark -
- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 100, 100)];
        _imgView.backgroundColor = [UIColor orangeColor];
    }
    return _imgView;
}

- (UIImageView *)ringImgView
{
    if (!_ringImgView) {
        _ringImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_Width - 100 - 10, 100, 100, 100)];
        _ringImgView.backgroundColor = [UIColor orangeColor];
    }
    return _ringImgView;
}

//点击按钮 加载图片 并执行裁剪操作
- (IBAction)buttonAction:(id)sender {
    
    //1. 注意: 因为图片剪裁完毕后 要写入到一个图片文件中，这里不能使用UIView的图形上下文
    //2. 而在drawRect: 方法中获取的图形上下文都是与UIView相关的图形上下文 不是我们需要的
    //3. 当把图片剪裁完毕后保存到图片文件的时候 需要的是一个"与图片相关的图形上下文"
    
    //图片剪裁步骤:
    //1. 加载要剪裁的图片
    UIImage *image = [UIImage imageNamed:@"baby"];
    
    //2. 开启一个和要剪裁的图片一样大小的图形上下文
    //参数1: 开启的图片的图形上下文的大小
    //参数2: 是否透明
    //参数3: 缩放因子 0.0表示由手机屏幕的材质决定
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 1.0);
    
    //3. 获取刚才开启的图形上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    //4. 在这个图形上下文中绘制一个圆
    CGPoint centerP = CGPointMake(image.size.width * 0.5, image.size.height * 0.5);
    CGFloat r = MIN(image.size.width, image.size.height) * 0.5;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerP radius:r startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    //路径添加到上下文中
    CGContextAddPath(ref, path.CGPath);
    
    //5. 执行裁剪
    CGContextClip(ref);
    
    //6. 把图片绘制到上下文中
    [image drawAtPoint:CGPointZero];
    
    //7. 拿到当前图形上下文中的图片
    UIImage *imgCliped = UIGraphicsGetImageFromCurrentImageContext();
    self.imgView.image = imgCliped;
    
    //8. 关闭图形上下文
    UIGraphicsEndImageContext();
    
    //9. 保存 -->到沙盒
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [docu stringByAppendingPathComponent:@"clip.png"];
    
    NSData *imgData = UIImagePNGRepresentation(imgCliped);
    [imgData writeToFile:fileName atomically:YES];
    
    NSLog(@"%@", fileName);
    
}

//带圆环的裁剪图片
- (IBAction)ringBtnAction:(id)sender {
    
    //1. 加载要剪裁的图片
    UIImage *image = [UIImage imageNamed:@"dog"];
    
    //2. 根据要剪裁的图片的大小开启一个图片的图形上下文    -->0.0表示由手机屏幕的材质决定
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    
    //3. 获取当前的图片图形上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    //4. 向当前上下文中绘制一个圆环 (用来显示的圆环)
    //创建路径
    CGPoint centerP = CGPointMake(image.size.width * 0.5, image.size.height * 0.5);
    CGFloat r = MIN(image.size.width, image.size.height) * 0.5 - 5/2.0;//减去的为线宽的一半
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerP radius:r startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    //把路径添加到上下文
    CGContextAddPath(ref, path.CGPath);
    
    //设置状态信息
    CGContextSetLineWidth(ref, 5);
    [[UIColor redColor] set];
    
    //渲染
    CGContextDrawPath(ref, kCGPathStroke);
    
    //5. 绘制一个用来裁剪的圆
    UIBezierPath *pathClip = [UIBezierPath bezierPathWithArcCenter:centerP radius:r startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    //把路径添加到上下文
    CGContextAddPath(ref, pathClip.CGPath);
    
    //6. 执行裁剪
    CGContextClip(ref);
    
    //7. 把图片绘制到当前上下文中
    [image drawAtPoint:CGPointZero];
    
    //8. 取出上下文中的图片
    UIImage *imgCliped = UIGraphicsGetImageFromCurrentImageContext();
    
//    self.ringImgView.image = clipedImg;
    
    //9. 关闭图形上下文
    UIGraphicsEndImageContext();
    
    
    //得到的图片 大小仍为原大小 只不过看到的区域为我们裁剪过的
    //继续裁剪
    if (image.size.width != image.size.height) {
        //需要裁剪
        
        //计算中间要裁剪的区域
        CGFloat x = (image.size.width - MIN(image.size.width, image.size.height))/2.0;
        CGFloat y = (image.size.height - MIN(image.size.width, image.size.height))/2.0;
        CGFloat w = MIN(image.size.width, image.size.height);
        CGFloat h = w;
        
        //将x y w h由点转换为像素 -->因为UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0); 缩放因子给了0.0 跟随屏幕材质
        CGFloat scale = [UIScreen mainScreen].scale;
        x *= scale;
        y *= scale;
        w *= scale;
        h *= scale;
        
        //执行裁剪操作
        CGImageRef cgImage = CGImageCreateWithImageInRect(imgCliped.CGImage, CGRectMake(x, y, w, h));
        
        //把CGImage转换为UIImage
        imgCliped = [UIImage imageWithCGImage:cgImage];
        
        self.ringImgView.image = imgCliped;
        
        //释放
        CGImageRelease(cgImage);
    }
    
    
    
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [docu stringByAppendingPathComponent:@"clip.png"];
    
    NSData *imgData = UIImagePNGRepresentation(imgCliped);
    [imgData writeToFile:fileName atomically:YES];
    
    NSLog(@"%@", fileName);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.imgView];
    [self.view addSubview:self.ringImgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
