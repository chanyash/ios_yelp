//
//  FiltersViewController.m
//  Yelp
//
//  Created by Joanna Chan on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *sortingsCategories;
@property (nonatomic, strong) NSArray *distanceCategories;

@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) int selectedSortings;
@property (nonatomic, assign) int selectedDistance;
@property (nonatomic, assign) BOOL selectedDeal;

@property (nonatomic, assign) BOOL category_isShowingList;
@property (nonatomic, assign) BOOL sortings_isShowingList;
@property (nonatomic, assign) BOOL distance_isShowingList;


- (void) initCategories;
- (void) initSortingsCategories;
- (void) initDistanceCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
        [self initSortingsCategories];
        [self initDistanceCategories];
    }
    
    return self;
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.title = @"Filters";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    
    _category_isShowingList = NO;
    _sortings_isShowingList = NO;
    _distance_isShowingList = NO;
    _selectedDeal = NO;
    
    if(!_selectedSortings){
        _selectedSortings = 0;
    }
    
    if(!_selectedDistance){
        _selectedDistance = 0;
    }
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Sort by";
    }
    else if (section == 1){
        return @"Distance";
    }
    else if ( section == 2 ){
        return @"Popular";
    }
    else{
        return @"Categories";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    double footerHeight = 0.0;
    
    if(section == 3){
        footerHeight = 30.0;
    }
    
    UIView *sectionFooterView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.frame.size.width, footerHeight)];
    
    if(section == 3){
        if(self.categories.count > 4 && !self.category_isShowingList){
            // create a button with image and add it to the view
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, sectionFooterView.frame.size.width, footerHeight)];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:@"See All" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onfooterTapped) forControlEvents:UIControlEventTouchUpInside];
            
            [sectionFooterView addSubview:button];
        }
    }
    
    return sectionFooterView;
}

- (void) onfooterTapped {
    
    self.category_isShowingList = !self.category_isShowingList;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
    
    NSLog(@"You've tapped the footer!");
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (!self.sortings_isShowingList) {
            return 1;
        }else{
            return self.sortingsCategories.count;
        }
    }else if( section == 1 ){
        if(!self.distance_isShowingList){
            return 1;
        }else{
            return self.distanceCategories.count;
        }
    }else if( section == 2){
        return 1;
    }else{
        if(self.categories.count > 4 && !self.category_isShowingList){
            return 4;
        }else{
            return self.categories.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 3) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        cell.titleLabel.text = self.categories[indexPath.row][@"name"];
        cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
        cell.delegate = self;
    
        return cell;
    }else if([indexPath section] == 2){
        
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        cell.titleLabel.text = @"Offering a Deal";
        cell.on = self.selectedDeal;
        cell.delegate = self;
        
        return cell;
    
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        NSArray *data = self.sortingsCategories;
        int selectedIndex = self.selectedSortings;
        BOOL isShowingList = self.sortings_isShowingList;
        
        
        if([indexPath section] == 1){
            data = self.distanceCategories;
            selectedIndex = self.selectedDistance;
            isShowingList = self.distance_isShowingList;
        }
        
        if (!isShowingList) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", data[selectedIndex][@"name"]];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
        
            cell.textLabel.text = [NSString stringWithFormat:@"%@", data[[indexPath row]][@"name"]];
            
            if ([indexPath row] == selectedIndex) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] == 0) {
        
        if (self.sortings_isShowingList) {
            self.selectedSortings = (int) [indexPath row];
        }
        
        self.sortings_isShowingList = !self.sortings_isShowingList;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
        
    }else if([indexPath section] == 1) {
        
        if (self.distance_isShowingList) {
            self.selectedDistance = (int) [indexPath row];
        }
        
        self.distance_isShowingList = !self.distance_isShowingList;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
    
    }else{
        return;
    }
    
}


- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if([indexPath section] == 2){
        self.selectedDeal = value;
    }else{
        if(value) {
            [self.selectedCategories addObject:self.categories[indexPath.row]];
        }else {
            [self.selectedCategories removeObject:self.categories[indexPath.row]];
        }
    }
    
}

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if(self.selectedCategories.count > 0){
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories){
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    if(self.selectedSortings > 0){
        [filters setObject:self.sortingsCategories[self.selectedSortings][@"code"] forKey:@"sort"];
    }
    
    if(self.selectedDistance > 0){
        [filters setObject:self.distanceCategories[self.selectedDistance][@"code"] forKey:@"radius_filter"];
    }
    
    if(self.selectedDeal){
        [filters setObject:@"true" forKey:@"deals_filter"];
    }
    
    return filters;
    
}

