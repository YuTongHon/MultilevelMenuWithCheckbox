//
//  ViewController.m
//  MultilevelMenuWithCheckbox
//
//  Created by hyt on 2017/10/31.
//  Copyright © 2017年 hyt. All rights reserved.
//

#import "ViewController.h"
#import "MultilevelDataHandler.h"
#import "TableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sourcedata" ofType:@"text"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *dataSource = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers error:nil];
    
    MultilevelDataHandler *dataHandler = [MultilevelDataHandler sharedHandler];
    [dataHandler setLevelKeys:@[@"second_category", @"knowledge"]];
    [dataHandler setReDataSource:dataSource];
}

- (IBAction)pushAction:(id)sender {
        [self.navigationController pushViewController:[[TableViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
