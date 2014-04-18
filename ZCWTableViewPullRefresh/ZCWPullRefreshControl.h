//
//  ZCWPullRefreshControl.h
//  ZCWRACPullRefresh
//
//  Created by ZangChengwei on 14-4-18.
//  Copyright (c) 2014年 ZCW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

typedef enum : NSUInteger {
    ZCWPullRefreshNormal = 0,
    ZCWPullRefreshPulling,
    ZCWPullRefreshLoading
} ZCWPullRefreshState;


@interface ZCWPullRefreshControl : UIView

@property (nonatomic, readonly) RACSignal *pullRefreshState;

@property (nonatomic, strong) RACCommand *refreshCommand;

- (void)addToScrollView:(UIScrollView *)scrollView;

@end
