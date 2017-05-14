//
//  ViewController.m
//  CatEyeMovieScroll
//
//  Created by Sinno on 2017/5/14.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import "ViewController.h"
#import "UIView+NIMDemo.h"
#import "MoviePickerView.h"
@interface ViewController ()
@property(nonatomic,strong)UIView *centerLineView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MoviePickerView *movieView =[[MoviePickerView alloc]init];
    movieView.width = kScreenWidth;
    movieView.height = 160.0f;
    movieView.top = 100.0f;
    movieView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:movieView];
    [movieView refreshWithImageArray:@[@"movie1",@"movie2",@"movie3",@"movie4",@"movie5",@"movie6",@"movie7",@"movie8"]];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor redColor];
    view.width =1.0f;
    view.height = kScreenHeight;
    _centerLineView = view;
    [self.view addSubview:_centerLineView];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidLayoutSubviews{
    self.centerLineView.centerX = self.view.width/2.0f;
    //    self.scrollView.left = 15.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
