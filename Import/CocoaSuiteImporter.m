//
//  CocoaSuiteImporter.m
//  Sdef Editor
//
//  Created by Grayfox on 25/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "CocoaSuiteImporter.h"
#import "SdefEditor.h"

#import "ShadowMacros.h"

#import "CocoaObject.h"

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefObject.h"
#import "SdefContents.h"
#import "SdefArguments.h"
#import "SdefEnumeration.h"
#import "SdefImplementation.h"

#import "SdefParser.h"
#import "SdefClassManager.h"


#pragma mark Statics Methods Declaration
static NSString *DecomposeCocoaName(NSString *type, NSString **suite);
static NSString *DecomposeCocoaType(NSString *type, NSString **suite);

#pragma mark -
@implementation CocoaSuiteImporter

- (id)initWithContentsOfFile:(NSString *)file {
  id term = [[file stringByDeletingPathExtension] stringByAppendingPathExtension:@"scriptTerminology"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
    [self release];
    self = nil;
  } else {
    self = [self initWithSuiteFile:file andTerminologyFile:term];
  }
  return self;
}

- (id)initWithSuiteFile:(NSString *)suite andTerminologyFile:(NSString *)aTerm {
  if (self = [super initWithContentsOfFile:suite]) {
    [self setSuite:[NSDictionary dictionaryWithContentsOfFile:suite]];
    if (aTerm)
      [self setTerminology:[NSDictionary dictionaryWithContentsOfFile:aTerm]];
    if (![self suite]) {
      [self release];
      self = nil;
    }
  }
  return self;
}


- (void)dealloc {
  [sd_suites release];
  
  [sd_suite release];
  [sd_terminology release];
  [super dealloc];
}

#pragma mark -

- (SdefSuite *)sdefSuite {
  return [[self sdefSuites] objectAtIndex:0];
}

- (NSDictionary *)suite {
  return sd_suite;
}

- (void)setSuite:(NSDictionary *)aSuite {
  if (sd_suite != aSuite) {
    [sd_suite release];
    sd_suite = [aSuite retain];
  }
}

- (NSDictionary *)terminology {
  return sd_terminology;
}

- (void)setTerminology:(NSDictionary *)aTerminology {
  if (sd_terminology != aTerminology) {
    [sd_terminology release];
    sd_terminology = [aTerminology retain];
  }
}

#pragma mark -
#pragma mark Importer
- (void)loadSuite:(NSString *)suite {
  while (suite && ![sd_suites containsObject:suite]) {
    NSString *suitePath = nil;
    if ([suite isEqualToString:@"NSCoreSuite"] || [suite isEqualToString:@"NSTextSuite"]) {
      suitePath = [[NSBundle mainBundle] pathForResource:suite ofType:@"sdef"];
    } else {
      NSOpenPanel *openPanel = nil;
      NSString *title = [[NSString alloc] initWithFormat:@"Where is the Suite \"%@\"?", suite];
      switch (NSRunAlertPanel(title, @"Sdef Editor need the suite \"%@\" to correctly import your file", @"Find", @"Ignore", nil, suite)) {
        case NSAlertDefaultReturn:
          openPanel = [NSOpenPanel openPanel];
          [openPanel setMessage:title];
          [openPanel setCanChooseFiles:YES];
          [openPanel setCanCreateDirectories:NO];
          [openPanel setCanChooseDirectories:NO];
          [openPanel setAllowsMultipleSelection:NO];
          [openPanel setTreatsFilePackagesAsDirectories:YES];
          switch([openPanel runModalForTypes:[NSArray arrayWithObjects:@"sdef", NSFileTypeForHFSTypeCode(kScriptingDefinitionHFSType), nil]]) {
            case NSOKButton:
              suitePath = ([[openPanel filenames] count]) ? [[openPanel filenames] objectAtIndex:0] : nil;
              break;
          }
            if (suitePath) 
              break;
          case NSAlertAlternateReturn:
            [sd_suites addObject:suite];
            break;
      }
      [title release];
    }
    if (suitePath) {
      id parser = [[SdefParser alloc] init];
      NSData *data = [[NSData alloc] initWithContentsOfFile:suitePath];
      if (data && [parser parseData:data]) {
        unsigned idx;
        SdefObject *dico = [parser document];
        for (idx=0; idx<[dico childCount]; idx++) {
          id sdefSuite = [dico childAtIndex:idx];
          [manager addSuite:sdefSuite];
          [sd_suites addObject:[sdefSuite cocoaName]];
          DLog(@"Load Suite: %@", [sdefSuite cocoaName]);
        }
      }
      [data release];
      [parser release]; 
    }
  }
}

#pragma mark Post Processor
- (BOOL)resolveObjectType:(SdefObject *)obj {
  NSString *suite = nil, *typename = nil, *type;
  type = [obj valueForKey:@"type"];
  if (!type) return YES;
  
  if ([type rangeOfString:@"." options:NSLiteralSearch].location == NSNotFound)
    typename = [manager sdefTypeForCocoaType:type];
  if (!typename) {
    type = DecomposeCocoaType(type, &suite);
    if (suite)
      [self loadSuite:suite];
    typename = [[manager sdefTypeWithCocoaType:type inSuite:suite] name];
  }
  if (typename) {
    [obj setValue:typename forKey:@"type"];
    return YES;
  } else {
    return NO;
  }
}

