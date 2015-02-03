//
//  Business.m
//  Yelp
//
//  Created by Joanna Chan on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if(self){
        @try {
            
            NSArray *categories = dictionary[@"categories"];
            NSMutableArray *categoryNames = [NSMutableArray array];
            [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                [categoryNames addObject:obj[0]];
            }];
            self.categories = [categoryNames componentsJoinedByString:@", "];
            
            self.name = self.title = dictionary[@"name"];
            self.imageUrl = dictionary[@"image_url"];
            
            NSString *street = [dictionary valueForKeyPath:@"location.address"][0];
            
            NSString *neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
            self.address = self.subtitle = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
            
            self.numReviews = [dictionary[@"review_count"] integerValue];
            self.ratingImageUrl = dictionary[@"rating_img_url"];
            float milesPerMeter = 0.000621371;
            self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
            
            
            MKCoordinateRegion region = { {0.0, 0.0}, {0.0, 0.0} };
            region.center.latitude = [[dictionary valueForKeyPath:@"location.coordinate.latitude"] doubleValue];
            region.center.longitude = [[dictionary valueForKeyPath:@"location.coordinate.longitude"] doubleValue];
            region.span.longitudeDelta = 0.01f;
            region.span.latitudeDelta = 0.01f;
            
            self.coordinate = region.center;
            
        } @catch (NSException *theException) {
            NSLog(@"An exception occurred: %@", theException.name);
            NSLog(@"Here are some details: %@", theException.reason);
        }
        
    }
    
    return self;
}

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries){
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        [businesses addObject:business];
    }
    
    return businesses;
}

@end
