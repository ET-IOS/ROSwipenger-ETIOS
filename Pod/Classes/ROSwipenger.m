//
//  ROSlidingPageController.m
//  Pods
//
//  Created by Heather Snepenger on 11/7/14.
//
//

#import "ROSwipenger.h"

#define TITLE_TAG_OFFSET 304
#define VC_TAG_OFFSET 832

#define SCROLL_CONTAINER_WIDTH 0

@interface ROSwipenger () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *titleScrollView;
@property (strong, nonatomic) UIView *titleContainer;
@property (strong, nonatomic) UIScrollView *pagingScrollView;
@property (strong, nonatomic) UIView *pagingContainer;

@property (strong, nonatomic) UIView *scrollIndicator;
@property (strong, nonatomic) UIView *scrollIndicatorContainer;
@property (strong, nonatomic) NSLayoutConstraint *leftOffsetConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topMarginConstraint;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;

@property (strong, nonatomic) NSLayoutConstraint *titleBackgroundHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *pagingContainerWidthConstraint;

@property (assign, nonatomic) CGFloat lastContentOffset;
@property (assign, nonatomic) CGFloat startingPageCenter;
@property (assign, nonatomic) BOOL buttonScrolling;


// defaults
@property (assign, nonatomic) NSInteger minTitleWidth;
@property (assign, nonatomic) CGFloat disabledTitleAlpha;
@property (assign, nonatomic) NSInteger childViewControllerWidth;

@property (assign, nonatomic) BOOL viewJustLoaded;

@end

@implementation ROSwipenger

- (id) initWithTitles:(NSArray *)titles andViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        self.scrollIndicatorAutoFitTitleWidth = YES;
        self.titles = [titles mutableCopy];
        self.childViewControllers = [viewControllers mutableCopy];
        
        self.currentPage = 0;
        
        // Make sure there are the same count of titles to view controllers
        assert(self.titles.count == self.childViewControllers.count);
    }
    return self;
}

- (id) initWithAttributedTitles:(NSArray *)attributedTitles andViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        self.scrollIndicatorAutoFitTitleWidth = YES;
        self.titles = [attributedTitles mutableCopy];
        self.childViewControllers = [viewControllers mutableCopy];
        
        self.currentPage = 0;
        
        // Make sure there are the same count of titles to view controllers
        assert(self.titles.count == self.childViewControllers.count);
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self setDefaultValues];
    [self setupViews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.currentPage == 0) {
        [self.swipeViewDelegate loadPageAtIndex:0];
    }
    self.viewJustLoaded = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // After the view is displayed, show the scroll indicator
    if (self.titles.count > 0 && self.viewJustLoaded) {
        if (self.currentPage !=0) {
            UIButton *firstButton = (UIButton *)[self.titleContainer viewWithTag:self.currentPage + TITLE_TAG_OFFSET];
            [self moveIndicatorUnderneathButtonWithTap:firstButton];
            
        }
        else{
            UIButton *firstButton = (UIButton *)[self.titleContainer viewWithTag:0 + TITLE_TAG_OFFSET];
            [self moveIndicatorUnderneathButton:firstButton];
        }
        
        
        self.scrollIndicatorContainer.hidden = NO;
    }
    
    self.viewJustLoaded = NO;
}

-(void)reloadViews:(int)atIndex{
    if (atIndex !=0) {
        UIButton *firstButton = (UIButton *)[self.titleContainer viewWithTag:atIndex + TITLE_TAG_OFFSET];
        [self moveIndicatorUnderneathButtonWithTap:firstButton];
        
        self.scrollIndicatorContainer.hidden = NO;
    }
    
    self.viewJustLoaded = NO;
}

-(void)moveToSpecificIndex:(NSInteger)index{
    
    UIButton * currentSelectedButton = (UIButton *)[self.titleContainer viewWithTag:_currentPage + TITLE_TAG_OFFSET];
    [self fadeOutOldButton:currentSelectedButton];
    
    self.currentPage = index;
    
    UIButton *firstButton = (UIButton *)[self.titleContainer viewWithTag:index + TITLE_TAG_OFFSET];
    [self moveIndicatorUnderneathButtonWithTap:firstButton];
}


