//
//  HLViewController.m
//  HLExtensions
//
//  Created by 757437150@qq.com on 01/10/2018.
//  Copyright (c) 2018 757437150@qq.com. All rights reserved.
//

#import "HLViewController.h"
#import "BlocksKit+UIKit.h"
#import "HLDefines.h"

#import "HLUser.h"

@interface HLViewController ()
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *addBtn;
@property (nonatomic,strong) UIButton *queryBtn;
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
    
//    @weakify(self);
    [self.addBtn bk_addEventHandler:^(id sender) {
//        @strongify(self);
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 10; i < 20; i++) {
            HLUser *user = [HLUser new];
            user.id = [NSNumber numberWithInt:i];
            user.name = [NSString stringWithFormat:@"name-%d",i];
//            user.age = [NSString stringWithFormat:@"%d",i];;
            user.num = i + 10;
            [arr addObject:user];
        }
        [HLUser saveObjects:arr];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.queryBtn bk_addEventHandler:^(id sender) {
//        @strongify(self);
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 18; i < 22; i++) {
            HLUser *user = [HLUser new];
            user.id = [NSNumber numberWithInt:i];
            user.name = [NSString stringWithFormat:@"name-%d",i];
            [arr addObject:user];
        }
        [HLUser objectsFromPersistenceWithKey:@"id" models:arr async:^(NSArray *objects) {
            NSLog(@"%@",objects);
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}


- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(100, 200, 50, 30);
        [_addBtn setTitle:@"新增" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:_addBtn];
    }
    return _addBtn;
}

- (UIButton *)queryBtn {
    if (!_queryBtn) {
        _queryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _queryBtn.frame = CGRectMake(100, 400, 50, 30);
        [_queryBtn setTitle:@"查询" forState:UIControlStateNormal];
        [_queryBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _queryBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:_queryBtn];
    }
    return _queryBtn;
}

@end
