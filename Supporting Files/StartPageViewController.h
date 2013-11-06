//
//  StartPageViewController.h
//  WeClub
//
//  Created by chao_mit on 13-5-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartPageViewController : UIViewController
<UIScrollViewDelegate>
{
	//定义UIScrollView与UIPageControl实例变量
	UIScrollView* scrollView;
	UIPageControl* pageControl;
	//定义滚动标志
    BOOL pageControlIsChangingPage;
    
	//定义图片文件名数组
	NSMutableArray *images;
    NSString *flag;
}
@property (retain, nonatomic) NSString *flag;
@property (assign, nonatomic) int inFlag;
/* UIPageControll的响应方法 */
- (void)changePage:(id)sender;

/* 内部方法，导入图片并进行UIScrollView的相关设置 */
- (void)setupPage;
@end
