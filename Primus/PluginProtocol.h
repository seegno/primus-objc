//
//  PluginProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 19/02/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusProtocol.h"

@protocol PluginProtocol <NSObject>

/**
 *  Initializes the plugin with a Primus instance. Plugins typically listen for
 *  events using this instance and act upon them.
 *
 *  @param primus An initialized Primus instance.
 *
 *  @return A Plugin instance.
 */
- (id)initWithPrimus:(id<PrimusProtocol>)primus;

@end
