# MultilevelMenuWithCheckbox
多级菜单功能， 可以支持多级菜单扩展，可以配置复选框。

关键词：
`递归` `多级菜单` `复选` 
###目标
1.显示多级菜单，默认显示一级.   
2.可以通过点击有子级的行展开菜单  
3.通过复选框，改变选中状态。状态有全选、半选、未选中  
4.可以扩展获取当前所选的条目集合

![img](https://github.com/YuTongHon/MultilevelMenuWithCheckbox/blob/master/menu.gif)

####数据处理
1.首先根Datasource进行数据处理   
2.生成一个handler:MultilevelDataHandler  
将数据处理逻辑在handle处理，将数据处理隔离  

```
MultilevelDataHandler *dataHandler = [MultilevelDataHandler sharedHandler];
[dataHandler setLevelKeys:@[@"second_category", @"knowledge"]];  //由于源数据中每层数据可能采用不同的key，所有我把每层的key依次添加到数组里面，以便数据转化
[dataHandler setReDataSource:dataSource]; // 将源数据交给handle处理
```

3.建立一个数据模型，需要用一些属性记录层级关系。最后我用了一个字典来记录原始的数据信息。

```
//
//  MultilevelMenuModel.h
//  MultilevelMenuWithCheckbox
//
//  Created by hyt on 2017/10/31.
//  Copyright © 2017年 hyt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, MMSelectState){
    selectNone,
    selectHalf,
    selectAll
};

@interface MultilevelMenuModel : NSObject

@property (nonatomic, assign) NSInteger MMLevel;
@property (nonatomic, assign) NSInteger MMIndex;
//@property (nonatomic, assign) NSInteger MMSuperIndex;
@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) NSArray *MMSubArray;
@property (nonatomic, assign) MMSelectState MMSelectState;
@property (nonatomic, assign) BOOL MMIsOpen;

@property (nonatomic, strong) NSDictionary *dataDict; // original data

@end

```

这里是Demo的数据Json


```
json数据：
[{
		"id": "",
		"name": "",
		"type": "",
		"second_category": [{
			"id": "",
			"name": "",
			"type": "",
			"knowledge": [{
				"id": "",
				"name": "",
				"type": ""
			}]
		}]
	}]
```

4.将jsonDictionary转化成数据模型的时候，把层级关系也一并赋值。  
由于数据层级数量的不确定性，这里用递归的方式把每层的数据结构都放到其父类的subArray当中。

```

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

- (void)setModelSubArray:(MultilevelMenuModel *)model {
    NSString *key = [self getSubKeyByModel:model];
    NSArray *subDictArray = model.dataDict[key];
    model.MMSubArray = [self getModelArrayFromDictArray:subDictArray
                                             modelLevel:model.MMLevel + 1
                                             superIndex:model.MMIndex
                                          locationArray:model.locationArray];
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
```

5.建一个新的数组用来存储要在tableView上展示的数据模型，按照父类子类，父类子类的顺序排列。我这里默认是把第一级全部关闭展示的

6.实现菜单展开关闭功能
>根据点击的model的isOpen属性来判断是否展开。  
>展开时是把subArray中的子级添加到showData当中去，需注意判断子级当前的状态是否是已展开的，如果是的话需要递归调用展开方法。  
>关闭时是把subArray中的子级从showData中删除，也用递归的方法把子类的子类也一并删除。  
>删除子级的时候不影响子级的展开状态。

```
- (void)addSubModelToShowByModel:(MultilevelMenuModel *)superModel  {
    NSInteger superIndex  = [self.showData indexOfObject:superModel]; //
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

```

7.实现复选框功能
>用三个方法分别实现复修改选框的三种状态  
>每个方法中，都需要考虑当前model的状态改变对其父级与子级的影响  
>用model的subArray找到其子级，用locationArray记录的坐标找到其父类  
>父级和子级的状态改变也会影响到他们的父级和子级，所有用递归的方式修改状态

```
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
    } else if ([self checkSubModelHasSelected:supModel])  {
        [self setModelToBeStateHalf:supModel];
    } else {
          supModel.MMSelectState = selectNone;
    }
}

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
```

根据locationArray里记录的每一层父级的序号，找到当前model的父级

```
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

```

#### 总结
由于层级数量的不确定性，所以多次使用到了递归的方式。要注意递归的结束条件，必须陷入死循环当中。



