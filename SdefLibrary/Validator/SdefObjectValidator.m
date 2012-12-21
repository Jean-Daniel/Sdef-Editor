/*
 *  SdefObjectValidator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefValidatorBase.h"

#import "SdefLeaf.h"
#import "SdefSuite.h"
#import "SdefObjects.h"
#import "SdefDictionary.h"
#import "SdefClassManager.h"
#import "SdefDocumentation.h"

#import <WonderBox/WBFunctions.h>

WB_INLINE 
NSString *SystemVersionForSdefVersion(SdefVersion vers) {
  switch (vers) {
    case kSdefTigerVersion:
      return @"10.4 (Tiger)";
    case kSdefPantherVersion:
      return @"10.3 (Panther)";
    case kSdefLeopardVersion:
      return @"10.5 (Leopard)";
  }
  return nil;
}

BOOL SdefValidatorIsKeyword(NSString *str) {
  static NSSet *sKeyword = nil;
  if (!sKeyword) {
    sKeyword = [[NSSet alloc] initWithObjects:
      @"after", @"does", @"get", @"my", @"second", @"to",
      @"and", @"eighth", @"given", @"ninth", @"set", @"transaction",
      @"as", @"else", @"global", @"not", @"seventh", @"true",
      @"back", @"end", @"if", @"of", @"sixth", @"try",
      @"before", @"equal", @"ignoring", @"on", @"some", @"until",
      @"beginning", @"equals", @"in", @"or", @"tell", @"where",
      @"behind", @"error", @"into", @"prop", @"tenth", @"while",
      @"but", @"every", @"is", @"property", @"that", @"whose",
      @"by", @"exit", @"it", @"put", @"the", @"with",
      @"considering", @"false", @"its", @"ref", @"then", @"without",
      @"contain", @"fifth", @"last", @"reference", @"third",
      @"contains", @"first", @"local", @"repeat", @"through",
      @"continue", @"fourth", @"me", @"return", @"thru",
      @"copy", @"from", @"middle", @"returning", @"timeout",
      @"div", @"front", @"mod", @"script", @"times", nil];
  }
  return str ? [sKeyword containsObject:str] : NO;
}

NSString *SdefValidatorCodeForName(NSString *name) {
  static NSDictionary *sStdCodes = nil;
  if (!sStdCodes) {
    sStdCodes = [[NSDictionary alloc] initWithObjectsAndKeys:
      @"pnam", @"name",
      @"ID  ", @"id",
      @"pidx", @"index",
      @"pcls", @"class",
      @"pALL", @"properties",
      @"vers", @"version",
      /* classes */
      @"cobj", @"item",
      @"capp", @"application",
      @"colr", @"color",
      @"docu", @"document",
      @"cwin", @"window",
      @"pcnt", @"contents",
      /* types */
      @"****", @"any",
      @"bool", @"boolean",
      @"ldt ", @"date",
      @"file", @"file",
      @"long", @"integer",
      @"insl", @"location specifier",
      @"nmbr", @"number",
      @"QDpt", @"point",
      @"doub", @"real",
      @"reco", @"record",
      @"qdrt", @"rectangle",
      @"obj ", @"specifier",
      @"ctxt", @"text",
      @"type", @"type", nil];
  }
  return name ? [sStdCodes objectForKey:name] : nil;
}

/* Like that, leaf and sdef object have both access to this methods */
@implementation NSObject (SdefValidatorInternal)
- (SdefValidatorItem *)invalidValue:(NSString *)value forAttribute:(NSString *)attr {
  if (value) {
    return [SdefValidatorItem errorItemWithNode:(NSObject<SdefObject> *)self 
                                        message:@"invalid value '%@' for attribute %@.", value, attr];
  } else {
    /* missing attribute */
    return [SdefValidatorItem errorItemWithNode:(NSObject<SdefObject> *)self 
                                        message:@"attribute '%@' required.", attr];
  }
}

- (SdefValidatorItem *)versionRequired:(SdefVersion)vers forAttribute:(NSString *)attr {
  return [SdefValidatorItem errorItemWithNode:(NSObject<SdefObject> *)self 
                                      message:@"attribute '%@' requires Mac OS version %@.", attr, SystemVersionForSdefVersion(vers)];
}

