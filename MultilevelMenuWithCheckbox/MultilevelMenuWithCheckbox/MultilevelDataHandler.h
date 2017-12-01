//
//  MultilevelDataHandler.h
//  MultilevelMenuWithCheckbox
//
//  Created by hyt on 2017/10/31.
//  Copyright © 2017年 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultilevelMenuModel.h"

#define MMUIUPDATE @"UIShouldBeUpdate"

@interface MultilevelDataHandler : NSObject

+ (instancetype)sharedHandler;

/**
 Set keys of level Array

 @param keyArray keys
 */
- (void)setLevelKeys:(NSArray *)keyArray;

/**
 Set datasource

 @param dictArray datasource
 */
- (void)setReDataSource:(NSArray *)dictArray;

/**
 Make level show or hide
 
 @param model current model
 */
- (void)modelClicked:(MultilevelMenuModel *)model;

/**
 Change selected state

 @param model current model
 */
- (void)changModelSelecteState:(MultilevelMenuModel *)model;

/**
 All visible level

 @return All visible level
 */
- (NSArray<MultilevelMenuModel *> *)getShowingModelArray;

@end