- (void) onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) initDistanceCategories {
    self.distanceCategories = @[@{@"name" : @"Best matched", @"code": @""},
                                @{@"name" : @"0.3 miles", @"code": @"483"},
                                @{@"name" : @"1 mile", @"code": @"1610"},
                                @{@"name" : @"5 miles", @"code": @"8047"},
                                @{@"name" : @"20 miles", @"code": @"32187"}
                                ];
}

- (void) initSortingsCategories {
    self.sortingsCategories = @[@{@"name" : @"Best matched", @"code": @"0"},
                                @{@"name" : @"Distance", @"code": @"1"},
                                @{@"name" : @"Highest Rated", @"code": @"2"}
                                ];
}

- (void) initCategories {
    self.categories = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                            @{@"name" : @"African", @"code": @"african" },
                            @{@"name" : @"American, New", @"code": @"newamerican" },
                            @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                            @{@"name" : @"Arabian", @"code": @"arabian" },
                            @{@"name" : @"Argentine", @"code": @"argentine" },
                            @{@"name" : @"Armenian", @"code": @"armenian" },
                            @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                            @{@"name" : @"Asturian", @"code": @"asturian" },
                            @{@"name" : @"Australian", @"code": @"australian" },
                            @{@"name" : @"Austrian", @"code": @"austrian" },
                            @{@"name" : @"Baguettes", @"code": @"baguettes" },
                            @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                            @{@"name" : @"Barbeque", @"code": @"bbq" },
                            @{@"name" : @"Basque", @"code": @"basque" },
                            @{@"name" : @"Bavarian", @"code": @"bavarian" },
                            @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                            @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                            @{@"name" : @"Beisl", @"code": @"beisl" },
                            @{@"name" : @"Belgian", @"code": @"belgian" },
                            @{@"name" : @"Bistros", @"code": @"bistros" },
                            @{@"name" : @"Black Sea", @"code": @"blacksea" },
                            @{@"name" : @"Brasseries", @"code": @"brasseries" },
                            @{@"name" : @"Brazilian", @"code": @"brazilian" },
                            @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                            @{@"name" : @"British", @"code": @"british" },
                            @{@"name" : @"Buffets", @"code": @"buffets" },
                            @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                            @{@"name" : @"Burgers", @"code": @"burgers" },
                            @{@"name" : @"Burmese", @"code": @"burmese" },
                            @{@"name" : @"Cafes", @"code": @"cafes" },
                            @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                            @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                            @{@"name" : @"Cambodian", @"code": @"cambodian" },
                            @{@"name" : @"Canadian", @"code": @"New)" },
                            @{@"name" : @"Canteen", @"code": @"canteen" },
                            @{@"name" : @"Caribbean", @"code": @"caribbean" },
                            @{@"name" : @"Catalan", @"code": @"catalan" },
                            @{@"name" : @"Chech", @"code": @"chech" },
                            @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                            @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                            @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                            @{@"name" : @"Chilean", @"code": @"chilean" },
                            @{@"name" : @"Chinese", @"code": @"chinese" },
                            @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                            @{@"name" : @"Corsican", @"code": @"corsican" },
                            @{@"name" : @"Creperies", @"code": @"creperies" },
                            @{@"name" : @"Cuban", @"code": @"cuban" },
                            @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                            @{@"name" : @"Cypriot", @"code": @"cypriot" },
                            @{@"name" : @"Czech", @"code": @"czech" },
                            @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                            @{@"name" : @"Danish", @"code": @"danish" },
                            @{@"name" : @"Delis", @"code": @"delis" },
                            @{@"name" : @"Diners", @"code": @"diners" },
                            @{@"name" : @"Dumplings", @"code": @"dumplings" },
                            @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                            @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                            @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                            @{@"name" : @"Filipino", @"code": @"filipino" },
                            @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                            @{@"name" : @"Fondue", @"code": @"fondue" },
                            @{@"name" : @"Food Court", @"code": @"food_court" },
                            @{@"name" : @"Food Stands", @"code": @"foodstands" },
                            @{@"name" : @"French", @"code": @"french" },
                            @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                            @{@"name" : @"Galician", @"code": @"galician" },
                            @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                            @{@"name" : @"Georgian", @"code": @"georgian" },
                            @{@"name" : @"German", @"code": @"german" },
                            @{@"name" : @"Giblets", @"code": @"giblets" },
                            @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                            @{@"name" : @"Greek", @"code": @"greek" },
                            @{@"name" : @"Halal", @"code": @"halal" },
                            @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                            @{@"name" : @"Heuriger", @"code": @"heuriger" },
                            @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                            @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                            @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                            @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                            @{@"name" : @"Hungarian", @"code": @"hungarian" },
                            @{@"name" : @"Iberian", @"code": @"iberian" },
                            @{@"name" : @"Indian", @"code": @"indpak" },
                            @{@"name" : @"Indonesian", @"code": @"indonesian" },
                            @{@"name" : @"International", @"code": @"international" },
                            @{@"name" : @"Irish", @"code": @"irish" },
                            @{@"name" : @"Island Pub", @"code": @"island_pub" },
                            @{@"name" : @"Israeli", @"code": @"israeli" },
                            @{@"name" : @"Italian", @"code": @"italian" },
                            @{@"name" : @"Japanese", @"code": @"japanese" },
                            @{@"name" : @"Jewish", @"code": @"jewish" },
                            @{@"name" : @"Kebab", @"code": @"kebab" },
                            @{@"name" : @"Korean", @"code": @"korean" },
                            @{@"name" : @"Kosher", @"code": @"kosher" },
                            @{@"name" : @"Kurdish", @"code": @"kurdish" },
                            @{@"name" : @"Laos", @"code": @"laos" },
                            @{@"name" : @"Laotian", @"code": @"laotian" },
                            @{@"name" : @"Latin American", @"code": @"latin" },
                            @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                            @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                            @{@"name" : @"Malaysian", @"code": @"malaysian" },
                            @{@"name" : @"Meatballs", @"code": @"meatballs" },
                            @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                            @{@"name" : @"Mexican", @"code": @"mexican" },
                            @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                            @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                            @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                            @{@"name" : @"Modern European", @"code": @"modern_european" },
                            @{@"name" : @"Mongolian", @"code": @"mongolian" },
                            @{@"name" : @"Moroccan", @"code": @"moroccan" },
                            @{@"name" : @"New Zealand", @"code": @"newzealand" },
                            @{@"name" : @"Night Food", @"code": @"nightfood" },
                            @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                            @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                            @{@"name" : @"Oriental", @"code": @"oriental" },
                            @{@"name" : @"Pakistani", @"code": @"pakistani" },
                            @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                            @{@"name" : @"Parma", @"code": @"parma" },
                            @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                            @{@"name" : @"Peruvian", @"code": @"peruvian" },
                            @{@"name" : @"Pita", @"code": @"pita" },
                            @{@"name" : @"Pizza", @"code": @"pizza" },
                            @{@"name" : @"Polish", @"code": @"polish" },
                            @{@"name" : @"Portuguese", @"code": @"portuguese" },
                            @{@"name" : @"Potatoes", @"code": @"potatoes" },
                            @{@"name" : @"Poutineries", @"code": @"poutineries" },
                            @{@"name" : @"Pub Food", @"code": @"pubfood" },
                            @{@"name" : @"Rice", @"code": @"riceshop" },
                            @{@"name" : @"Romanian", @"code": @"romanian" },
                            @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                            @{@"name" : @"Rumanian", @"code": @"rumanian" },
                            @{@"name" : @"Russian", @"code": @"russian" },
                            @{@"name" : @"Salad", @"code": @"salad" },
                            @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                            @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                            @{@"name" : @"Scottish", @"code": @"scottish" },
                            @{@"name" : @"Seafood", @"code": @"seafood" },
                            @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                            @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                            @{@"name" : @"Singaporean", @"code": @"singaporean" },
                            @{@"name" : @"Slovakian", @"code": @"slovakian" },
                            @{@"name" : @"Soul Food", @"code": @"soulfood" },
                            @{@"name" : @"Soup", @"code": @"soup" },
                            @{@"name" : @"Southern", @"code": @"southern" },
                            @{@"name" : @"Spanish", @"code": @"spanish" },
                            @{@"name" : @"Steakhouses", @"code": @"steak" },
                            @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                            @{@"name" : @"Swabian", @"code": @"swabian" },
                            @{@"name" : @"Swedish", @"code": @"swedish" },
                            @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                            @{@"name" : @"Tabernas", @"code": @"tabernas" },
                            @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                            @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                            @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                            @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                            @{@"name" : @"Thai", @"code": @"thai" },
                            @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                            @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                            @{@"name" : @"Trattorie", @"code": @"trattorie" },
                            @{@"name" : @"Turkish", @"code": @"turkish" },
                            @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                            @{@"name" : @"Uzbek", @"code": @"uzbek" },
                            @{@"name" : @"Vegan", @"code": @"vegan" },
                            @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                            @{@"name" : @"Venison", @"code": @"venison" },
                            @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                            @{@"name" : @"Wok", @"code": @"wok" },
                            @{@"name" : @"Wraps", @"code": @"wraps" },
                            @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
  
}

@end
