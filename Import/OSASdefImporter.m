/*
 *  OSASdefImporter.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "OSASdefImporter.h"

#import <WonderBox/WBFSFunctions.h>

#include <Carbon/Carbon.h>

#import "SdefParser.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

@interface OSASdefImporter () <SdefParserDelegate>

@end

@implementation OSASdefImporter

- (id)initWithURL:(NSURL *)url {
  if (self = [super init]) {
    sd_url = url;
  }
  return self;
}

- (SdefDictionary *)sdefDictionary {
  [super sdefDictionary];
  return sd_dico;
}

#pragma mark -
#pragma mark Parsing
- (BOOL)import {
  sd_dico = nil;

  if (sd_url) {
    CFDataRef sdef = nil;
    if (noErr == OSACopyScriptingDefinitionFromURL(SPXNSToCFURL(sd_url), 0, &sdef) && sdef) {
      sd_dico = SdefLoadDictionaryData(SPXCFToNSData(sdef), nil, NULL, self, NULL);
			if (![sd_dico title] || [[sd_dico title] isEqualToString:[[sd_dico class] defaultName]]) {
				NSString *name = NULL;
				if ([sd_url getResourceValue:&name forKey:NSURLLocalizedNameKey error:NULL]) {
					[sd_dico setTitle:name];
				}
			}
      CFRelease(sdef);
    }
  }
  [suites addObjectsFromArray:[sd_dico children]];
  return sd_dico != nil;
}

- (BOOL)sdefParser:(SdefParser *)parser shouldIgnoreValidationError:(NSError *)error isFatal:(BOOL)fatal {
  if (fatal) {
    NSRunAlertPanel(@"An unrecoverable error occured while parsing file.",
                    @"%@",
                    @"OK", nil, nil, [error localizedDescription]);
    return NO;
  } else {
    switch (NSRunAlertPanel(@"An sdef validation error occured while parsing file.",
                            @"%@",
                            @"Ignore", @"Abort", nil, [error localizedDescription])) {
      case NSAlertAlternateReturn:
        return NO;
    }
  }
  /* ignore error */
  return YES;
}

#pragma mark Post Processor
- (BOOL)resolveObjectType:(SdefObject *)object {
  NSString *type = [object valueForKey:@"type"];
  if (type) {
    SEL cmd = @selector(isEqualToString:);
    BOOL (*isEqual)(id, SEL, id) = (BOOL(*)(id, SEL, id))[type methodForSelector:cmd];
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
