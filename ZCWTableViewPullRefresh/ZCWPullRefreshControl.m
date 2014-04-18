//
//  ZCWPullRefreshControl.m
//  ZCWRACPullRefresh
//
//  Created by ZangChengwei on 14-4-18.
//  Copyright (c) 2014年 ZCW. All rights reserved.
//

#import "ZCWPullRefreshControl.h"
#import "RACEXTScope.h"

@interface ZCWPullRefreshControl()

@property (nonatomic, strong) RACSubject *currentState;
@property (nonatomic, strong) RACSubject *progress;
@property (nonatomic, strong) RACDisposable *lastScrollViewDisposable;
@property (nonatomic, assign) UIEdgeInsets oldScrollViewContentInset;
@end

@implementation ZCWPullRefreshControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentState = [RACReplaySubject replaySubjectWithCapacity:1];
        [self.currentState sendNext:@(ZCWPullRefreshNormal)];
        self.progress = [RACSubject subject];
        [self.progress sendNext:@(0.0f)];
        _pullRefreshState = [self.currentState combineLatestWith:self.progress];
    }
    return self;
}

- (void)addToScrollView:(UIScrollView *)scrollView
{
    id<UIScrollViewDelegate> scrollViewDelegate = scrollView.delegate;
    if (scrollViewDelegate == nil) {
        scrollViewDelegate = (id<UIScrollViewDelegate>)self;
        scrollView.delegate = scrollViewDelegate;
    }

    [self removeFromSuperview];
    
    RACSignal *scrollViewDidScroll = [(NSObject *)scrollViewDelegate rac_signalForSelector:@selector(scrollViewDidScroll:) fromProtocol:@protocol(UIScrollViewDelegate)];

    CGRect selfFrame = self.frame;
    selfFrame.origin.y = -selfFrame.size.height;
    self.frame = selfFrame;
    
    [scrollView addSubview:self];
    self.oldScrollViewContentInset = scrollView.contentInset;
    [self.lastScrollViewDisposable isDisposed];
    @weakify(self);

    self.lastScrollViewDisposable = [[RACSignal combineLatest:@[self.currentState, scrollViewDidScroll]] subscribeNext:^(RACTuple *values) {
        @strongify(self);

        ZCWPullRefreshState stateValue = [values.first intValue];
        UIScrollView *_scrollView = [values.second first];
        CGFloat scrollViewOffsetY = _scrollView.contentOffset.y;
        BOOL isDragging = _scrollView.isDragging;
        
        switch (stateValue) {
            case ZCWPullRefreshNormal:
                if (isDragging && scrollViewOffsetY < -self.oldScrollViewContentInset.top) {
                    [self.currentState sendNext:@(ZCWPullRefreshPulling)];
                } else if (_scrollView.contentInset.top != self.oldScrollViewContentInset.top) {
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        _scrollView.contentInset = self.oldScrollViewContentInset;
                    }];
                }
                break;
            case ZCWPullRefreshPulling:
                if (!isDragging && scrollViewOffsetY < -self.oldScrollViewContentInset.top - self.frame.size.height) {
                    [self.currentState sendNext:@(ZCWPullRefreshLoading)];
                    [UIView animateWithDuration:0.3 animations:^{
                        UIEdgeInsets contentInset = _scrollView.contentInset;
                        contentInset.top += self.frame.size.height;
                        _scrollView.contentInset = contentInset;
                    }];
                    [[self.refreshCommand execute:self] subscribeNext:^(NSNumber *progress) {
                        if ([progress isKindOfClass:[NSNumber class]]) {
                            [self.progress sendNext:progress];
                        }
                    } error:^(NSError *error) {
                        [self.currentState sendNext:@(ZCWPullRefreshNormal)];
                    } completed:^{
                        [self.currentState sendNext:@(ZCWPullRefreshNormal)];
                    }];
                } else if (isDragging && scrollViewOffsetY < -self.oldScrollViewContentInset.top) {
                    CGFloat progress = (-scrollViewOffsetY - self.oldScrollViewContentInset.top) / self.frame.size.height;
                    [self.progress sendNext:@(progress > 1.0 ? 1.0 : progress)];
                } else if (!isDragging) {
                    [self.currentState sendNext:@(ZCWPullRefreshNormal)];
                }
                break;
            case ZCWPullRefreshLoading:
                break;
            default:
                break;
        }
    }];
}

@end
