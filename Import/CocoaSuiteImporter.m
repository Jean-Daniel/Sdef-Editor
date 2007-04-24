/*
 *  CocoaSuiteImporter.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "CocoaSuiteImporter.h"
#import "SdefEditor.h"


#import "CocoaObject.h"

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefTypedef.h"
#import "SdefDocument.h"
#import "SdefContents.h"
#import "SdefArguments.h"
#import "SdefDictionary.h"
#import "SdefImplementation.h"

#import "SdefClassManager.h"


#pragma mark Statics Methods Declaration
static 
NSString *_CocoaScriptingDecomposeName(NSString *type, NSString **suite);
static 
NSString *_CocoaScriptingDecomposeType(NSString *type, NSString **suite);

#pragma mark -
@implementation CocoaSuiteImporter

static 
NSDictionary *_CocoaScriptingFindTerminology(NSString *base, NSString *name) {
  NSString *file = [[base stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"scriptTerminology"];
  NSDictionary *dterm = nil;
  
  if (file && [[NSFileManager defaultManager] fileExistsAtPath:file]) {
    dterm = [[NSDictionary alloc] initWithContentsOfFile:file];
  }
  
  if (!dterm) {
    BOOL search = YES;
    do {
      NSOpenPanel *openPanel = [NSOpenPanel openPanel];
      [openPanel setMessage:[NSString stringWithFormat:@"Where is the Suite Terminology \"%@\"?", name]];
      [openPanel setCanChooseFiles:YES];
      [openPanel setCanCreateDirectories:NO];
      [openPanel setCanChooseDirectories:NO];
      [openPanel setAllowsMultipleSelection:NO];
      [openPanel setTreatsFilePackagesAsDirectories:YES];
      
      switch([openPanel runModalForTypes:[NSArray arrayWithObjects:@"scriptTerminology", nil]]) {
        case NSOKButton:
          file = ([[openPanel filenames] count]) ? [[openPanel filenames] objectAtIndex:0] : nil;
          break;
        case NSCancelButton:
          search = NO;
          break;
      }
      if (file && search) {
        dterm = [[NSDictionary alloc] initWithContentsOfFile:file];
        if (!dterm) {
          NSRunAlertPanel(@"Invalid or not matching script terminology", @"You must provide a valid terminology: %@", @"OK", nil, nil, name);
        }
      }
    } while (search);
  }
  return [dterm autorelease];
}

- (id)initWithContentsOfFile:(NSString *)file {
  if (self = [super init]) {
    BOOL ok = NO;
    sd_roots = [[NSMutableArray alloc] init];
    [sd_roots addObject:[[file stringByDeletingLastPathComponent] retain]];
    NSDictionary *dsuite = [NSDictionary dictionaryWithContentsOfFile:file];
    if (dsuite) {
      NSString *name = [dsuite objectForKey:@"Name"];
      NSDictionary *terminology = _CocoaScriptingFindTerminology([sd_roots objectAtIndex:0], name);
      if (terminology) {
        ok = YES;
        sd_cache = [[NSMutableSet alloc] init];
        [self addSuite:dsuite terminology:terminology];
      }
    }
    if (!ok) {
      [self release];
      self = nil;
    }
  }
  return self;
}

- (void)dealloc {
  [sd_roots release];
  [sd_cache release];
  
  [sd_suites release];
  [sd_terminologies release];
  [super dealloc];
}

#pragma mark -
- (SdefSuite *)sdefSuite {
  return [[self sdefSuites] objectAtIndex:0];
}

#pragma mark -
#pragma mark Importer
static NSArray *ASKStandardsSuites() {
  static NSArray *asksuites = nil;
  if (!asksuites) {
    asksuites = [[NSArray alloc] initWithObjects:
      @"ASKApplicationSuite",
      @"ASKContainerViewSuite",
      @"ASKControlViewSuite",
      @"ASKDataViewSuite",
      @"ASKDocumentSuite",
      @"ASKDragAndDropSuite",
      @"ASKMenuSuite",
      @"ASKPanelSuite",
      @"ASKPluginSuite",
      @"ASKTextViewSuite",
      nil];
  }
  return asksuites;
}

- (void)addSuite:(NSDictionary *)suite terminology:(NSDictionary *)terminology {
  if (!sd_suites) {
    sd_suites = [[NSMutableArray alloc] init];
    sd_terminologies = [[NSMutableArray alloc] init];
  }
  [sd_suites addObject:suite];
  [sd_terminologies addObject:terminology];
  
  [sd_cache addObject:[suite objectForKey:@"Name"]];
}

- (void)loadSuite:(NSString *)suite {
  DLog(@"Load suite: %@", suite);
  if ([suite isEqualToString:@"NSCoreSuite"] || [suite isEqualToString:@"NSTextSuite"]) {
    sd_std = YES;
    [sd_cache addObject:@"NSCoreSuite"];
    [sd_cache addObject:@"NSTextSuite"];
    return;
  } else if([ASKStandardsSuites() containsObject:suite]) {
    sd_scpt = YES;
    [sd_cache addObjectsFromArray:ASKStandardsSuites()];
    return;
  }
  
  NSString *file = nil;
  NSString *base = nil;
  NSDictionary *dsuite = nil;
  NSUInteger count = [sd_roots count];
  while (count-- > 0) {
    file = [[[sd_roots objectAtIndex:count] stringByAppendingPathComponent:suite] stringByAppendingPathExtension:@"scriptSuite"];
    if (file && [[NSFileManager defaultManager] fileExistsAtPath:file]) {
      dsuite = [NSDictionary dictionaryWithContentsOfFile:file];
      if (!dsuite || ![[dsuite objectForKey:@"Name"] isEqualToString:suite])
        dsuite = nil;
      else
        base = [sd_roots objectAtIndex:count];
    }
  }
  if (!dsuite) {
    file = nil;
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setMessage:[NSString stringWithFormat:@"Where is the Script Suite \"%@\"?", suite]];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setTreatsFilePackagesAsDirectories:YES];
    
    switch([openPanel runModalForTypes:[NSArray arrayWithObjects:@"scriptSuite", nil]]) {
      case NSOKButton:
        file = ([[openPanel filenames] count]) ? [[openPanel filenames] objectAtIndex:0] : nil;
        break;
    }
    if (file) {
      base = [file stringByDeletingLastPathComponent];
      dsuite = [NSDictionary dictionaryWithContentsOfFile:file];
      if (!dsuite || ![[dsuite objectForKey:@"Name"] isEqualToString:suite])
        dsuite = nil;
      else if (![sd_roots containsObject:base])
        [sd_roots addObject:base];
    }
  }
  
  if (dsuite) {
    NSDictionary *terminology = _CocoaScriptingFindTerminology(base, suite);
    if (terminology) {
      [self addSuite:dsuite terminology:terminology];
      [self preloadSuite:dsuite];
    }
    return;
  }
  [sd_cache addObject:suite];
  
  /* ignore suite not found */
  return;
}

