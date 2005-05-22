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

@class SdefDocumentationParser;
@class SdefObject, SdefDictionary;
@interface SdefXMLParser : NSObject {
  id sd_node;
  id sd_delegate;
  NSString *sd_error;
  CFXMLParserRef sd_parser;
  NSMutableArray *sd_comments;
  SdefDictionary *sd_dictionary;
}
- (int)parserVersion;

- (NSString *)error;
- (SdefDictionary *)document;
- (BOOL)parseData:(NSData *)document;

- (void)parser:(CFXMLParserRef)parser didStartClass:(NSDictionary *)attributes;
- (void)parser:(CFXMLParserRef)parser didStartEvent:(NSDictionary *)attributes;
- (void)parser:(CFXMLParserRef)parser didStartElement:(NSDictionary *)attributes;
- (void)parser:(CFXMLParserRef)parser didStartCommand:(NSDictionary *)attributes;
- (void)parser:(CFXMLParserRef)parser didStartProperty:(NSDictionary *)attributes;
- (void)parser:(CFXMLParserRef)parser didStartRespondsTo:(NSDictionary *)attributes;
- (void)parser:(CFXMLParserRef)parser didStartEnumeration:(NSDictionary *)attributes;

- (void)parser:(CFXMLParserRef)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes;
- (void)parser:(CFXMLParserRef)parser didEndElement:(NSString *)element;

- (void)parserDidEndDocumentation:(SdefDocumentationParser *)parser;
@end

@class SdefDocumentation;
@interface SdefDocumentationParser : NSObject {
  unsigned short sd_html;
  SdefXMLParser *sd_parent;
  SdefDocumentation *sd_doc;
  NSMutableString *sd_content;
}

- (id)initWithDocumentation:(SdefDocumentation *)doc parent:(id)theParent;

@end

