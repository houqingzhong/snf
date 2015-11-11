//
//  SNFViewcontroller.m
//  snf
//
//  Created by 调伏自己 on 15/11/11.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#import "SNFViewcontroller.h"
#import "SNFHeader.h"

@interface SNFViewcontroller()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation SNFViewcontroller

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = @[@"净空法师十念法－视频"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    [self.view addSubview:self.tableview];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"512fa609eade4ccd35fc4df95d9629f0" withExtension:@"f4v"];
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"snf_jkfs" withExtension:@"mp4"];


//    KxMovieViewController *player = [KxMovieViewController movieViewControllerWithContentPath:[videoURL path] parameters:nil];
//    [self presentViewController:player animated:YES completion:nil];
    
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [self presentMoviePlayerViewControllerAnimated:player];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 60;
}

@end