- (void)setDefaultValues {
    if (!self.titlePadding)
        self.titlePadding = 50;
    
    if (!self.minTitleWidth)
        self.minTitleWidth = 80;
    
    if (!self.defaultScrollIndicatorWidth)
        self.defaultScrollIndicatorWidth = 80;
    
    if (!self.scrollIndicatorColor)
        self.scrollIndicatorColor = [UIColor grayColor];
    
    if (!self.scrollIndicatorHeight)
        self.scrollIndicatorHeight = 3;
    
    if (!self.childViewControllerWidth){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        self.childViewControllerWidth = screenWidth;
    }
    
    if (!self.titleBarBackground)
        self.titleBarBackground = _deSelectedTitleColor;
    
    if (!self.titleTextColor)
        self.titleTextColor = _deSelectedTitleColor;
    //[UIColor colorWithRed:48/255.0 green:167/255.0 blue:237/255.0 alpha:1.0];
    
    if (!self.titleBackgroundHeight)
        self.titleBackgroundHeight = 60.0f;
    
    self.disabledTitleAlpha = 1.0f;
}

- (void)setupViews {
    if (self.currentPage != 0) {
        
    }
    else{
        self.currentPage = 0;
    }
    self.startingPageCenter = self.childViewControllerWidth / 2;
    
    [self.view addSubview:self.titleScrollView];
    
    self.titleScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.titleScrollView addSubview:self.titleContainer];
    [self.titleScrollView addSubview:self.scrollIndicatorContainer];
    [self.scrollIndicatorContainer addSubview:self.scrollIndicator]; // the scrollIndicatorContainer has a constant width
    
    [self.view addSubview:self.pagingScrollView];
    [self.pagingScrollView addSubview:self.pagingContainer];
    
    
    [self addTitles];
    
    if (self.currentPage != 0) {
        [self loadViewControllerAtIndex:self.currentPage-1];
        [self loadViewControllerAtIndex:self.currentPage];
        if (self.currentPage< self.childViewControllers.count) {
            [self loadViewControllerAtIndex:self.currentPage+1];
            
        }
        
    }
    else{
        [self loadViewControllerAtIndex:0];
        [self loadViewControllerAtIndex:1];
    }
    
    [self updateConstraints];
    [self.view setNeedsUpdateConstraints];
    
}

