/*
 *  SdefParser.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */


#import "SdefBase.h"

enum {
  kSdefParserAbort,
  kSdefParserAddNode,
  kSdefParserDeleteNode,
};
typedef NSUInteger SdefParserOperation;

@class SdefXMLValidator, SdefDocumentationParser;
@interface SdefParser : NSObject {
  id sd_delegate;

  NSString *sd_error;
  SdefVersion sd_version;
  CFXMLParserRef sd_parser;
  NSMutableArray *sd_comments;
  /* root element */
  SdefDictionary *sd_dictionary;
  
  SdefXMLValidator *sd_validator;
  /* html documentation parser */
  SdefDocumentationParser *sd_docParser;
}

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (NSInteger)line;
- (NSInteger)location;

- (SdefVersion)sdefVersion;
- (SdefDictionary *)dictionary;

- (BOOL)parseSdef:(NSData *)sdefData error:(NSString **)error;

@end

@interface NSObject (SdefParserDelegate)
- (SdefParserOperation)sdefParser:(SdefParser *)parser shouldAddInvalidObject:(id)anObject inNode:(SdefObject *)node;
@end

