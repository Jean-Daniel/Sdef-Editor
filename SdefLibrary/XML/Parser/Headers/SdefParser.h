/*
 *  SdefParser.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */


#import "SdefBase.h"

@class SdefXMLValidator, SdefDocumentationParser;
@interface SdefParser : NSObject {
  id sd_delegate;

  SdefVersion sd_version;
  CFXMLParserRef sd_parser;
  NSMutableArray *sd_comments;
  CFMutableDictionaryRef sd_metas;
  
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

- (BOOL)parseSdef:(NSData *)sdefData;

@end

@interface NSObject (SdefParserDelegate)
- (BOOL)sdefParser:(SdefParser *)parser handleValidationError:(NSString *)error isFatal:(BOOL)fatal;
@end

