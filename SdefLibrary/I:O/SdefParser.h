//
//  SdefParser.h
//  SDef Editor
//
//  Created by Grayfox on 06/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefDictionary;
@interface SdefParser : NSObject {
@private
  SdefDictionary *sd_document;
}

- (SdefDictionary *)document;
- (BOOL)parseData:(NSData *)document;

@end
