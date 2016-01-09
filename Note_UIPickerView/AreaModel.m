//
//  AreaModel.m
//  parrot
//
//  Created by THN-Huangfei on 15/12/22.
//  Copyright © 2015年 taihuoniao. All rights reserved.
//

#import "AreaModel.h"

@implementation AreaModel

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(![dictionary[@"_id"] isKindOfClass:[NSNull class]]){
        self.idField = [dictionary[@"_id"] integerValue];
    }
    if(![dictionary[@"city"] isKindOfClass:[NSNull class]]){
        self.name = dictionary[@"city"];
    }
    
    return self;
}

@end