#pragma mark -
- (void)postProcessClass:(SdefClass *)aClass {
  id suite = nil;
  id superclass = [aClass inherits];
  if (superclass) {
    superclass = DecomposeCocoaName(superclass, &suite);
    if (suite)
      [self loadSuite:suite];
    SdefClass *parent = [manager sdefClassWithCocoaClass:superclass inSuite:suite];
    if (parent) {
      [aClass setInherits:[parent name]];
    } else {
      [self addWarning:[NSString stringWithFormat:@"Unable to resolve super class name: %@", [aClass inherits]]
              forValue:[aClass name]];
    }
  }
  [super postProcessClass:aClass];
}

- (void)postProcessContents:(SdefContents *)aContents forClass:aClass {
  if ([[aContents type] isEqualToString:@"NSArray"])
    [self addWarning:@"Contents NSArray type set to \"list of any\""
            forValue:[aClass name]];
  [super postProcessContents:aContents forClass:aClass];
}

- (void)postProcessElement:(SdefElement *)anElement inClass:(SdefClass *)aClass {
  if ([[anElement type] isEqualToString:@"NSArray"]) 
    [self addWarning:@"Element NSArray type set to \"list of any\""
            forValue:[aClass name]];
  [super postProcessElement:anElement inClass:aClass];
}

- (void)postProcessProperty:(SdefProperty *)aProperty inClass:(SdefClass *)aClass {
  if ([[aProperty type] isEqualToString:@"NSArray"])
    [self addWarning:@"NSArray type set to \"list of any\""
            forValue:[NSString stringWithFormat:@"%@->%@", [aClass name], [aProperty name]]];
  [super postProcessProperty:aProperty inClass:aClass];
}

- (void)postProcessRespondsTo:(SdefRespondsTo *)aCmd inClass:(SdefClass *)aClass {
  NSString *suite = nil;
  NSString *cmdName = DecomposeCocoaName([aCmd name], &suite);
  if (suite)
    [self loadSuite:suite];
  SdefVerb *cmd = [manager verbWithCocoaName:cmdName inSuite:suite];
  if (cmd) {
    [aCmd setName:[cmd name]];
  } else {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve command: %@", [aCmd name]]
            forValue:[aClass name]];
  }
}

#pragma mark -
- (void)postProcessParameter:(SdefParameter *)aParameter inCommand:(SdefVerb *)aCmd {
  if ([[aParameter type] isEqualToString:@"NSArray"])
    [self addWarning:@"NSArray type set to \"list of any\""
            forValue:[NSString stringWithFormat:@"%@(%@)", [[aParameter parent] name], [aParameter name]]];
  [super postProcessParameter:aParameter inCommand:aCmd];
}

- (void)postProcessDirectParameter:(SdefDirectParameter *)aParameter inCommand:(SdefVerb *)aCmd {
  if ([[aParameter type] isEqualToString:@"NSArray"])
    [self addWarning:@"Direct-Param NSArray type set to \"list of any\""
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]]];
  [super postProcessDirectParameter:aParameter inCommand:aCmd];
}

- (void)postProcessResult:(SdefResult *)aResult inCommand:(SdefVerb *)aCmd {
  if ([[aResult type] isEqualToString:@"NSArray"])
    [self addWarning:@"Result NSArray type set to \"list of any\""
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]]];
  [super postProcessResult:aResult inCommand:aCmd];
}

- (void)postProcess {
  id suite = [suites count] ? [suites objectAtIndex:0] : nil;
  if (!suite) return;
  
  sd_suites = [[NSMutableArray alloc] init];
  [sd_suites addObject:[suite cocoaName]];
  
  [super postProcess];
  
  [sd_suites release];
  sd_suites = nil;
}

#pragma mark Import
- (BOOL)import {
  if (![self suite] || ![self terminology])
    return NO;
  
  SdefSuite *suite = [[SdefSuite alloc] initWithName:nil suite:[self suite] andTerminology:[self terminology]];
  if (suite) {
    [suites addObject:suite];
    [suite release];
    return YES;
  }
  return NO;
}

@end

#pragma mark -
#pragma mark Statics Methods Implementation
static NSString *DecomposeCocoaName(NSString *type, NSString **suite) {
  *suite = NULL;
  unsigned idx = [type rangeOfString:@"." options:NSLiteralSearch].location;
  if (suite)
    *suite = (idx != NSNotFound) ? [type substringToIndex:idx] : nil;
  return (idx != NSNotFound) ? [type substringFromIndex:idx+1] : type;
}

/* Extract string between "<" and ">" and try to decompose it */
static NSString *DecomposeCocoaType(NSString *type, NSString **suite) {
  unsigned start = [type rangeOfString:@"<" options:NSLiteralSearch].location;
  unsigned end = [type rangeOfString:@">" options:NSLiteralSearch].location;
  if (NSNotFound != start || NSNotFound != end) {
    type = [type substringWithRange:NSMakeRange(start+1, end - start - 1)];
  }
  return DecomposeCocoaName(type, suite);  
}
