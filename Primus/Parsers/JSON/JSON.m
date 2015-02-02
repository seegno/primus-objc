//
//  JSON.m
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "JSON.h"

@implementation JSON

- (void)encode:(id)raw callback:(PrimusParserCallback)callback
{
    NSError *error = nil;

    @try {
        if ([raw isKindOfClass:[NSString class]]) {
            raw = [NSString stringWithFormat:@"\"%@\"", raw];
        } else {
            raw = [NSJSONSerialization dataWithJSONObject:raw options:0 error:&error];
            raw = [[NSString alloc] initWithData:raw encoding:NSUTF8StringEncoding];
        }
    }
    @catch (NSException *exception) {
        raw = nil;

        error = [NSError errorWithDomain:exception.name code:0 userInfo:@{
            NSLocalizedFailureReasonErrorKey: exception.reason
        }];
    }

    return callback(error, raw);
}

- (void)decode:(id)raw callback:(PrimusParserCallback)callback
{
    NSError *error = nil;

    @try {
        if ([raw isKindOfClass:NSString.class]) {
            raw = [raw dataUsingEncoding:NSUTF8StringEncoding];
        }

        if ([raw isKindOfClass:NSData.class]) {
            raw = [NSJSONSerialization JSONObjectWithData:raw options:NSJSONReadingAllowFragments error:&error];
        }
    }
    @catch (NSException *exception) {
        raw = nil;

        error = [NSError errorWithDomain:exception.name code:0 userInfo:@{
            NSLocalizedFailureReasonErrorKey: exception.reason
        }];
    }

    return callback(error, raw);
}

@end
