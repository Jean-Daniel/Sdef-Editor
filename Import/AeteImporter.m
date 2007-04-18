/*
 *  AeteImporter.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "AeteImporter.h"
#import <ShadowKit/SKExtensions.h>
#import <ShadowKit/SKFSFunctions.h>

#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefTypedef.h"
#import "SdefClassManager.h"

#import "AeteObject.h"
#import <ShadowKit/SKAEFunctions.h>
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

static
OSStatus _GetTerminologyFromAppleEvent(AppleEvent *theEvent, NSMutableArray *terminolgies) {
  long count = 0;
  AEDescList aetes = {typeNull, nil};
  
  OSStatus err = SKAESetStandardAttributes(theEvent);
  require_noerr(err, bail);
  
  err = SKAEAddSInt32(theEvent, keyDirectObject, 0);
  require_noerr(err, bail);
  
  err = SKAESendEventReturnAEDescList(theEvent, &aetes);
  require_noerr(err, bail);

  err = AECountItems(&aetes, &count);
  require_noerr(err, bail);

  for (CFIndex idx = 1; idx <= count; idx++) {
    CFDataRef data = NULL;
    SKAEGetNthCFDataFromDescList(&aetes, idx, typeAETE, &data);
    if (data) {
      [terminolgies addObject:(id)data];
      CFRelease(data);
    }
  }

bail:
  SKAEDisposeDesc(&aetes);
  return err;
}

- (id)_initWithTarget:(AEDesc *)target {
  if (self = [super init]) {
    AppleEvent theEvent = {typeNull, nil};
    sd_aetes = [[NSMutableArray alloc] init];
    OSStatus err = SKAECreateEventWithTarget(target, kASAppleScriptSuite, kGetAEUT, &theEvent);
    require_noerr(err, bail);
    
    err = _GetTerminologyFromAppleEvent(&theEvent, sd_aetes);
    SKAEDisposeDesc(&theEvent);
    
    err = SKAECreateEventWithTarget(target, kASAppleScriptSuite, kGetAETE, &theEvent);
    require_noerr(err, bail);
    
    err = _GetTerminologyFromAppleEvent(&theEvent, sd_aetes);
    SKAEDisposeDesc(&theEvent);
    
    require(sd_aetes && [sd_aetes count], bail);
  }
  return self;
/* On Error */
bail:
  [sd_aetes release];
  sd_aetes = nil;
  [self release];
  self = nil;
  return self;
}

- (id)initWithApplicationSignature:(OSType)signature {
  AEDesc target;
  OSStatus err = SKAECreateTargetWithSignature(signature, NO, &target);
  if (noErr == err) {
    self = [self _initWithTarget:&target];
  } else {
    [self release];
    self = nil;
  }
  SKAEDisposeDesc(&target);
  return self;
}

- (id)initWithApplicationBundleIdentifier:(NSString *)identifier {
  AEDesc target;
  OSStatus err = SKAECreateTargetWithBundleID((CFStringRef)identifier, NO, &target);
  if (noErr == err) {
    self = [self _initWithTarget:&target];
  } else {
    [self release];
    self = nil;
  }
  SKAEDisposeDesc(&target);
  return self;
}

- (id)initWithFSRef:(FSRef *)aRef {
  if (self = [super init]) {
    ResFileRefNum fileRef;
    OSStatus err = FSOpenResourceFile(aRef, 0, NULL, fsRdPerm, &fileRef);
    if (mapReadErr == err) {
      HFSUniStr255 rsrcName;
      if (noErr == FSGetResourceForkName(&rsrcName)) {
        err = FSOpenResourceFile(aRef, rsrcName.length, rsrcName.unicode, fsRdPerm, &fileRef);
      }
    }
    if(noErr == err) {
      ResourceCount count;
      /* Standard Infos */
      count = Count1Resources(kAEUserTerminology);
      sd_aetes = [[NSMutableArray alloc] initWithCapacity:count];
      for (ResourceCount idx = 1; idx <= count; idx++) {
        Handle aeteH = Get1IndResource(kAEUserTerminology, idx);
        NSData *aete = [[NSData alloc] initWithHandle:aeteH];
        if (aete) {
          [sd_aetes addObject:aete];
          [aete release];
        }
      }
      /* Extensions */
      count = Count1Resources(kAETerminologyExtension);
      for (ResourceCount idx = 1; idx <= count; idx++) {
        Handle aeteH = Get1IndResource(kAETerminologyExtension, idx);
        NSData *aete = [[NSData alloc] initWithHandle:aeteH];
        if (aete) {
          [sd_aetes addObject:aete];
          [aete release];
        }
      }
      CloseResFile(fileRef);
    }
    if (!sd_aetes) {
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
  [sd_aetes release];
  [super dealloc];
}

#pragma mark -
#pragma mark Parsing
- (BOOL)import {
  NSData *aete;
  NSEnumerator *aetes = [sd_aetes objectEnumerator];
  while (aete = [aetes nextObject]) {
    @try {
      BytePtr bytes = (BytePtr)[aete bytes];
      ByteOffset offset = 0;
      AeteHeader *header = (AeteHeader *)bytes;
      bytes += sizeof(AeteHeader);
      offset += sizeof(AeteHeader);
      for (UInt16 idx = 0; idx < header->suiteCount; idx++) {
        SdefSuite *suite = [[SdefSuite allocWithZone:[self zone]] init];
        bytes += [suite parseData:bytes];
        [suites addObject:suite];
        [suite release];
      }
    } @catch (id exception) {
      SKLogException(exception);
      [suites removeAllObjects];
      return NO;
    }
  }
  return YES;
}

#pragma mark Post Processor
- (BOOL)resolveObjectType:(SdefObject *)obj {
  NSString *type = [obj valueForKey:@"type"];
  BOOL isList = NO;
  if ([type hasPrefix:@"list of"]) {
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
  if ([[aClass properties] count]) {
    SdefProperty *info = [[aClass properties] firstChild];
    if (SKOSTypeFromString([info code]) == pInherits) {
      id superclass = [manager sdefClassWithCode:[info type] inSuite:nil];
      if (superclass) {
        [aClass setInherits:[superclass name]];
      } else {
        [self addWarning:[NSString stringWithFormat:@"Unable to find superclass: %@", [info type]]
                forValue:[aClass name]];
      }
      [info remove];
    } else if (SKOSTypeFromString([info code]) == kAESpecialClassProperties) {
      if ([[info name] isEqualToString:@"<Plural>"]) {
        if ([[aClass properties] count] == 1) {
          NSUInteger idx = [aClass index];
          [(SdefClass *)[[aClass parent] childAtIndex:idx-1] setPlural:[aClass name]];
          [aClass remove];
        } else {
          [aClass setPlural:[aClass name]];
          [[aClass properties] removeChildAtIndex:0];
        }
      } else {
        [self addWarning:@"Unable to import Special Properties" forValue:[aClass name]];
      }      
    }
  }
  [super postProcessClass:aClass];
}

@end
