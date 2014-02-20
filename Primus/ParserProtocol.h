//
//  ParserProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

typedef void (^PrimusParserCallback)(NSError *error, id data);

@protocol ParserProtocol <NSObject>

- (void)encode:(id)raw callback:(PrimusParserCallback)callback;
- (void)decode:(id)raw callback:(PrimusParserCallback)callback;

@end
