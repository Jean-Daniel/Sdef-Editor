//
//  AeteImporter.m
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "AeteImporter.h"
#import "ShadowMacros.h"
#import "SKFunctions.h"
#import "SKExtensions.h"

#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefEnumeration.h"
#import "SdefClassManager.h"

#import "AeteObject.h"
#import "ShadowAEUtils.h"
#include <Carbon/Carbon.h>

struct AeteHeader {
  UInt8 majorVersion;
  UInt8 minorVersion;
  UInt16 lang;
  UInt16 script;
  UInt16 suiteCount;
};
typedef struct AeteHeader AeteHeader;

@implementation AeteImporter

- (id)initWithApplicationSignature:(OSType)signature {
  if (self = [super init]) {
    AppleEvent theEvent;
    OSStatus err = ShadowAECreateEventWithTargetSignature(signature, kASAppleScriptSuite, kGetAETE, &theEvent);
    if (noErr == err) {
      err = ShadowAEAddMagnitude(&theEvent);
    }
    if (noErr == err) {
      err = ShadowAEAddSubject(&theEvent);
    }
    if (noErr == err) {
      err = ShadowAEAddSInt32(&theEvent, keyDirectObject, 0);
    }
    if (noErr == err) {
      err = ShadowAESendEventReturnCFData(&theEvent, typeAETE, (CFDataRef *)&sd_rsrc);
    }
    ShadowAEDisposeDesc(&theEvent);
    if (!sd_rsrc) {
      [self release];
      self = nil;
    }
  }
  return self;
}

- (id)initWithFSRef:(FSRef *)aRef {
  if (self = [super init]) {
    short fileRef;
    if(noErr == FSOpenResourceFile(aRef, 0, NULL, fsRdPerm, &fileRef)) {
      if (Count1Resources(kAETerminologyExtension) > 0) {
        Handle aeteH = Get1IndResource(kAETerminologyExtension, 1);
        sd_rsrc = [[NSData alloc] initWithHandle:aeteH];
      }
      CloseResFile(fileRef);
    }
    if (!sd_rsrc) {
      [self release];
      self = nil;
    }
  }
  return self;
}

- (id)initWithContentsOfFile:(NSString *)aFile {
  FSRef aRef;
  if (![aFile getFSRef:&aRef]) {
    [self release];
    self = nil;
  } else {
    self = [self initWithFSRef:&aRef];
  }
  return self;
}

- (void)dealloc {
  [sd_rsrc release];
  [super dealloc];
}

- (NSString *)description {
  AeteHeader *header = (AeteHeader *)[sd_rsrc bytes];
  return [NSString stringWithFormat:@"<%@ %p> {version: %x.%x, suites: %d}",
    NSStringFromClass([self class]), self,
    header->majorVersion, header->minorVersion, header->suiteCount];
}

#pragma mark -

- (unsigned)suiteCount {
  AeteHeader *header = (AeteHeader *)[sd_rsrc bytes];
  return header->suiteCount;
}

#pragma mark -
#pragma mark Parsing

- (BOOL)import {
  if (!sd_rsrc) return NO;
  
  @try {
    BytePtr bytes = (BytePtr)[sd_rsrc bytes];
    ByteOffset offset = 0;
    AeteHeader *header = (AeteHeader *)bytes;
    bytes += sizeof(AeteHeader);
    offset += sizeof(AeteHeader);
    unsigned idx = 0;
    for (idx=0; idx<header->suiteCount; idx++) {
      SdefSuite *suite = [SdefSuite node];
      bytes += [suite parseData:bytes];
      [suites addObject:suite];
    }
  } @catch (id exception) {
    SKLogException(exception);
    return NO;
  }
  return YES;
}

#pragma mark Post Processor
- (BOOL)resolveObjectType:(SdefObject *)obj {
  NSString *type = [obj valueForKey:@"type"];
  BOOL isList = NO;
  if ([type rangeOfString:@"list of" options:NSLiteralSearch | NSAnchoredSearch].location != NSNotFound) {
    isList = YES;
    type = [type substringFromIndex:8];
  }
  NSString *typename = [manager sdefTypeForAeteType:type];
  if (!typename) {
    typename = [[manager sdefTypeWithCode:type inSuite:nil] name];
  }
  if (typename) {
    if (isList) typename = [@"list of " stringByAppendingString:typename];
    [obj setValue:typename forKey:@"type"];
    return YES;
  }
  return NO;
}

- (void)postProcessClass:(SdefClass *)aClass {
  if ([[aClass properties] childCount]) {
    SdefProperty *info = [[aClass properties] firstChild];
    if (SKHFSTypeCodeFromFileType([info codeStr]) == pInherits) {
      id superclass = [manager sdefClassWithCode:[info type] inSuite:nil];
      if (superclass) {
        [aClass setInherits:[superclass name]];
      } else {
        [self addWarning:[NSString stringWithFormat:@"Unable to find superclass: %@", [info type]]
                forValue:[aClass name]];
      }
      [info remove];
    } else if (SKHFSTypeCodeFromFileType([info codeStr]) == kAESpecialClassProperties) {
      if ([[info name] isEqualToString:@"<Plural>"]) {
        unsigned idx = [[aClass parent] indexOfChild:aClass];
        [[[aClass parent] childAtIndex:idx-1] setPlural:[aClass name]];
        [aClass remove];
      } else {
        [self addWarning:@"Unable to understand Special Properties" forValue:[aClass name]];
      }      
    }
  }
  [super postProcessClass:aClass];
}

@end
