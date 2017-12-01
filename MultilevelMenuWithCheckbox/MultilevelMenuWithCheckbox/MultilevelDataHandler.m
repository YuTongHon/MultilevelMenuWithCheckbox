//
//  MultilevelDataHandler.m
//  MultilevelMenuWithCheckbox
//
//  Created by hyt on 2017/10/31.
//  Copyright © 2017年 hyt. All rights reserved.
//

#import "MultilevelDataHandler.h"
#import "MultilevelMenuModel.h"


@interface MultilevelDataHandler()

@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic, copy) NSArray *modelArray;
@property (nonatomic, strong) NSMutableArray<MultilevelMenuModel *> *showData;
@property (nonatomic, copy) NSArray *levelKey;

@end


@implementation MultilevelDataHandler

+ (instancetype)sharedHandler {
    
    static MultilevelDataHandler *handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        handler = [[MultilevelDataHandler alloc] init];
        
    });
    return handler;
}

#pragma mark - DataSource
- (void)setLevelKeys:(NSArray *)keyArray {
    self.levelKey = keyArray;
}

- (void )setReDataSource:(NSArray *)dictArray {
    self.dataSource = dictArray;
    self.modelArray = [NSArray arrayWithArray:[self getModelArrayFromDictArray:dictArray
                                                                    modelLevel:0
                                                                    superIndex:0
                                                                 locationArray:[NSMutableArray arrayWithCapacity:self.levelKey.count]]];
    self.showData = [NSMutableArray arrayWithArray:self.modelArray];
}

- (NSArray *)getShowingModelArray {
    return  self.showData;
}

- (NSString *)getSubKeyByModel:(MultilevelMenuModel *)model {
    return  [self.levelKey objectAtIndex:model.MMLevel];
}

- (BOOL)checkModelHasSubArray:(MultilevelMenuModel *)model {
    if (model.MMLevel >= self.levelKey.count) {
        return NO;
    }
    NSString *key = [self getSubKeyByModel:model];
    NSArray *subArray = model.dataDict[key];
    if (subArray.count > 0) {
        return YES;
    }
    return  NO;
}

- (void)setModelSubArray:(MultilevelMenuModel *)model {
    NSString *key = [self getSubKeyByModel:model];
    NSArray *subDictArray = model.dataDict[key];
    model.MMSubArray = [self getModelArrayFromDictArray:subDictArray
                                             modelLevel:model.MMLevel + 1
                                             superIndex:model.MMIndex
                                          locationArray:model.locationArray];
}

- (MultilevelMenuModel *)getModelByDict:(NSDictionary *)dict
                             modelLevel:(NSInteger)level
                             modelIndex:(NSInteger)index
                             superIndex:(NSInteger)superIndex
                          locationArray:(NSMutableArray *)loactionArray{
    
    MultilevelMenuModel *levelModel = [[MultilevelMenuModel alloc] init];
    levelModel.MMLevel = level;
    levelModel.MMIndex = index++;
//    levelModel.MMSuperIndex = superIndex;
    levelModel.dataDict = [NSDictionary dictionaryWithDictionary:dict];
    levelModel.locationArray = [NSMutableArray arrayWithArray:loactionArray];
    [levelModel.locationArray addObject:[NSNumber numberWithInteger:superIndex]];
    
    if ([self checkModelHasSubArray:levelModel]) {
        [self setModelSubArray:levelModel];
    }
    return levelModel;
}

- (NSArray *)getModelArrayFromDictArray:(NSArray *)dictArray
                             modelLevel:(NSInteger)level
                             superIndex:(NSInteger)superIndex
                          locationArray:(NSMutableArray *)locationArray{

    NSMutableArray *deArray = [NSMutableArray array];
    NSInteger index = 0;
    for (NSDictionary *dict in dictArray) {
        MultilevelMenuModel *levelModel = [self getModelByDict:dict
                                                    modelLevel:level
                                                    modelIndex:index++
                                                    superIndex:superIndex
                                                 locationArray:locationArray];
        [deArray addObject:levelModel];
    }
    return [NSArray arrayWithArray:deArray];
}

