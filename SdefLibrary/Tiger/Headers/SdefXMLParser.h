/*
 *  SdefXMLParser.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

enum {
  kSdefParserUnknownVersion = 0,
  kSdefParserPantherVersion = 1 << 0,
  kSdefParserTigerVersion   = 1 << 1,
  kSdefParserLeopardVersion = 1 << 2,
  kSdefParserAllVersions    = kSdefParserPantherVersion | kSdefParserTigerVersion | kSdefParserLeopardVersion,
};
typedef NSInteger SdefParserVersion;

typedef enum {
  kSdefParserAbort,
  kSdefParserAddNode,
  kSdefParserDeleteNode,
} SdefParserOperation;

SK_PRIVATE
NSString *SdefXMLAccessStringFromFlag(NSUInteger flag);
SK_PRIVATE
NSUInteger SdefXMLAccessFlagFromString(NSString *str);

SK_PRIVATE
NSUInteger SdefXMLAccessorFlagFromString(NSString *str);
SK_PRIVATE
NSArray *SdefXMLAccessorStringsFromFlag(NSUInteger flag);

@class SdefDocumentationParser;
@class SdefObject, SdefDictionary;
@interface SdefXMLParser : NSObject {
  id sd_node;
  id sd_delegate;
  NSString *sd_error;
  CFXMLParserRef sd_parser;
  NSMutableArray *sd_comments;
  NSStringEncoding sd_encoding;
  SdefDictionary *sd_dictionary;
  SdefDocumentationParser *sd_subParser;
}
- (SdefParserVersion)parserVersion;
- (SdefParserVersion)supportedVersions;

- (NSStringEncoding)encoding;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (NSInteger)line;
- (NSString *)error;
- (SdefDictionary *)document;
- (BOOL)parseData:(NSData *)document;

- (SdefParserOperation)shouldAddInvalidObject:(id)anObject inNode:(SdefObject *)aNode;

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

@interface NSObject (SdefXMLParserDelegate)
- (SdefParserOperation)sdefParser:(SdefXMLParser *)parser shouldAddInvalidObject:(id)anObject inNode:(SdefObject *)node;
@end

@class SdefDocumentation;
@interface SdefDocumentationParser : NSObject {
  NSInteger sd_html;
  SdefXMLParser *sd_parent;
  SdefDocumentation *sd_doc;
  NSMutableString *sd_content;
}

- (id)initWithDocumentation:(SdefDocumentation *)doc parent:(id)theParent;

- (id)parser:(CFXMLParserRef)parser didStartXMLNode:(CFXMLNodeRef)aNode;
- (void)parser:(CFXMLParserRef)parser didEndXMLNode:(id)aNode;

- (void)parser:(CFXMLParserRef)parser foundCDATA:(NSString *)CDATABlock;

@end

