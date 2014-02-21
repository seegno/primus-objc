//
//  PrimusTransformers.h
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

@interface PrimusTransformers : NSObject

@property (nonatomic) NSMutableArray *incoming;
@property (nonatomic) NSMutableArray *outgoing;

/**
 *  Maps the server-side Primus transformer to an objective-c client class.
 *
 *  @param transformer The transformer name as defined in the Primus javascript implementation.
 *
 *  @return The name of the objective-c client transformer.
 */
- (NSString *)mapTransformer:(NSString *)transformer;

@end
