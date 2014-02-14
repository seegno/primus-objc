//
//  PrimusTransformersTest.m
//  Primus
//
//  Created by Nuno Sousa on 11/02/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusTransformers.h"

SpecBegin(PrimusTransformers)

describe(@"PrimusTransformers", ^{
    it(@"initializes incoming and outgoing transformers", ^{
        PrimusTransformers *transformers = [[PrimusTransformers alloc] init];

        expect(transformers.incoming).to.equal([NSArray array]);
        expect(transformers.outgoing).to.equal([NSArray array]);
    });
});

SpecEnd