//
//  ROSlidingPageController.h
//  Pods
//
//  Created by Heather Snepenger on 11/7/14.
//
//

#import <UIKit/UIKit.h>
#import <PureLayout/PureLayout.h>
@protocol swipeDelegate <NSObject>
-(void) loadPageAtIndex:(int)index;

@optional
-(BOOL) shouldNotLoadPageAtIndex:(NSInteger)index;
@end


@interface ROSwipenger : UIViewController

@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *childViewControllers;
@property(nonatomic, weak) id<swipeDelegate> swipeViewDelegate;

// Colors
@property (strong, nonatomic) UIColor *titleBarBackground;
@property (strong, nonatomic) UIColor *titleTextColor;
@property (strong, nonatomic) UIColor *scrollIndicatorColor;
@property (strong, nonatomic) UIColor *selectedTitleColor;
@property (strong, nonatomic) UIColor *deSelectedTitleColor;
@property (strong, nonatomic) NSNumber *contentScrollEnable;

// Font
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIFont *selectedTitleFont;

// Dimensions
@property (assign, nonatomic) CGFloat titleBackgroundHeight;
@property (assign, nonatomic) NSInteger titlePadding;
@property (assign, nonatomic) NSInteger scrollIndicatorHeight;
@property (assign, nonatomic) NSInteger defaultScrollIndicatorWidth;
@property (assign, nonatomic) NSInteger currentPage;

-(void)moveToSpecificIndex:(NSInteger)index;
-(void)showOptions:(BOOL)toShow;

@property (assign, nonatomic) BOOL scrollIndicatorAutoFitTitleWidth;

- (id) initWithTitles:(NSArray *)titles andViewControllers:(NSArray *)viewControllers;
- (id) initWithAttributedTitles:(NSArray *)attributedTitles andViewControllers:(NSArray *)viewControllers;

/**
 *  remove a title and corresponding view controller at a given index
 *
 *  @param index to be removed
 */
- (void) removeTitleAtIndex:(NSInteger)index;
/**
 *  Add a title and view controller at the end of the scrollviews
 *
 *  @param title          to be added
 *  @param viewController to be added
 */
- (void) addTitle:(NSObject *)title withViewController:(UIViewController *)viewController;
/**
 *  Add a title and view controller at the end of the scrollviews
 *
 *  @param title          to be added
 *  @param viewController to be added
 *  @param index          to be added at
 */
- (void) addTitle:(NSObject *)title withViewController:(UIViewController *)viewController atIndex:(NSInteger)index;
-(void)reloadViews:(int)atIndex;
@end
