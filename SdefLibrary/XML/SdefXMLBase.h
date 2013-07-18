/*
 *  SdefXMLObject.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefType.h"
#import "SdefXRef.h"
#import "SdefClass.h"
#import "SdefSynonym.h"

#import <WonderBox/NSString+WonderBox.h>

@class SdefXMLNode;

@protocol SdefXMLObject <SdefObject>

#pragma mark Parser
- (void)addXMLChild:(id<SdefObject>)node;
- (void)addXMLComment:(NSString *)comment;

- (void)setXMLMetas:(NSDictionary *)metas;
- (void)setXMLAttributes:(NSDictionary *)attrs;

#pragma mark Generator
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;

@end

@interface SdefObject (SdefXMLObject) <SdefXMLObject>
#pragma mark Parser
- (void)addXMLChild:(id<SdefObject>)node;
- (void)addXMLComment:(NSString *)comment;

- (void)setXMLMetas:(NSDictionary *)metas;
- (void)setXMLAttributes:(NSDictionary *)attrs;

#pragma mark Generator
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;

@end

@interface SdefLeaf (SdefXMLObject) <SdefXMLObject>
#pragma mark Parsing
- (void)addXMLComment:(NSString *)comment;

- (void)setXMLMetas:(NSDictionary *)metas;
- (void)setXMLAttributes:(NSDictionary *)attrs;

#pragma mark XML Generation
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;
@end

#pragma mark -
@interface SdefElement (SdefXMLManager)
- (void)addXMLAccessor:(NSString *)style;
@end

static inline
NSString *SdefXMLAccessStringFromFlag(NSUInteger flag) {
  id str = nil;
  if (flag == (kSdefAccessRead | kSdefAccessWrite)) str = @"rw";
  else if (flag == kSdefAccessRead) str = @"r";
  else if (flag == kSdefAccessWrite) str = @"w";
  return str;
}

static inline
uint32_t SdefXMLAccessFlagFromString(NSString *str) {
  uint32_t flag = 0;
  if (str && [str rangeOfString:@"r"].location != NSNotFound) {
    flag |= kSdefAccessRead;
  }
  if (str && [str rangeOfString:@"w"].location != NSNotFound) {
    flag |= kSdefAccessWrite;
  }
  return flag;
}