- (SdefValidatorItem *)versionRequired:(SdefVersion)vers forElement:(NSString *)element {
  return [SdefValidatorItem errorItemWithNode:(NSObject<SdefObject> *)self 
                                      message:@"element %@ requires Mac OS version %@.", element, SystemVersionForSdefVersion(vers)];
}
@end

@implementation SdefLeaf (SdefValidator)

/* fill the message array with warnign and errors */
- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  
}

@end

@implementation SdefObject (SdefValidator)

/* fill the message array with warnign and errors */
- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  SdefObject *child;
  NSEnumerator *children = [self childEnumerator];
  while (child = [children nextObject]) {
    [child validate:messages forVersion:vers];
  }
}

@end

@implementation SdefDocumentedObject (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (sd_documentation && [sd_documentation isHtml]) {
    if (vers <kSdefTigerVersion) {
      SdefValidatorItem *error = [SdefValidatorItem errorItemWithNode:(NSObject<SdefObject> *)self 
                                                              message:@"html documentation is not supported in Panther Sdef files."];
      [messages addObject:error];
    }
  }
  [super validate:messages forVersion:vers];
}


@end

@implementation SdefImplementedObject (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (sd_impl)
    [sd_impl validate:messages forVersion:vers];
  [super validate:messages forVersion:vers];
}

@end

BOOL SdefValidatorCheckCode(NSString *code) {
  BOOL invalid = YES;
  switch ([code length]) {
    case 4:
    case 10:
      invalid = (0 == SdefOSTypeFromString(code));
      break;
    case 6: {
      if ([code hasPrefix:@"'"] && [code hasSuffix:@"'"])
        invalid = (0 == WBOSTypeFromString([code substringWithRange:NSMakeRange(1, 4)]));
    }
      break;
  }
  return !invalid;
}

@implementation SdefTerminologyObject (SdefValidator)

- (BOOL)validateCode {
  return NO;
}

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  /* xrefs */
  if ([self hasXrefs] && sd_xrefs && [sd_xrefs count] > 0) {
    if (vers < kSdefLeopardVersion) {
      [messages addObject:[self versionRequired:kSdefLeopardVersion forElement:@"xref"]];
    } else {
      NSUInteger count = [sd_xrefs count];
      while (count-- > 0) {
        [[sd_xrefs objectAtIndex:count] validate:messages forVersion:vers];
      }
    }
  }
  /* synonyms */
  if ([self hasSynonyms] && sd_synonyms && [sd_synonyms count] > 0) {
    /* Note: synonym ignored by cocoa scripting */
    NSUInteger count = [sd_synonyms count];
    while (count-- > 0) {
      [[sd_synonyms objectAtIndex:count] validate:messages forVersion:vers];
    }
  }
  /* id */
  if ([self hasID] && sd_id && vers < kSdefLeopardVersion) {
    [messages addObject:[self versionRequired:kSdefLeopardVersion forAttribute:@"id"]];
  }
  /* code */
  if ([self validateCode]) {
    if (!sd_code) {
      [messages addObject:[self invalidValue:nil forAttribute:@"code"]];
    } else if (!SdefValidatorCheckCode(sd_code)) {
      [messages addObject:[self invalidValue:sd_code forAttribute:@"code"]];
    }
  }
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefTypedObject (SdefValidator)

- (BOOL)validateType {
  return NO;
}

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if ([self validateType]) {
    if (!sd_types || [sd_types count] == 0) {
      [messages addObject:[self invalidValue:nil forAttribute:@"type"]];
    } else {
      NSUInteger count = [sd_types count];
      SdefClassManager *manager = [self classManager];
      while (count-- > 0) {
        SdefType *type = [sd_types objectAtIndex:count];
        [type validate:messages forVersion:vers];
        if ([type name] && ![SdefClassManager isBaseType:[type name]] && ![manager typeWithName:[type name]])
          [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                             message:@"unknown type '%@'", [type name]]];
      }
    }
  }
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefDictionary (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self title] || [[self title] isEqualToString:[[self class] defaultName]])
    [messages addObject:[SdefValidatorItem noteItemWithNode:self
                                                    message:@"title should be your application name"]];    
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefSuite (SdefValidator)

- (BOOL)validateCode { return YES; }

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self name])
    [messages addObject:[self invalidValue:nil forAttribute:@"name"]];
  
  [super validate:messages forVersion:vers];
}

@end
