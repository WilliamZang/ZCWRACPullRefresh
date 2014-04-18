//
//  ZCWLoadMoreControl.m
//  ZCWRACPullRefresh
//
//  Created by ZangChengwei on 14-4-18.
//  Copyright (c) 2014年 ZCW. All rights reserved.
//

#import "ZCWLoadMoreControl.h"
#import "RACEXTScope.h"

@interface ZCWLoadMoreControl()

@property (nonatomic, strong) RACSubject *currentState;
@property (nonatomic, strong) RACSubject *progress;
@property (nonatomic, strong) RACDisposable *lastScrollViewDisposable;
@property (nonatomic, assign) UIEdgeInsets oldScrollViewContentInset;
@end

@implementation ZCWLoadMoreControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentState = [RACReplaySubject replaySubjectWithCapacity:1];
        [self.currentState sendNext:@(ZCWLoadMoreNormal)];
        self.progress = [RACSubject subject];
        [self.progress sendNext:@(0.0f)];
        _loadMoreState = [self.currentState combineLatestWith:self.progress];
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
    selfFrame.origin.y = scrollView.contentSize.height;
    self.frame = selfFrame;
    
    [scrollView addSubview:self];
    self.oldScrollViewContentInset = scrollView.contentInset;
    [self.lastScrollViewDisposable isDisposed];
    @weakify(self);
    
    self.lastScrollViewDisposable = [[RACSignal combineLatest:@[self.currentState, scrollViewDidScroll]] subscribeNext:^(RACTuple *values) {
        @strongify(self);
        
        ZCWLoadMoreState stateValue = [values.first intValue];
        UIScrollView *_scrollView = [values.second first];
        CGFloat scrollViewOffsetY = _scrollView.contentOffset.y;
        BOOL isDragging = _scrollView.isDragging;
        
//        NSLog(@"%d, %@, %f", stateValue, isDragging? @"YES": @"NO", scrollViewOffsetY);
        switch (stateValue) {
            case ZCWLoadMoreNormal:
                if (isDragging && scrollViewOffsetY + _scrollView.frame.size.height > _scrollView.contentSize.height) {
                    [self.currentState sendNext:@(ZCWLoadMorePulling)];
                } else if (_scrollView.contentInset.bottom != self.oldScrollViewContentInset.bottom) {
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        _scrollView.contentInset = self.oldScrollViewContentInset;
                    }];
                }
                break;
            case ZCWLoadMorePulling:
                if (!isDragging && scrollViewOffsetY + _scrollView.frame.size.height > _scrollView.contentSize.height + self.frame.size.height) {
                    [self.currentState sendNext:@(ZCWLoadMoreLoading)];
                    [UIView animateWithDuration:0.3 animations:^{
                        UIEdgeInsets contentInset = _scrollView.contentInset;
                        contentInset.bottom += self.frame.size.height;
                        _scrollView.contentInset = contentInset;
                    }];
                    [[self.loadMoreCommand execute:self] subscribeNext:^(NSNumber *progress) {
                        if ([progress isKindOfClass:[NSNumber class]]) {
                            [self.progress sendNext:progress];
                        }
                    } error:^(NSError *error) {
                        [self.currentState sendNext:@(ZCWLoadMoreNormal)];
                    } completed:^{
                        [self.currentState sendNext:@(ZCWLoadMoreNormal)];
                    }];
                } else if (isDragging && scrollViewOffsetY + _scrollView.frame.size.height > _scrollView.contentSize.height) {
                    CGFloat progress = (scrollViewOffsetY + _scrollView.frame.size.height - _scrollView.contentSize.height) / self.frame.size.height;
                    [self.progress sendNext:@(progress > 1.0 ? 1.0 : progress)];
                } else if (!isDragging) {
                    [self.currentState sendNext:@(ZCWLoadMoreNormal)];
                }
                break;
            case ZCWLoadMoreLoading:
                break;
            default:
                break;
        }
    }];
}



@end
