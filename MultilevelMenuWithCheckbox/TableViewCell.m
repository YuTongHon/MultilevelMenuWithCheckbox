//
//  TableViewCell.m
//  MultilevelMenuWithCheckbox
//
//  Created by hyt on 2017/11/2.
//  Copyright © 2017年 hyt. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell ()

@property (nonatomic, strong) MultilevelMenuModel *model;
@property (nonatomic, strong) UIButton *button;

@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateByModel:(MultilevelMenuModel *)currentModel {
    self.model = currentModel;
    [self setBaseInfoByDict];
    [self setOpenOrClose];
    [self setSelectState];
}

/**
 Set value with datasource
 */
- (void)setBaseInfoByDict {
    // you can use custom cell instead of UITableViewCell
    NSDictionary *dataDict = self.model.dataDict;
    NSString *blank = @"";
    NSInteger count = 4 * self.model.MMLevel;
    for (int i = 0; i <= count; i++) {
        blank = [blank stringByAppendingString:@" "];
    }
    self.textLabel.text = [NSString stringWithFormat:@"%@Level%ld-%ld-%@",blank,self.model.MMLevel,self.model.MMIndex,dataDict[@"name"]];
}


/**
 Set states by Image
 */
- (void)setOpenOrClose {
    if (self.model.MMSubArray.count == 0) {
        self.imageView.image = [UIImage imageNamed:@"PlanMiddle_only"];
    } else if (self.model.MMIsOpen) {
         self.imageView.image = [UIImage imageNamed:@"PlanMiddle_open"];
    } else {
         self.imageView.image = [UIImage imageNamed:@"PlanMiddle_n"];
    }
}

/**
 Set selection state by Image
 */
- (void)setSelectState {
    
    NSString *imageName = @"";
    switch (self.model.MMSelectState) {
        case selectAll:
            imageName = @"planSelect";
            break;
        case  selectHalf:
            imageName = @"planSomeSelect";
            break;
        default:
            imageName = @"planNormal";
            break;
    }
    [self.button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 10, 60, 30);
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
    }
    return _button;
}

- (void)buttonAction {
    [DATAHANDLER changModelSelecteState:self.model];
    [self setSelectState];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
