//
//  Transformer.m
//  Primus
//
//  Created by Nuno Sousa on 17/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "Transformer.h"

@implementation Transformer

- (id)initWithPrimus:(id<PrimusProtocol>)primus
{
    self = [super init];

    if (self) {
        _primus = primus;
    }

    return self;
}

@end
