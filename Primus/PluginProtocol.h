//
//  PluginProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 19/02/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusProtocol.h"

@protocol PluginProtocol <NSObject>

- (id)initWithPrimus:(id<PrimusProtocol>)primus;

@end
