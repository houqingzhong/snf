//
//  SNFViewcontroller.m
//  snf
//
//  Created by 调伏自己 on 15/11/11.
//  Copyright © 2015年 调伏自己. All rights reserved.
//

#import "SNFViewcontroller.h"
#import "SNFHeader.h"
#import "SCLRTimeSelector.h"

@interface SNFViewcontroller()<UITableViewDataSource, UITableViewDelegate, SCLRTimeSelectorDelegate>
{
    UIProgressView  *_downloadProgressView;
}
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArray;
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
    
    self.dataArray = [NSMutableArray new];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"title"] = @"净空法师十念法－视频";
    dict[@"sub_title"] = @"日常生活当中，这个功夫要时时刻刻提得起，你遇到称心如意的事情，生欢喜心，生贪念心，那也是烦恼，要马上念佛把它伏住。遇到不如意的事情，生怨恨，生闷气时，也要把念佛功夫提起来，气就消掉了，怨恨就化解了。这就是古人所讲的“不怕念起，只怕觉迟”，念起不怕，佛号提起来就是觉，佛号忘掉就迷了迷了，你就随顺烦恼，就很苦了。觉了，不随顺烦恼，马上把烦恼降伏住，这叫功夫，这叫会念，这叫真念佛。因此，真念佛不在乎一天念多少声，印祖这个伏烦恼的念佛方法，非常有效果";
    dict[@"file_name"] = @"snf_jkfs";
    dict[@"type"] = @"mp4";
    [self.dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"title"] = @"八十八佛大忏悔文－视频";
    dict[@"sub_title"] = @"至诚礼拜八十八佛，最为殊胜，最为简便，亦最常用，极易感应，得见瑞相，身心轻安，足以证明，罪灭障除，堪可进功，修行办道。是故古德大善知识，将之列入早晚课诵。";
    dict[@"file_name"] = @"bsbf_qq";
    dict[@"type"] = @"mp4";
    [self.dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"title"] = @"《大悲咒》－视频";
    dict[@"sub_title"] = @"大悲咒为任何学佛者所必修，犹金钱为世人所必具，此咒能圆满众生一切愿望并治八万四千种病。观世音菩萨白佛言：“如众生诵持大悲咒，不生诸佛国者，不得无量三昧辩才者，于现在生中一切所求若不遂者，我誓不成正觉，惟除不善及不至诚”。南无大慈大悲圣观世音菩萨，愿诚心诵持此真言者，皆得涅槃。";
    dict[@"file_name"] = @"dbz_fhw";
    dict[@"type"] = @"mp4";
    [self.dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"title"] = @"金刚经－视频";
    dict[@"sub_title"] = @"能断一切法，能破一切烦恼，能成就佛道的般若大智慧，脱离苦海而登彼岸成就的经典。";
    dict[@"file_name"] = @"jgj_huashu";
    dict[@"type"] = @"mp4";
    [self.dataArray addObject:dict];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _downloadProgressView.progressTintColor = [UIColor redColor];
    _downloadProgressView.trackTintColor = [UIColor clearColor];

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *dict = _dataArray[indexPath.row];
    cell.textLabel.text = dict[@"title"];

    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = dict[@"sub_title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = _dataArray[indexPath.row];
    BOOL isPlay = [PublicMethod play:dict controller:self];
    if (!isPlay) {
        WS(ws);
        [[DownloadClient sharedInstance] setCallback:^(CGFloat progress, NSString *md5, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            [ws  updateDownloadProgress:progress];
        }];
        
        [self.tableView reloadData];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{

    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (0 == section && [DownloadClient sharedInstance].dataArray.count > 0) {
//        return 60;
//    }
    
    if (0 == section) {
        return 1;
    }

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        
        UITableViewHeaderFooterView *v = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Section_Header_ID"];
        
        if (nil == v) {
            v = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Section_Header_ID"];
            
            _downloadProgressView.frame = CGRectMake(0, 0, self.view.width, 1);
            
            [v addSubview:_downloadProgressView];
            
        }

        return v;
    }
    
    return nil;
}

- (void)updateDownloadProgress:(CGFloat)progress
{
    _downloadProgressView.progress = progress;
}


- (void)timeSelected:(NSDate *)date withHours:(int)hours
          andMinutes:(int) minutes forUserData:(id)userData
{
    
}

@end