- (void)preloadSuite:(NSDictionary *)dictionary {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  /* Check type */
  NSString *type = [dictionary objectForKey:@"Type"];
  if (type) {
    NSString *suite = nil;
    if (_CocoaScriptingDecomposeType(type, &suite) && suite) {
      if (![sd_cache containsObject:suite])
        [self loadSuite:suite];
    }
  } else {
    /* Check superclass */
    NSString *sclass = [dictionary objectForKey:@"Superclass"];
    if (sclass) {
      NSString *suite = nil;
      if (_CocoaScriptingDecomposeName(sclass, &suite) && suite) {
        if (![sd_cache containsObject:suite])
          [self loadSuite:suite];
      }
    }
    /* Check responds-to */
    NSDictionary *responds = [dictionary objectForKey:@"SupportedCommands"];
    if (responds) {
      NSString *key;
      NSEnumerator *keys = [responds keyEnumerator];
      while (key = [keys nextObject]) {
        NSString *suite = nil;
        if (_CocoaScriptingDecomposeName(key, &suite) && suite) {
          if (![sd_cache containsObject:suite])
            [self loadSuite:suite];
        }
      }
    }
  } 
  
  /* check sub dictionaries */
  id entry;
  NSEnumerator *values = [dictionary objectEnumerator];
  while (entry = [values nextObject]) {
    if ([entry isKindOfClass:[NSDictionary class]])
      [self preloadSuite:entry];
  }
  [pool release];
}

- (BOOL)preload {
  [self preloadSuite:[sd_suites objectAtIndex:0]];
  return YES;
}


#pragma mark Post Processor
- (void)loadCoreSdef:(NSString *)name {
  NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"sdef"];
  if (path) {
    SdefDictionary *dico = SdefLoadDictionary(path, nil, nil);
    if (dico) {
      for (NSUInteger idx = 0; idx < [dico count]; idx++) {
        SdefSuite *suite = [dico childAtIndex:idx];
        DLog(@"Load core suite: %@", suite);
        [manager addSuite:suite];
      }
    }
  }
}

- (void)postProcess {
  if (sd_std) {
    [self loadCoreSdef:@"NSCoreSuite"];
    [self loadCoreSdef:@"NSTextSuite"];
  }
  if (sd_scpt) {
    [self loadCoreSdef:@"AppleScriptKit"];
  }
  [super postProcess];
}

- (BOOL)resolveObjectType:(SdefObject *)obj {
  NSString *suite = nil, *typename = nil, *type;
  type = [obj valueForKey:@"type"];
  if (!type) return YES;
  
  if ([type rangeOfString:@"." options:NSLiteralSearch].location == NSNotFound)
    typename = [manager sdefTypeForCocoaType:type];
  if (!typename) {
    type = _CocoaScriptingDecomposeType(type, &suite);
    typename = [[manager sdefTypeWithCocoaType:type inSuite:suite] name];
  }
  if (typename) {
    [obj setValue:typename forKey:@"type"];
    return YES;
  } else {
    return NO;
  }
}

