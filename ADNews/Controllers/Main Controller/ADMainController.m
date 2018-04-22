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

@interface ADMainController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

static NSString *cellIdentifier = @"cell";

@implementation ADMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"title";
    UIBarButtonItem *bbItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable)];
    [self.navigationItem setRightBarButtonItem:bbItem];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView registerClass:[ADMainCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    [self frc];
}

- (void)viewWillLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)frc {
    if (!_frc) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([DBNews class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"publishedAt" ascending:YES]];
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

- (void)editTable {
    [[ADCoreDataManager shared] downloadNewsForType:DBNewsTypeEverything withOptions:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADMainCell *cell = [[ADMainCell alloc] init];
    DBNews *news = [self.frc.sections[indexPath.section] objects][indexPath.row];
    [cell configureWithNews:news];
    return [cell getHeightForWidth:CGRectGetWidth(tableView.frame) - 35];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
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



@end
