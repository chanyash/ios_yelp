//
//  Business.h
//  Yelp
//
//  Created by Joanna Chan on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Business : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ratingImageUrl;
@property (nonatomic, assign) NSInteger numReviews;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries;

@end