- (void)updateConstraints {
    
    NSLayoutConstraint * leftConstraint = [NSLayoutConstraint constraintWithItem:self.titleScrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint * rightConstraint = [NSLayoutConstraint constraintWithItem:self.titleScrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:self.titleScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    self.titleBackgroundHeightConstraint = [NSLayoutConstraint constraintWithItem:self.titleScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.titleBackgroundHeight];
    [self.view addConstraints:@[leftConstraint, rightConstraint, topConstraint, self.titleBackgroundHeightConstraint]];

    NSLayoutConstraint * leftTitleConstraint = [NSLayoutConstraint constraintWithItem:self.titleContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleScrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint * rightTitleConstraint = [NSLayoutConstraint constraintWithItem:self.titleContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.titleScrollView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint * topTitleConstraint = [NSLayoutConstraint constraintWithItem:self.titleContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleScrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint * bottomTitleConstraint = [NSLayoutConstraint constraintWithItem:self.titleContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleScrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint * heightTitleConstraint = [NSLayoutConstraint constraintWithItem:self.titleContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.titleBackgroundHeight];

    [self.titleScrollView addConstraints:@[leftTitleConstraint, rightTitleConstraint, topTitleConstraint, bottomTitleConstraint, heightTitleConstraint]];
    
    // Set the scrollIndicator constraints
    [self updateScrollIndicatorHeight];
    [self.scrollIndicatorContainer autoSetDimension:ALDimensionWidth toSize:SCROLL_CONTAINER_WIDTH];
    self.heightConstraint = [self.scrollIndicatorContainer autoSetDimension:ALDimensionHeight toSize:self.scrollIndicatorHeight];
    
    [self.scrollIndicatorContainer autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    self.leftOffsetConstraint = [self.scrollIndicatorContainer autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleContainer withOffset:self.titlePadding];
    
    [self.scrollIndicator autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.scrollIndicator autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.scrollIndicator autoAlignAxisToSuperviewAxis:ALAxisVertical];
    self.widthConstraint = [self.scrollIndicator autoSetDimension:ALDimensionWidth toSize:self.minTitleWidth/2];
    
    [self.pagingScrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    self.topMarginConstraint = [self.pagingScrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleScrollView withOffset:0];
    [self pagingContainerWidthConstraint];
    [self.pagingContainer autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.pagingScrollView];
    
    [self.pagingContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    
    [super updateViewConstraints];
}

- (void) removeTitleAtIndex:(NSInteger)index {
    assert(index < self.titles.count && index > -1);
    
    [self.titles removeObjectAtIndex:index];
    [self.childViewControllers removeObjectAtIndex:index];
    
    [self reloadViews];
}

- (void)addTitle:(NSObject *)title withViewController:(UIViewController *)viewController {
    [self addTitle:title withViewController:viewController atIndex:self.titles.count];
}

- (void)addTitle:(NSObject *)title withViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    assert(index <= self.titles.count && index > -1);
    
    [self.titles insertObject:title atIndex:index];
    [self.childViewControllers insertObject:viewController atIndex:index];
    
    [self reloadViews];
}

- (void) selectTitleAtIndex:(NSInteger)index {
    [self moveIndicatorUnderneathButton:[self.titleContainer viewWithTag:index]];
}

- (void)reloadViews {
    [UIView animateWithDuration:0.15
                     animations:^{
                         // fade the title and paging containers out
                         self.titleContainer.alpha = 0.8;
                         self.pagingContainer.alpha = 0.8;
                     }
                     completion:^(BOOL finished) {
                         // Remove all the subviews from the title and paging container
                         [self.titleContainer.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
                         [self.pagingContainer.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
                         
                         [self addTitles];
                         self.pagingContainerWidthConstraint.constant = self.childViewControllerWidth * self.titles.count;
                         
                         if (self.currentPage == self.titles.count) {
                             self.currentPage--;
                         }
                         
                         [self fadeInNewButton:[self.titleContainer viewWithTag:self.currentPage + TITLE_TAG_OFFSET]];
                         [self loadViewControllerAtIndex:self.currentPage];
                         [self loadViewControllerAtIndex:self.currentPage - 1];
                         [self loadViewControllerAtIndex:self.currentPage + 1];
                         
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              // fade the title and paging containers back in
                                              self.titleContainer.alpha = 1;
                                              self.pagingContainer.alpha = 1;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTitles {
    
    for (int i = 0; i < self.titles.count; i++) {
        NSObject *titleObject = self.titles[i];
        UIButton *button;
        if ([titleObject isKindOfClass:[NSString class]]) {
            button = [self newButtonWithTitle:(NSString *)titleObject];
        } else if ([titleObject isKindOfClass:[NSAttributedString class]]) {
            button = [self newButtonWithAttributedString:(NSAttributedString *)titleObject];
        }
        
        button.alpha = self.disabledTitleAlpha;
        button.tag = i + TITLE_TAG_OFFSET;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7);
        [button addTarget:self action:@selector(moveIndicatorUnderneathButtonWithTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.titleContainer addSubview:button];
        
        if (i == 0) {
            
            NSLayoutConstraint * leftConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleContainer attribute:NSLayoutAttributeLeft multiplier:1 constant:self.titlePadding / 2];
            NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            NSLayoutConstraint * bottomConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self.titleContainer addConstraints:@[leftConstraint, topConstraint, bottomConstraint]];
        } else {
            UIView * leftView =  [self.view viewWithTag:i + TITLE_TAG_OFFSET - 1];
            NSLayoutConstraint * leftConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftView attribute:NSLayoutAttributeRight multiplier:1 constant:self.titlePadding / 2];
            NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            NSLayoutConstraint * bottomConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self.titleContainer addConstraints:@[leftConstraint, topConstraint, bottomConstraint]];

            if (i == self.titles.count - 1) {
                NSLayoutConstraint * rightConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.titleContainer attribute:NSLayoutAttributeRight multiplier:1 constant:-self.titlePadding / 2];
                [self.titleContainer addConstraints:@[rightConstraint]];
            }
        }
    }
    
}

- (UIButton *)newButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton newAutoLayoutView];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:self.titleTextColor forState:UIControlStateNormal];
    if (self.titleFont) {
        [button.titleLabel setFont:self.titleFont];
    }
    return button;
}

- (UIButton *)newButtonWithAttributedString:(NSAttributedString *)title {
    UIButton *button = [UIButton newAutoLayoutView];
    [button setAttributedTitle:title forState:UIControlStateNormal];
    return button;
}


- (void) loadViewControllerAtIndex:(NSInteger)index {
    
    if (index > self.childViewControllers.count - 1)
        return;
    
    
    UIViewController *childViewController = self.childViewControllers[index];
    if (!childViewController.view.superview) {
        
        [childViewController.view setTag:(index + VC_TAG_OFFSET)];
        
        [self addChildViewController:childViewController];
        [self.pagingContainer addSubview:childViewController.view];
        [childViewController didMoveToParentViewController:self];
        
        [childViewController.view autoSetDimension:ALDimensionWidth toSize:self.childViewControllerWidth];
        [childViewController.view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.pagingContainer];
        [childViewController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, index * self.childViewControllerWidth, 0, 0) excludingEdge:ALEdgeRight];
    }
}
- (void)moveIndicatorUnderneathButtonWithTap:(UIButton *)button {
    
    if([self.swipeViewDelegate respondsToSelector:@selector(shouldNotLoadPageAtIndex:)] && [self.swipeViewDelegate shouldNotLoadPageAtIndex:button.tag - TITLE_TAG_OFFSET] == true) {
        return;
    }
    
    [self moveIndicatorUnderneathButton:button];
    [self.swipeViewDelegate loadPageAtIndex:(int)button.tag - TITLE_TAG_OFFSET];
}

- (void) moveIndicatorUnderneathButton:(UIButton *)button {
    [self fadeOutOldButton:[self.titleContainer viewWithTag:self.currentPage + TITLE_TAG_OFFSET]];
    self.currentPage = button.tag - TITLE_TAG_OFFSET;
    [self fadeInNewButton:button];
    
    if (self.scrollIndicatorAutoFitTitleWidth) {
        self.widthConstraint.constant = button.frame.size.width;
    }
    self.buttonScrolling = YES;
    self.leftOffsetConstraint.constant = button.center.x;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.buttonScrolling = NO;
                     }];
    
    [self.pagingScrollView setContentOffset:CGPointMake(self.currentPage * self.childViewControllerWidth, self.pagingScrollView.contentOffset.y) animated:YES];
    
    
    // If the title is on the left hand side of the screen move the title bar over
    if ((button.frame.origin.x - self.titleScrollView.contentOffset.x) < self.titlePadding) {
        if (self.currentPage > 0) {
            CGFloat newOffset = self.titleScrollView.contentOffset.x - [self.titleContainer viewWithTag:self.currentPage + TITLE_TAG_OFFSET - 1].frame.size.width - self.titlePadding / 2;
            [self.titleScrollView setContentOffset:CGPointMake(MAX(0, newOffset), 0) animated:YES];
        } else { // if it's the first title, move all the way over
            [self.titleScrollView setContentOffset:CGPointZero animated:YES];
        }
    }
    
    // If the title is on the right hand side of the screen, move the title bar over to the right
    if (((button.frame.origin.x + button.frame.size.width) - self.titleScrollView.contentOffset.x) > (self.childViewControllerWidth - self.titlePadding)) {
        CGFloat leftOffset = self.titleScrollView.contentSize.width - self.titleScrollView.bounds.size.width;
        CGFloat newOffset = button.frame.origin.x-button.frame.size.width;
        //self.titleScrollView.contentOffset.x + [self.titleContainer viewWithTag:self.currentPage + TITLE_TAG_OFFSET + 1].frame.size.width + self.titlePadding / 2;
        if (self.currentPage < self.titles.count - 1) {
            [self.titleScrollView setContentOffset:CGPointMake(MIN(leftOffset, newOffset), 0) animated:YES];
        } else { // if it's the last title, move to the end
            [self.titleScrollView setContentOffset:CGPointMake(leftOffset, 0) animated:YES];
        }
    }
    [self loadViewControllerAtIndex:self.currentPage - 1];
    [self loadViewControllerAtIndex:self.currentPage];
    [self loadViewControllerAtIndex:self.currentPage + 1];
}

- (void)updateScrollIndicatorHeight {
    self.heightConstraint.constant = self.scrollIndicatorHeight;
    
    // Round the corners of the bar
    //  self.scrollIndicator.layer.cornerRadius = self.scrollIndicatorHeight / 2;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.pagingScrollView && !self.buttonScrolling) {
        
        if (self.pagingScrollView.contentOffset.x < 0 || (self.titles.count - 1) * self.childViewControllerWidth < self.pagingScrollView.contentOffset.x) {
            return;
        }
        
        CGFloat titleDistance;
        // get the distance based on direction of swipe
        if (self.lastContentOffset > self.pagingScrollView.contentOffset.x) {
            titleDistance = fabs([self.titleContainer viewWithTag:(self.currentPage + TITLE_TAG_OFFSET)- 1].center.x - [self.titleContainer viewWithTag:(self.currentPage + TITLE_TAG_OFFSET)].center.x);
            
        } else {
            titleDistance = fabs([self.titleContainer viewWithTag:(self.currentPage + TITLE_TAG_OFFSET)].center.x - [self.titleContainer viewWithTag:(self.currentPage + TITLE_TAG_OFFSET + 1)].center.x);
        }
        
        self.lastContentOffset = self.pagingScrollView.contentOffset.x;
        
        float b = titleDistance / self.childViewControllerWidth;
        float a = [self.titleContainer viewWithTag:(self.currentPage + TITLE_TAG_OFFSET)].center.x - b * (self.currentPage * self.childViewControllerWidth);
        
        self.leftOffsetConstraint.constant = (titleDistance / self.childViewControllerWidth) * self.pagingScrollView.contentOffset.x + a;
        
        [self.view layoutIfNeeded];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //    int page = self.pagingScrollView.contentOffset.x / self.childViewControllerWidth;
    //    if (page != self.currentPage) {
    //        [self.swipeViewDelegate loadPageAtIndex:page];
    //    }
    //    self.startingPageCenter = [self.pagingScrollView viewWithTag:(page + VC_TAG_OFFSET)].center.x;
    //    UIButton *currentButton = (UIButton *)[self.titleContainer viewWithTag:(page + TITLE_TAG_OFFSET)];
    //
    //    [self moveIndicatorUnderneathButton:currentButton];
    
    
    int page = self.pagingScrollView.contentOffset.x / self.childViewControllerWidth;
    if (page == self.currentPage) {
        
        self.startingPageCenter = [self.pagingScrollView viewWithTag:(page + VC_TAG_OFFSET)].center.x;
        UIButton *currentButton = (UIButton *)[self.titleContainer viewWithTag:(page + TITLE_TAG_OFFSET)];
        
        [self moveIndicatorUnderneathButton:currentButton];
    } else {
        self.startingPageCenter = [self.pagingScrollView viewWithTag:(page + VC_TAG_OFFSET)].center.x;
        UIButton *currentButton = (UIButton *)[self.titleContainer viewWithTag:(page + TITLE_TAG_OFFSET)];
        [self moveIndicatorUnderneathButton:currentButton];
        
        [self.swipeViewDelegate loadPageAtIndex:page];
    }
    
}

- (CGFloat) computeIndicatorOffset:(CGFloat)scrollViewOffset {
    return scrollViewOffset * (self.titlePadding + self.minTitleWidth) / self.childViewControllerWidth;
}

- (CGFloat) distanceBetweenTitles:(UIButton *)title1 andTitle2:(UIButton *)title2 {
    return fabs(title2.center.x - title1.center.x);
}

- (void) fadeOutOldButton:(UIView *)button {
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
        button.alpha = self.disabledTitleAlpha;
        NSMutableAttributedString * titleAttributedString = ((UIButton*)button).titleLabel.attributedText.mutableCopy;
        __block NSTextAttachment *textAttachment;
        [titleAttributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, titleAttributedString.length) options: 0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:[NSTextAttachment class]]) {
                textAttachment = value;
            }
        }];
        
        if (textAttachment) {
             [titleAttributedString setAttributes:@{NSFontAttributeName:weakSelf.titleFont, NSForegroundColorAttributeName:weakSelf.titleTextColor} range:NSMakeRange(1, titleAttributedString.length-1)];
        }
        else {
             [titleAttributedString setAttributes:@{NSFontAttributeName:weakSelf.titleFont, NSForegroundColorAttributeName:weakSelf.titleTextColor} range:NSMakeRange(0, titleAttributedString.length)];
        }
        [((UIButton*)button) setAttributedTitle:titleAttributedString forState:UIControlStateNormal];
    }];
    
}

