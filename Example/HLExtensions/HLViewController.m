//
//  HLViewController.m
//  HLExtensions
//
//  Created by 757437150@qq.com on 01/10/2018.
//  Copyright (c) 2018 757437150@qq.com. All rights reserved.
//

#import "HLViewController.h"
#import <HLExtensions/HLDefines.h>

@interface HLViewController ()
@property (nonatomic) UILabel *titleLabel;
@end

@implementation HLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 300, 200, 22)];
    _titleLabel.text = @"HLExtensions";
    _titleLabel.font = [UIFont systemFontOfSize:20];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
