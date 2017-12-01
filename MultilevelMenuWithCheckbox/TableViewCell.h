//
//  TableViewCell.h
//  MultilevelMenuWithCheckbox
//
//  Created by hyt on 2017/11/2.
//  Copyright © 2017年 hyt. All rights reserved.
//

#define  DATAHANDLER [MultilevelDataHandler sharedHandler]

#import <UIKit/UIKit.h>
#import "MultilevelMenuModel.h"
#import "MultilevelDataHandler.h"

@interface TableViewCell : UITableViewCell

/**
 refresh UI by current model

 @param currentModel currentModel
 */
- (void)updateByModel:(MultilevelMenuModel *)currentModel;


@end
