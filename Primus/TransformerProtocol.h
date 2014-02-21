//
//  TransformerProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 1/12/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusProtocol.h"

@protocol TransformerProtocol <NSObject>

/**
 *  Initializes the transformer with a Primus instance.
 *
 *  @param primus An initialized Primus instance.
 *
 *  @return A Plugin instance.
 */
- (id)initWithPrimus:(id<PrimusProtocol>)primus;

@end
