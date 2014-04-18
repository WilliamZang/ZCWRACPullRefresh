//
//  ZCWLoadMoreControl.h
//  ZCWRACPullRefresh
//
//  Created by ZangChengwei on 14-4-18.
//  Copyright (c) 2014年 ZCW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

typedef enum : NSUInteger {
    ZCWLoadMoreNormal = 0,
    ZCWLoadMorePulling,
    ZCWLoadMoreLoading
} ZCWLoadMoreState;

@interface ZCWLoadMoreControl : UIView
@property (nonatomic, readonly) RACSignal *loadMoreState;

@property (nonatomic, strong) RACCommand *loadMoreCommand;

- (void)addToScrollView:(UIScrollView *)scrollView;

@end
