//
//  ParserProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

typedef void (^PrimusParserCallback)(NSError *error, id data);

@protocol ParserProtocol <NSObject>

/**
 *  Encode a raw object and execute the callback block with the result.
 *
 *  @param raw      The raw object to encode.
 *  @param callback The block that will be called when the object has been encoded.
 */
- (void)encode:(id)raw callback:(PrimusParserCallback)callback;

/**
 *  Decode a raw object and execute the callback block with the result.
 *
 *  @param raw      The raw object to decode.
 *  @param callback The block that will be called when the object has been decoded.
 */
- (void)decode:(id)raw callback:(PrimusParserCallback)callback;

@end
