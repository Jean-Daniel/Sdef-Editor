//
//  SdefXMLParser.h
//  Sdef Editor
//
//  Created by Grayfox on 03/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
  kSdefParserUnknownVersion		= 0,
  kSdefParserPantherVersion		= 1 << 0,
  kSdefParserTigerVersion		= 1 << 1,
  kSdefParserBothVersion		= kSdefParserPantherVersion | kSdefParserTigerVersion,
};

extern NSString *SdefXMLAccessStringFromFlag(unsigned flag);
extern unsigned SdefXMLAccessFlagFromString(NSString *str);

extern unsigned SdefXMLAccessorFlagFromString(NSString *str);
extern NSArray *SdefXMLAccessorStringsFromFlag(unsigned flag);

@class SdefObject, SdefDictionary;
@interface SdefXMLParser : NSObject {
  id sd_node;
  id sd_parent;
  SdefDictionary *sd_dictionary;
}

- (SdefDictionary *)document;
- (BOOL)parseData:(NSData *)document;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)element;

@end
