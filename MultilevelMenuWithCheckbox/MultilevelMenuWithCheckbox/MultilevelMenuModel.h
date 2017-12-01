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
