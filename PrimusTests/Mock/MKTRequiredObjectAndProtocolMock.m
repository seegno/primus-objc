//
//  MKTRequiredObjectAndProtocolMock.m
//  Primus
//
//  Created by Nuno Sousa on 28/02/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "MKTRequiredObjectAndProtocolMock.h"

#import <objc/runtime.h>

@implementation MKTRequiredObjectAndProtocolMock

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    struct objc_method_description methodDescription = protocol_getMethodDescription(_mockedProtocol, aSelector, NO, YES);

    if (methodDescription.name) {
        return nil;
    }

	return [super methodSignatureForSelector:aSelector];
}


@end
