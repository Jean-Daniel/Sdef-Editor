/*
 *  OSASdefImporter.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "OSASdefImporter.h"

#import <ShadowKit/SKExtensions.h>
#import <ShadowKit/SKFSFunctions.h>

#include <Carbon/Carbon.h>

#import "SdefDocument.h"
#import "SdefDictionary.h"

@implementation OSASdefImporter

+ (id)allocWithZone:(NSZone *)aZone {
  // Don't check weak ref in Tiger
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_4
  if (!OSACopyScriptingDefinition) {
    return nil;
  }
#endif
  return [super allocWithZone:aZone];
}

- (id)initWithFile:(NSString *)file {
  if (self = [super init]) {
    sd_path = [file copy];
  }
  return self;
}

- (void)dealloc {
  [sd_dico release];
  [sd_path release];
  [super dealloc];
}

- (SdefDictionary *)sdefDictionary {
  [super sdefDictionary];
  return sd_dico;
}

#pragma mark -
#pragma mark Parsing
- (BOOL)import {
  if (sd_dico) {
    [sd_dico release];
    sd_dico = nil;
  }
  
  FSRef file;
  if (sd_path && [sd_path getFSRef:&file]) {
    CFDataRef sdef = nil;
    if (noErr == OSACopyScriptingDefinition(&file, 0, &sdef) && sdef) {
      NSString *error = nil;
      sd_dico = [SdefLoadDictionaryData((id)sdef, nil, self, &error) retain];
      CFRelease(sdef);
      if (!sd_dico && error)
        NSRunAlertPanel(@"Sdef parser failed with error:",
                        @"%@", @"OK", nil, nil, error);
    }
  }
  [suites addObjectsFromArray:[sd_dico children]];
  return sd_dico != nil;
}

#pragma mark Post Processor
- (BOOL)resolveObjectType:(SdefObject *)object {
  NSString *type = [object valueForKey:@"type"];
  if (type) {
    SEL cmd = @selector(isEqualToString:);
    EqualIMP isEqual = (EqualIMP)[type methodForSelector:cmd];
    NSAssert(isEqual, @"Missing isEqualToStringMethod");
    
    if (isEqual(type, cmd, @"Unicode text")) {
      [object setValue:@"text" forKey:@"type"];
    } else if (isEqual(type, cmd, @"reference")) {
      [object setValue:@"specifier" forKey:@"type"];
    } else if (isEqual(type, cmd, @"location reference")) {
      [object setValue:@"location specifier" forKey:@"type"];
    } else if (isEqual(type, cmd, @"anything")) {
      [object setValue:@"any" forKey:@"type"];
    } else if (isEqual(type, cmd, @"bounding rectangle")) {
      [object setValue:@"rectangle" forKey:@"type"];
    } else if (isEqual(type, cmd, @"type class")) {
      [object setValue:@"type" forKey:@"type"];
    } else if (isEqual(type, cmd, @"file reference")) {
      [object setValue:@"file" forKey:@"type"];
    }
  }
  return YES;
}

@end
