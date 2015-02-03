//
//  CategoriesViewController.h
//  Yelp
//
//  Created by Joanna Chan on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoriesViewController;

@protocol CategoriesViewControllerDelegate <NSObject>

- (void) categoriesViewController:(CategoriesViewController *) categoriesViewController didChangeCategories:(NSDictionary *)categories;

@end

@interface CategoriesViewController : UIViewController

@property (nonatomic, weak) id<CategoriesViewControllerDelegate> delegate;

@end