- (void) fadeInNewButton:(UIView *)button {
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
        button.alpha = 1.0;
        
        NSMutableAttributedString * titleAttributedString = ((UIButton*)button).titleLabel.attributedText.mutableCopy;
        __block NSTextAttachment *textAttachment;
        [titleAttributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, titleAttributedString.length) options: 0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ([value isKindOfClass:[NSTextAttachment class]]) {
                textAttachment = value;
            }
        }];
        
        if (textAttachment) {
            [titleAttributedString setAttributes:@{NSFontAttributeName:weakSelf.selectedTitleFont, NSForegroundColorAttributeName:weakSelf.selectedTitleColor} range:NSMakeRange(1, titleAttributedString.length-1)];
        }
        else {
            [titleAttributedString setAttributes:@{NSFontAttributeName:weakSelf.selectedTitleFont, NSForegroundColorAttributeName:weakSelf.selectedTitleColor} range:NSMakeRange(0, titleAttributedString.length)];
        }
         [((UIButton*)button) setAttributedTitle:titleAttributedString forState:UIControlStateNormal];
    }];
}

#pragma mark - Getters
- (UIScrollView *)titleScrollView {
    if (!_titleScrollView) {
        _titleScrollView = [UIScrollView newAutoLayoutView];
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        
        if (@available(iOS 11, *)) {
            [_titleScrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
        
    }
    return _titleScrollView;
}

- (UIScrollView *)pagingScrollView {
    if (!_pagingScrollView) {
        _pagingScrollView = [UIScrollView newAutoLayoutView];
        _pagingScrollView.pagingEnabled = YES;
        _pagingScrollView.delegate = self;
        
        if(self.contentScrollEnable){
            _pagingScrollView.scrollEnabled = _contentScrollEnable.boolValue;
        }
        
        if (@available(iOS 11, *)) {
            [_pagingScrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }
    return _pagingScrollView;
}

- (UIView *)titleContainer {
    if (!_titleContainer) {
        _titleContainer = [UIView newAutoLayoutView];
    }
    return _titleContainer;
}

- (UIView *)scrollIndicator {
    if (!_scrollIndicator) {
        _scrollIndicator = [UIView newAutoLayoutView];
        _scrollIndicator.backgroundColor = self.scrollIndicatorColor;
    }
    return _scrollIndicator;
}

- (UIView *)scrollIndicatorContainer {
    if (!_scrollIndicatorContainer) {
        _scrollIndicatorContainer = [UIView newAutoLayoutView];
        _scrollIndicatorContainer.backgroundColor = [UIColor clearColor];
        _scrollIndicatorContainer.hidden = YES;
    }
    return _scrollIndicatorContainer;
}

- (UIView *)pagingContainer {
    if (!_pagingContainer) {
        _pagingContainer = [UIView newAutoLayoutView];
        _pagingContainer.backgroundColor = [UIColor clearColor];
    }
    return _pagingContainer;
}

- (NSLayoutConstraint *)pagingContainerWidthConstraint {
    if (!_pagingContainerWidthConstraint) {
        _pagingContainerWidthConstraint = [self.pagingContainer autoSetDimension:ALDimensionWidth toSize:self.childViewControllerWidth * self.titles.count];
    }
    return _pagingContainerWidthConstraint;
}

#pragma mark - Setters
-(void)setContentScrollEnable:(NSNumber *)contentScrollEnable {
    _contentScrollEnable = contentScrollEnable;
    if(_pagingScrollView){
        _pagingScrollView.scrollEnabled = contentScrollEnable.boolValue;
    }
}

- (void)setScrollIndicatorAutoFitTitleWidth:(BOOL)scrollIndicatorAutoFitTitleWidth {
    _scrollIndicatorAutoFitTitleWidth = scrollIndicatorAutoFitTitleWidth;
    self.widthConstraint.constant = self.defaultScrollIndicatorWidth;
}

- (void)setScrollIndicatorColor:(UIColor *)scrollIndicatorColor {
    _scrollIndicatorColor = scrollIndicatorColor;
    self.scrollIndicator.backgroundColor = scrollIndicatorColor;
}

- (void)setScrollIndicatorHeight:(NSInteger)scrollIndicatorHeight {
    _scrollIndicatorHeight = scrollIndicatorHeight;
    [self updateScrollIndicatorHeight];
}

- (void)setTitleBarBackground:(UIColor *)titleBarBackground {
    _titleBarBackground = titleBarBackground;
    self.titleScrollView.backgroundColor = self.titleBarBackground;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    for (int i = 0; i < self.titles.count; i++) {
        UIButton *button = (UIButton *)[self.titleContainer viewWithTag:(i + TITLE_TAG_OFFSET)];
        if (button) {
            [button setTitleColor:self.titleTextColor forState:UIControlStateNormal];
        }
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    for (int i = 0; i < self.titles.count; i++) {
        
        UIButton *button = (UIButton *)[self.titleContainer viewWithTag:(i + TITLE_TAG_OFFSET)];
        if (button && i != self.currentPage) {
            NSMutableAttributedString * titleAttributedString = button.titleLabel.attributedText.mutableCopy;
            [titleAttributedString setAttributes:@{NSFontAttributeName:self.titleFont} range:NSMakeRange(0, titleAttributedString.length)];
            __block NSTextAttachment *textAttachment;
            [titleAttributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, titleAttributedString.length) options: 0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                if ([value isKindOfClass:[NSTextAttachment class]]) {
                    textAttachment = value;
                }
            }];
            
            if (textAttachment) {
                 [titleAttributedString setAttributes:@{NSFontAttributeName:self.titleFont, NSForegroundColorAttributeName:self.titleTextColor} range:NSMakeRange(1, titleAttributedString.length-1)];
            }
            else {
                 [titleAttributedString setAttributes:@{NSFontAttributeName:self.titleFont, NSForegroundColorAttributeName:self.titleTextColor} range:NSMakeRange(0, titleAttributedString.length)];
            }
            [button setAttributedTitle:titleAttributedString forState:UIControlStateNormal];
        } else {
            
            if(self.selectedTitleFont){
                NSMutableAttributedString * titleAttributedString = button.titleLabel.attributedText.mutableCopy;
               __block NSTextAttachment *textAttachment;
                [titleAttributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, titleAttributedString.length) options: 0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                    if ([value isKindOfClass:[NSTextAttachment class]]) {
                        textAttachment = value;
                    }
                }];
                
                if (textAttachment) {
                    [titleAttributedString setAttributes:@{NSFontAttributeName:self.selectedTitleFont, NSForegroundColorAttributeName:self.selectedTitleColor} range:NSMakeRange(1, titleAttributedString.length-1)];
                }
                else {
                    [titleAttributedString setAttributes:@{NSFontAttributeName:self.selectedTitleFont, NSForegroundColorAttributeName:self.selectedTitleColor} range:NSMakeRange(0, titleAttributedString.length)];
                }
                 [((UIButton*)button) setAttributedTitle:titleAttributedString forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setSelectedTitleFont:(UIFont *)selectedTitleFont {
    _selectedTitleFont = selectedTitleFont;
    for (int i = 0; i < self.titles.count; i++) {
        UIButton *button = (UIButton *)[self.titleContainer viewWithTag:(i + TITLE_TAG_OFFSET)];
        if (button && i== self.currentPage) {
            NSMutableAttributedString * titleAttributedString = button.titleLabel.attributedText.mutableCopy;
            __block NSTextAttachment *textAttachment;
            [titleAttributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, titleAttributedString.length) options: 0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                if ([value isKindOfClass:[NSTextAttachment class]]) {
                    textAttachment = value;
                }
            }];
            
            if (textAttachment) {
                [titleAttributedString setAttributes:@{NSFontAttributeName:self.selectedTitleFont, NSForegroundColorAttributeName:self.selectedTitleColor} range:NSMakeRange(1, titleAttributedString.length-1)];
            }
            else {
                [titleAttributedString setAttributes:@{NSFontAttributeName:self.selectedTitleFont, NSForegroundColorAttributeName:self.selectedTitleColor} range:NSMakeRange(0, titleAttributedString.length)];
            }
             [((UIButton*)button) setAttributedTitle:titleAttributedString forState:UIControlStateNormal];
        }
    }
}

- (void)setTitleBackgroundHeight:(CGFloat)titleBackgroundHeight {
    _titleBackgroundHeight = titleBackgroundHeight;
    self.titleBackgroundHeightConstraint.constant = titleBackgroundHeight;
}

-(void)showOptions:(BOOL)toShow{
    
    BOOL isHeightChanged = false;
    if(toShow == false) {
        self.topMarginConstraint.constant = -(self.titleBackgroundHeight);
        [self.scrollIndicator setHidden:true];
        isHeightChanged = true;
    } else if(self.topMarginConstraint.constant != 0) {
        self.topMarginConstraint.constant = 0;
        [self.scrollIndicator setHidden:false];
        isHeightChanged = true;
    }
    
    if(isHeightChanged == true){
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

@end