- (void)postProcessClass:(SdefClass *)aClass {
  NSString *suite = nil;
  NSString *inherits = [aClass inherits];
  if (inherits != nil) {
    inherits = _CocoaScriptingDecomposeName(inherits, &suite);
    SdefClass *parent = [manager sdefClassWithCocoaClass:inherits inSuite:suite];
    if (parent) {
      [aClass setInherits:[parent name]];
    } else {
      [self addWarning:[NSString stringWithFormat:@"Unable to resolve super class name: %@", [aClass inherits]]
              forValue:[aClass name] node:aClass];
	}
  }
  [super postProcessClass:aClass];
}

- (void)postProcessContents:(SdefContents *)aContents forClass:aClass {
  if ([[aContents type] isEqualToString:@"NSArray"])
    [self addWarning:@"Contents NSArray type import as \"list of any\""
            forValue:[aClass name] node:aClass];
  [super postProcessContents:aContents forClass:aClass];
}

- (void)postProcessElement:(SdefElement *)anElement inClass:(SdefClass *)aClass {
  if ([[anElement type] isEqualToString:@"NSArray"]) 
    [self addWarning:@"Element NSArray type import as \"list of any\""
            forValue:[aClass name] node:anElement];
  [super postProcessElement:anElement inClass:aClass];
}

- (void)postProcessProperty:(SdefProperty *)aProperty inClass:(SdefClass *)aClass {
  if ([[aProperty type] isEqualToString:@"NSArray"])
    [self addWarning:@"NSArray type import as \"list of any\""
            forValue:[NSString stringWithFormat:@"%@->%@", [aClass name], [aProperty name]] node:aProperty];
  [super postProcessProperty:aProperty inClass:aClass];
}

- (void)postProcessRespondsTo:(SdefRespondsTo *)aCmd inClass:(SdefClass *)aClass {
  NSString *suite = nil;
  NSString *cmdName = _CocoaScriptingDecomposeName([aCmd name], &suite);
  SdefVerb *cmd = [manager verbWithCocoaName:cmdName inSuite:suite];
  if (cmd) {
    [aCmd setName:[cmd name]];
  } else {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve command: %@", [aCmd name]]
            forValue:[aClass name] node:aCmd];
  }
}

#pragma mark -
- (void)postProcessParameter:(SdefParameter *)aParameter inCommand:(SdefVerb *)aCmd {
  if ([[aParameter type] isEqualToString:@"NSArray"])
    [self addWarning:@"NSArray type import as \"list of any\""
            forValue:[NSString stringWithFormat:@"%@(%@)", [[aParameter parent] name], [aParameter name]] node:aParameter];
  [super postProcessParameter:aParameter inCommand:aCmd];
}

- (void)postProcessDirectParameter:(SdefDirectParameter *)aParameter inCommand:(SdefVerb *)aCmd {
  if ([[aParameter type] isEqualToString:@"NSArray"])
    [self addWarning:@"Direct-Param NSArray type import as \"list of any\""
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]] node:aCmd];
  [super postProcessDirectParameter:aParameter inCommand:aCmd];
}

- (void)postProcessResult:(SdefResult *)aResult inCommand:(SdefVerb *)aCmd {
  if ([[aResult type] isEqualToString:@"NSArray"])
    [self addWarning:@"Result NSArray type import as \"list of any\""
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]] node:aCmd];
  [super postProcessResult:aResult inCommand:aCmd];
}

#pragma mark Import
- (BOOL)import {
  NSUInteger idx = [sd_suites count];
  if (idx == 0)
    return NO;
  
  while (idx-- > 0) {
    SdefSuite *suite = [[SdefSuite alloc] initWithName:nil suite:[sd_suites objectAtIndex:idx] andTerminology:[sd_terminologies objectAtIndex:idx]];
    if (suite) {
      [suites addObject:suite];
      [suite release];
    }    
  }
  
  return [suites count] > 0;
}

@end

#pragma mark -
#pragma mark Statics Methods Implementation
NSString *_CocoaScriptingDecomposeName(NSString *type, NSString **suite) {
  *suite = NULL;
  NSUInteger idx = [type rangeOfString:@"." options:NSLiteralSearch].location;
  if (suite)
    *suite = (idx != NSNotFound) ? [type substringToIndex:idx] : nil;
  return (idx != NSNotFound) ? [type substringFromIndex:idx+1] : type;
}

/* Extract string between "<" and ">" and try to decompose it */
NSString *_CocoaScriptingDecomposeType(NSString *type, NSString **suite) {
  NSUInteger start = [type rangeOfString:@"<" options:NSLiteralSearch].location;
  NSUInteger end = [type rangeOfString:@">" options:NSLiteralSearch].location;
  if (NSNotFound != start && NSNotFound != end) {
    type = [type substringWithRange:NSMakeRange(start+1, end - start - 1)];
  }
  return _CocoaScriptingDecomposeName(type, suite);  
}
