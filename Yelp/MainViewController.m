//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"
#import "JGProgressHUD.h"
#import "MapViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSDictionary *filters;

- (void) fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self fetchBusinessesWithQuery:@"Restaurants" params:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.title = @"Yelp";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"e.g. tacos, Max's";
    self.searchBar.delegate = self;
    
    self.navigationItem.titleView = self.searchBar;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    // Do the search...
    [self onSearchButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    self.searchBar.text = @"";
    self.filters = filters;
    [self fetchBusinessesWithQuery:@"Restaurants" params:filters];
    
    NSLog(@"fire new network event: %@", filters);
}

- (void) onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void) onSearchButton {
    NSString *searchTerm = self.searchBar.text;
    [self fetchBusinessesWithQuery:searchTerm params:self.filters];
}

- (void) onMapButton {
    MapViewController *vc = [[MapViewController alloc] init];
    
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    vc.businesses = self.businesses;
    [self presentViewController:nvc animated:YES completion:nil];
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void) fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.tableView];
    
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessesDictionaries = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:businessesDictionaries];
        
        [self.tableView reloadData];
        
        NSLog(@"test count: %lu", (unsigned long)self.businesses.count);
        if(self.businesses.count == 0){
            HUD.textLabel.text = @"No result found.";
            [HUD dismissAfterDelay:3.0];
        }else{
            [HUD dismissAfterDelay:1.0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HUD.textLabel.text = @"Error";
        [HUD dismissAfterDelay:3.0];
        NSLog(@"error: %@", [error description]);
    }];
}

@end
