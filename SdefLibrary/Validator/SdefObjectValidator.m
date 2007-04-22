/*
 *  SdefObjectValidator.m
 *  Sdef Editor
 *
 *  Created by Grayfox on 22/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import "SdefValidatorBase.h"

#import "SdefLeaf.h"
#import "SdefObjects.h"
#import "SdefDictionary.h"
#import "SdefClassManager.h"
#import "SdefDocumentation.h"

#import <ShadowKit/SKFunctions.h>

SK_INLINE 
NSString *SystemVersionForSdefVersion(SdefVersion vers) {
  switch (vers) {
    case kSdefTigerVersion:
      return @"Tiger";
    case kSdefPantherVersion:
      return @"Panther";
    case kSdefLeopardVersion:
      return @"Leopard";
  }
  return nil;
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
                                      message:@"attribute %@ require %@ and above.", attr, SystemVersionForSdefVersion(vers)];
}

- (SdefValidatorItem *)versionRequired:(SdefVersion)vers forElement:(NSString *)element {
  return [SdefValidatorItem errorItemWithNode:(NSObject<SdefObject> *)self 
                                      message:@"element %@ require %@ and above.", element, SystemVersionForSdefVersion(vers)];
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
  if (sd_documentation && [sd_documentation isHtml] && vers <kSdefTigerVersion) {
    SdefValidatorItem *error = [SdefValidatorItem errorItemWithNode:(NSObject<SdefObject> *)self 
                                                            message:@"html documentation is not supported in Panther Sdef files."];
    [messages addObject:error];
  }
  [super validate:messages forVersion:vers];
}


@end

@implementation SdefImplementedObject (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  [super validate:messages forVersion:vers];
}

@end

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
    } else {
      BOOL invalid = YES;
      switch ([sd_code length]) {
        case 4:
        case 10:
          invalid = (0 == OSTypeFromSdefString(sd_code));
          break;
        case 6: {
          if ([sd_code hasPrefix:@"'"] && [sd_code hasSuffix:@"'"])
            invalid = (0 == SKOSTypeFromString([sd_code substringWithRange:NSMakeRange(1, 4)]));
        }
          break;
      }
      if (invalid) {
        [messages addObject:[self invalidValue:sd_code forAttribute:@"code"]];
      }
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
        if (![SdefClassManager isBaseType:[type name]] && ![manager typeWithName:[type name]])
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
