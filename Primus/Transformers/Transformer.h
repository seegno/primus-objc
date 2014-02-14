//
//  Transformer.h
//  Primus
//
//  Created by Nuno Sousa on 17/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "TransformerProtocol.h"

@interface Transformer : NSObject<TransformerProtocol>
{
    NSObject<PrimusProtocol> *_primus;
}
@end
