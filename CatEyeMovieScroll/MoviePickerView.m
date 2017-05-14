//
//  MoviePickerView.m
//  CatEyeMovieScroll
//
//  Created by Sinno on 2017/5/14.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import "MoviePickerView.h"
#import "UIView+NIMDemo.h"

#define SCROLLVIEW_HEIGHT 150.0f
#define singleMaxWidth 100.0f
#define singleMaxHeight 130.0f
#define SMIN 0.8f
#define SMAX 0.9f
@interface MoviePickerView ()<UIScrollViewDelegate>

/**
 滚动视图
 */
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIImageView *backgroundImageView;
@property(nonatomic,strong)NSMutableArray<UIView* >* viewArrays;
@property(nonatomic,strong)NSArray<NSString*> *imageArray;
@property(nonatomic,strong)UIVisualEffectView *effectView;
@end

@implementation MoviePickerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.scrollView];
    }
    return self;
}

-(UIScrollView*)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.decelerationRate = 0.01f;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}
-(UIImageView*)backgroundImageView{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        self.effectView = effectView;
        [_backgroundImageView addSubview:effectView];
    }
    return _backgroundImageView;
}
-(NSMutableArray*)viewArrays{
    if (!_viewArrays) {
        _viewArrays = [NSMutableArray array];
    }
    return _viewArrays;
}
-(void)refreshWithImageArray:(NSArray<NSString*>*)imageArray{
    NSArray *newImageArray = [imageArray copy];
    if ([self.imageArray isEqualToArray:newImageArray]) {
        return;
    }
    self.imageArray = newImageArray;
    // 不相同 移除scrollView上所有子视图，再加上去
    for (UIView*subView in self.viewArrays) {
        [subView removeFromSuperview];
    }
    // 移除所有视图
    [self.viewArrays removeAllObjects];
    CGFloat imageViewWidth = singleMaxWidth *SMIN;// 初始都是最小值
    CGFloat imageViewHeight = singleMaxHeight *SMIN;// 初始都是最小值
    NSInteger viewCount = imageArray.count;
    for (int i = 0 ; i<imageArray.count; i++) {
        NSString *imageName = imageArray[i];
        CGFloat centerX = i*singleMaxWidth + singleMaxWidth/2.0f;
        CGFloat left = centerX - imageViewWidth/2.0f;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, 0, imageViewWidth, imageViewHeight)];
        imageView.bottom = self.height - 20.0f;
        imageView.backgroundColor = [UIColor purpleColor];// 背景颜色
        imageView.image = [UIImage imageNamed:imageName];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewClicked:)];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:imageView];
        [self.viewArrays addObject:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(viewCount*singleMaxWidth, 100);
    _scrollView.delegate = self;
    //        _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = NO;
    CGFloat insetLeft = (kScreenWidth - singleMaxWidth)/2.0f;
    _scrollView.contentInset = UIEdgeInsetsMake(0, insetLeft, 0, insetLeft);
    [_scrollView setContentOffset:CGPointMake(0-_scrollView.contentInset.left, 0) animated:YES];
    [self movieSlectedWithOffset:_scrollView.contentOffset.x];
}
-(void)imageViewClicked:(UITapGestureRecognizer*)recognizer{
    CGFloat centerX = recognizer.view.centerX;
    CGFloat offsetX = centerX - self.width/2.0f;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //    NSLog(@" x:%.1f,y:%.1f,scrollHeight-%.1f",scrollView.contentOffset.x,scrollView.contentOffset.y,scrollView.height);
    
    CGFloat centerLineX = kScreenWidth/2.0f;
    CGFloat allX = scrollView.contentOffset.x + centerLineX;
    CGFloat buttonAllWidth = singleMaxWidth;
    
    for (UIView*view in self.viewArrays) {
        CGFloat centerX = view.centerX;
        CGFloat bottom = view.bottom;
        
        CGFloat cha = fabs(allX - centerX);
        if (cha>singleMaxWidth) {
            view.height = singleMaxHeight *SMIN;
            view.width = singleMaxWidth *SMIN;
            view.centerX = centerX;
            view.bottom = bottom;
        }else{
            view.width = singleMaxWidth *SMIN +((singleMaxWidth-cha)/singleMaxWidth)*(singleMaxWidth*(SMAX-SMIN));
            view.height = singleMaxHeight *SMIN +((singleMaxWidth-cha)/singleMaxWidth)*(singleMaxHeight*(SMAX-SMIN));
            view.bottom = bottom;
            view.centerX = centerX;
        }
    }
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    // 取到将要滚动到的位置的x值
    CGFloat x = targetContentOffset->x;
    // 中线所在位置
    CGFloat centerLinex = x + scrollView.width/2.0f;
    //
    int shang = centerLinex / (singleMaxWidth);
    // fmodf 取余
    // 当前基准线的位置
    CGFloat yu  = fmodf(centerLinex, singleMaxWidth);
    CGFloat resultY = 0.0f;
    CGFloat cha = (yu - singleMaxWidth/2.0f);
    if (cha>0) {
        resultY = x - cha;
    }else{
        resultY = x - cha;
    }
    
    *targetContentOffset = CGPointMake(resultY, 0);
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        NSLog(@"用户手已移开,但是还将因惯性滚动");
    }else{
        NSLog(@"用户手移开，停止滚动了");
        [self movieSlectedWithOffset:scrollView.contentOffset.x];
        
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"停止滚动");
    [self movieSlectedWithOffset:scrollView.contentOffset.x];
}
-(void)movieSlectedWithOffset:(CGFloat)offset{
    CGFloat allWidth = offset + self.width/2.0f;
    NSInteger index =  fabs(allWidth/singleMaxWidth);
    NSString *imageName = self.imageArray[index];
    NSLog(@"选中%@",imageName);
    self.backgroundImageView.image = [UIImage imageNamed:imageName];
}

#pragma mark 子视图布局
-(void)layoutSubviews{
    self.backgroundImageView.frame = self.bounds;
    self.scrollView.frame = self.bounds;
    self.effectView.frame = self.backgroundImageView.bounds;
}
@end
