//
//  AreaModel.h
//  parrot
//
//  Created by THN-Huangfei on 15/12/22.
//  Copyright © 2015年 taihuoniao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AreaModel : NSObject

@property (nonatomic, assign) NSInteger idField;
@property (nonatomic, strong) NSString * name;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
