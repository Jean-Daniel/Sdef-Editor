/*
 *  SdefParser.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */


#import "SdefBase.h"

@protocol SdefParserDelegate;
@class SdefXMLValidator, SdefDocumentationParser;
@interface SdefParser : NSObject {
  __unsafe_unretained id<SdefParserDelegate> sd_delegate;
  
  SdefVersion sd_version;
  NSMutableArray *sd_comments;
  NSMutableArray *sd_xincludes;
  NSMutableDictionary *sd_metas;
  
  /* root element */
  NSMutableArray *sd_roots;
  
  SdefXMLValidator *sd_validator;
  /* html documentation parser */
  SdefDocumentationParser *sd_docParser;
}

@property(nonatomic, assign) id<SdefParserDelegate> delegate;

- (NSArray *)objects;
- (SdefVersion)sdefVersion;
- (SdefDictionary *)dictionary;

- (BOOL)parseContentsOfURL:(NSURL *)anURL error:(NSError **)outError;
- (BOOL)parseData:(NSData *)sdefData base:(NSURL *)anURL error:(NSError **)outError;

@end

@protocol SdefParserDelegate
- (BOOL)sdefParser:(SdefParser *)parser shouldIgnoreValidationError:(NSError *)error isFatal:(BOOL)fatal;
@end

