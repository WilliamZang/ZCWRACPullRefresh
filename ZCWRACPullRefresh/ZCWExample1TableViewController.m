//
//  ZCWExample1TableViewController.m
//  ZCWRACPullRefresh
//
//  Created by ZangChengwei on 14-4-18.
//  Copyright (c) 2014年 ZCW. All rights reserved.
//

#import "ZCWExample1TableViewController.h"
#import "ZCWPullRefreshControl.h"
#import "ZCWLoadMoreControl.h"
#import "HZActivityIndicatorView.h"

@interface ZCWExample1TableViewController ()
@property (nonatomic, strong) ZCWPullRefreshControl *pullRefreshControl;
@property (nonatomic, strong) ZCWLoadMoreControl *loadMoreControl;
@end

@implementation ZCWExample1TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pullRefreshControl = [[ZCWPullRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 320.0, 65.0)];
    
    self.pullRefreshControl.backgroundColor = [UIColor grayColor];
    
     HZActivityIndicatorView *activityIndicatorView = [[ HZActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = self.pullRefreshControl.center;
    [self.pullRefreshControl addSubview:activityIndicatorView];
    [self.pullRefreshControl.pullRefreshState subscribeNext:^(RACTuple *values) {
        ZCWPullRefreshState state = [values.first intValue];
        switch (state) {
            case ZCWPullRefreshNormal:
                if (activityIndicatorView.isAnimating) {
                    [activityIndicatorView stopAnimating];
                }
                break;
            case ZCWPullRefreshLoading:
                if (!activityIndicatorView.isAnimating) {
                    [activityIndicatorView startAnimating];
                }
                break;
            case ZCWPullRefreshPulling:
                activityIndicatorView.progress = [values.second floatValue];
                break;
            default:
                break;
        }
    }];
    self.pullRefreshControl.refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            __block CGFloat progress = 0;
            [[RACScheduler mainThreadScheduler] after:[NSDate dateWithTimeIntervalSinceNow:1] repeatingEvery:1 withLeeway:0.1 schedule:^{
                progress += 0.1;
                [subscriber sendNext:@(progress)];
                if (progress > 1) {
                    [subscriber sendCompleted];
                }
            }];
             
            return nil;
        }];
    }];

    
    
    self.loadMoreControl = [[ZCWLoadMoreControl alloc] initWithFrame:CGRectMake(0, 0, 320.0, 65.0)];
    self.loadMoreControl.backgroundColor = [UIColor redColor];
    HZActivityIndicatorView *loadMoreActivityIndicatorView = [[ HZActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadMoreActivityIndicatorView.center = self.pullRefreshControl.center;
    [self.loadMoreControl addSubview:loadMoreActivityIndicatorView];

    [self.loadMoreControl.loadMoreState subscribeNext:^(RACTuple *values) {
        ZCWLoadMoreState state = [values.first intValue];
        switch (state) {
            case ZCWLoadMoreNormal:
                if (loadMoreActivityIndicatorView.isAnimating) {
                    [loadMoreActivityIndicatorView stopAnimating];
                }
                break;
            case ZCWLoadMoreLoading:
                if (!loadMoreActivityIndicatorView.isAnimating) {
                    [loadMoreActivityIndicatorView startAnimating];
                }
                break;
            case ZCWLoadMorePulling:
                loadMoreActivityIndicatorView.progress = [values.second floatValue];
                break;
            default:
                break;
        }

    }];
    
    self.loadMoreControl.loadMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            __block CGFloat progress = 0;
            [[RACScheduler mainThreadScheduler] after:[NSDate dateWithTimeIntervalSinceNow:1] repeatingEvery:1 withLeeway:1 schedule:^{
                progress += 0.1;
                [subscriber sendNext:@(progress)];
                if (progress > 1) {
                    [subscriber sendCompleted];
                }
            }];
            
            return nil;
        }];
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pullRefreshControl addToScrollView:self.tableView];
    [self.loadMoreControl addToScrollView:self.tableView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Example1" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadMoreControl.loadMoreCommand execute:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
