//
//  SwitchCell.h
//  Yelp
//
//  Created by Joanna Chan on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

- (void) switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value;

@end

@interface SwitchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) id<SwitchCellDelegate> delegate;

- (void)setOn:(BOOL)on animated:(BOOL) animated;

@end