- (void)modelClicked:(MultilevelMenuModel *)model {
    if (!model.MMIsOpen) {
        [self addSubModelToShowByModel:model];
    } else {
        [self removeSubModelFromShowByModel:model closeIt:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UIShouldBeUpdate" object:nil];
}

- (void)addSubModelToShowByModel:(MultilevelMenuModel *)superModel  {
    NSInteger sup  erIndex= [self.showData indexOfObject:superModel];
    for (MultilevelMenuModel *subModel in [[superModel.MMSubArray reverseObjectEnumerator] allObjects]) {
        if (![self.showData containsObject:subModel]) {
            [self.showData insertObject:subModel atIndex:superIndex + 1];
        }
        if (subModel.MMIsOpen == YES && subModel.MMSubArray.count > 0 ) {
            [self addSubModelToShowByModel:subModel];
        }
    }
    superModel.MMIsOpen = YES;
}

- (void)removeSubModelFromShowByModel:(MultilevelMenuModel *)superModel
                            closeIt:(BOOL)close{
    if (superModel.MMSubArray.count == 0) {
        return;
    }
    
    for (MultilevelMenuModel *subModel in superModel.MMSubArray) {
        [self removeSubModelFromShowByModel:subModel closeIt:!subModel.MMIsOpen];
        [self.showData removeObject:subModel];
    }
    
    superModel.MMIsOpen = !close;
}


/**
 Deal with selective state

 @param model current model
 */
- (void)changModelSelecteState:(MultilevelMenuModel *)model {
    switch (model.MMSelectState) {
        case selectAll:
            [self setModelToBeStateNone:model];
            break;
        case  selectHalf:
            [self setModelToBeStateHalf:model];
        default:
            [self setModelToBeStateAll:model];
            break;
    }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UIShouldBeUpdate" object:nil];
}

/**
 Make current level or sublevel , parent level unselected
 
 @param model  current selected Model
 */
- (void)setModelToBeStateNone:(MultilevelMenuModel *)model {
    
    // make current model unselected
    model.MMSelectState = selectNone;
    // make sublevel unselected
    if (model.MMSubArray.count > 0) {
        for (MultilevelMenuModel *subModel in model.MMSubArray) {
            if (subModel.MMSelectState != selectNone) {
                [self setModelToBeStateNone:subModel];
            }
        }
    }
    //make super model unselected
    MultilevelMenuModel *supModel = [self findSuperModelBySubModel:model];
    if (supModel == nil) {
        return;
    }
    
    if ([self checkSubModeHasStateAll:supModel]) {
        [self setModelToBeStateHalf:supModel];
    } else if ([self checkSubModelHasSelectedHalf:supModel])  {
        [self setModelToBeStateHalf:supModel];
    } else {
         [self setModelToBeStateNone:supModel];
    }
}


/**
 Make current level or sublevel , parent level selected

 @param model  current selected Model
 */
- (void)setModelToBeStateAll:(MultilevelMenuModel *)model {
    
    // make current model selected
    model.MMSelectState = selectAll;
    
    // make  sublevel selected
    if (model.MMSubArray.count > 0) {
        for (MultilevelMenuModel *subModel in model.MMSubArray) {
            if (subModel.MMSelectState != selectAll) {
                
                [self setModelToBeStateAll:subModel];
            }
        }
    }
    //make super model selected
    MultilevelMenuModel *supModel = [self findSuperModelBySubModel:model];
    if (supModel == nil) {
        return;
    }
    if ([self checkSubModelsBeStateAll:supModel]) {
        [self setModelToBeStateAll:supModel];
    } else {
        [self setModelToBeStateHalf:supModel];
    }
}

/**
 Make current level or sublevel , parent level half-selected

 @param model current selected Model
 */
- (void)setModelToBeStateHalf:(MultilevelMenuModel *)model {
    // make current model selected
    model.MMSelectState = selectHalf;
    
    //make super model half-selected
    MultilevelMenuModel *supModel = [self findSuperModelBySubModel:model];
    if (supModel == nil) {
        return;
    }
    [self setModelToBeStateHalf:supModel];
}

- (BOOL)checkSubModelsBeStateAll:(MultilevelMenuModel *)supModel {
    BOOL result = YES;
    for (MultilevelMenuModel *subModel in supModel.MMSubArray) {
        if (subModel.MMSelectState != selectAll) {
            return  NO;
        }
    }
    return result;
}

- (BOOL)checkSubModelHasSelectedHalf:(MultilevelMenuModel *)supModel {
    BOOL result = NO;
    for (MultilevelMenuModel *subModel in supModel.MMSubArray) {
        
        if (subModel.MMSelectState == selectHalf) {
            
            return  YES;
        }
    }
    return result;
}
- (BOOL)checkSubModeHasStateAll:(MultilevelMenuModel *)supModel {
    BOOL result = NO;
    for (MultilevelMenuModel *subModel in supModel.MMSubArray) {
        if (subModel.MMSelectState == selectAll) {
            return  YES;
        }
    }
    return result;
}

- (MultilevelMenuModel *)findSuperModelBySubModel:(MultilevelMenuModel *)subModel {
    NSArray *location = subModel.locationArray;
    if (location.count == 0) {
        return nil;
    }
    MultilevelMenuModel *resultModel;
    NSArray *dataSource = self.modelArray;
    int i = 1;
    while (i < location.count) {
        
        int index = [location[i] intValue];
        resultModel = dataSource[index];
        dataSource = resultModel.MMSubArray;
        i++;
    }
    return resultModel;
}



@end
