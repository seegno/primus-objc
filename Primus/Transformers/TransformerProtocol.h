//
//  TransformerProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 1/12/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusProtocol.h"

@protocol TransformerProtocol <NSObject>

- (id)initWithPrimus:(id<PrimusProtocol>)primus;

- (void)bindEvents;

@end
