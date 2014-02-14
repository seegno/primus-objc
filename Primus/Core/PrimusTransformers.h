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

- (NSString *)mapTransformer:(NSString *)transformer;

@end
