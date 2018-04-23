//
//  ADMainController.m
//  ADNews
//
//  Created by Александр Дудырев on 21.04.2018.
//  Copyright © 2018 Александр Дудырев. All rights reserved.
//

#import "ADMainController.h"
#import "ADMainCell.h"

#import "ADNewsDetailController.h"

@interface ADMainController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (nonatomic, assign) DBNewsType newsType;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) NSFetchedResultsController *frc;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchText;

@end

static NSString *cellIdentifier = @"cell";

@implementation ADMainController

- (instancetype)initWithType:(DBNewsType)type
{
    self = [super init];
    if (self) {
        self.newsType = type;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.newsType = DBNewsTypeTopHeadlines;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.newsType) {
        case DBNewsTypeTopHeadlines: {
            self.title = @"Breaking";
            UIBarButtonItem *bbItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateNews)];
            self.navigationItem.rightBarButtonItem = bbItem;

        }
            break;
        case DBNewsTypeEverything: {
            self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
            self.searchBar.delegate = self;
            [self.searchBar setEnablesReturnKeyAutomatically:NO];
            self.navigationItem.titleView = self.searchBar;
            UIBarButtonItem *bbItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showHistory)];
            self.navigationItem.rightBarButtonItem = bbItem;
            
        }
        default:
            break;
    }
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView registerClass:[ADMainCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    [self frc];
}

- (void)viewDidAppear:(BOOL)animated {
    [[ADCoreDataManager shared] downloadNewsForType:self.newsType withOptions:nil];
}

- (void)viewWillLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}


#pragma mark - ADTabBarProtocol

- (BOOL)embeddedInNavigationController {
    return YES;
}

- (UIImage *)tabBarImage {
    switch (self.newsType) {
        case DBNewsTypeTopHeadlines:
            return [UIImage imageNamed:@"topheadline"];
        case DBNewsTypeEverything:
            return [UIImage imageNamed:@"everything"];
        default:
            break;
    }
}
- (NSString *)tabBarTitle {
    switch (self.newsType) {
        case DBNewsTypeTopHeadlines:
            return @"Fier";
        case DBNewsTypeEverything:
            return @"News";
        default:
            break;
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)frc {
    if (!_frc) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([DBNews class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"publishedAt" ascending:YES]];
        request.fetchBatchSize = 50;
        switch (self.newsType) {
            case DBNewsTypeTopHeadlines:
                request.predicate = [NSPredicate predicateWithFormat:@"type = %@", @(self.newsType)];
                break;
            case DBNewsTypeEverything:
                if (self.searchText && self.searchText.length != 0) {
                    request.predicate = [NSPredicate predicateWithFormat:@"textForSearch CONTAINS[cd] %@", self.searchText];
                }
                break;
            default:
                break;
        }
        
        _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:[[ADCoreDataManager shared] mainContext]
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
        _frc.delegate = self;
        NSError *error;
        if (![_frc performFetch:&error]) {
            NSLog(@"%@\n%@", error.localizedDescription, error.userInfo);
            abort();
        }
    }
    return _frc;
}

#pragma mark Actions

- (void)updateNews {
    switch (self.newsType) {
        case DBNewsTypeTopHeadlines:
            [[ADCoreDataManager shared] downloadNewsForType:DBNewsTypeEverything withOptions:nil];
            break;
        case DBNewsTypeEverything: {
            if (self.searchText && self.searchText.length != 0) {
                NSDictionary *options = @{
                                          ADOptionKeywords : self.searchText,
                                          };
                [[ADCoreDataManager shared] downloadNewsForType:DBNewsTypeEverything withOptions:options];
            }
        }
            break;
        default:
            break;
    }
}

- (void)showHistory {
    
}

#pragma mark TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [self.frc.sections[section] numberOfObjects];
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [self.frc.sections count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ADMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    DBNews *news = [self.frc.sections[indexPath.section] objects][indexPath.row];
    [cell configureWithNews:news];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADMainCell *cell = [[ADMainCell alloc] init];
    DBNews *news = [self.frc.sections[indexPath.section] objects][indexPath.row];
    [cell configureWithNews:news];
    return [cell getHeightForWidth:CGRectGetWidth(tableView.frame) - 35];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id <NSFetchedResultsSectionInfo> section = [[self.frc sections] objectAtIndex:indexPath.section];
    DBNews *news = [[section objects] objectAtIndex:indexPath.row];
    ADNewsDetailController *detailVC = [[ADNewsDetailController alloc] initWithNews:news];
    
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark NSFetchedResultsController Delegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(nullable NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(nullable NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller  {
    [self.tableView endUpdates];}




#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
    self.frc = nil;
    [self.tableView reloadData];
    [self frc];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (searchBar.text.length == 0) {
        return;
    }
    self.searchText = searchBar.text;
    [self updateNews];
}



@end
