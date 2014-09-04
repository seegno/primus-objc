//
//  PrimusError.h
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#define kPrimusErrorDomain @"com.seegno.primus"

typedef NS_ENUM(NSInteger, PrimusError) {
    kPrimusErrorUnableToRetry = 1000,
    kPrimusErrorConnectionTimeout = 1001
};