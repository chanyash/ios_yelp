//
//  MapViewController.m
//  Yelp
//
//  Created by Joanna Chan on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapViewController.h"
#import "Business.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List View" style:UIBarButtonItemStylePlain target:self action:@selector(onListButton)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];;
    [self.locationManager requestAlwaysAuthorization];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
        
    }
    
    self.title = @"Map View";
    self.mapView.delegate = self;
    
    for (Business *business in self.businesses){
        [self.mapView addAnnotation:business];
    }
    
    
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) onListButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
