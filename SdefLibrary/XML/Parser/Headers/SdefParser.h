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
  
  void *sd_parser;
  SdefVersion sd_version;
  NSMutableArray *sd_comments;
  NSMutableArray *sd_xincludes;
  CFMutableDictionaryRef sd_metas;
  
  /* root element */
  NSMutableArray *sd_roots;
  
  SdefXMLValidator *sd_validator;
  /* html documentation parser */
  SdefDocumentationParser *sd_docParser;
}

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (NSInteger)line;
- (NSInteger)location;

- (NSArray *)objects;
- (SdefVersion)sdefVersion;
- (SdefDictionary *)dictionary;

- (BOOL)parseContentsOfURL:(NSURL *)anURL error:(NSError **)outError;
- (BOOL)parseData:(NSData *)sdefData base:(NSURL *)anURL error:(NSError **)outError;

@end

@interface NSObject (SdefParserDelegate)
- (BOOL)sdefParser:(SdefParser *)parser shouldIgnoreValidationError:(NSError *)error isFatal:(BOOL)fatal;
@end

