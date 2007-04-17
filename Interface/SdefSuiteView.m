/*
 *  SdefSuiteView.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKAppKitExtensions.h>
#import "SdefSuiteView.h"
#import "SdefTypedef.h"
#import "SdefSuite.h"

@class SdefClass, SdefClassExtension;
@interface SdefTypeHasClassTransformer : NSValueTransformer {
}

+ (id)transformer;

@end

@implementation SdefSuiteView

+ (void)initialize {
  if ([SdefSuiteView class] == self) {
    [NSValueTransformer setValueTransformer:[SdefTypeHasClassTransformer transformer] forName:@"SdefHasClassTransformer"];
  }
}

- (void)dealloc {
  [sd_typeMenu release];
  [super dealloc];
}

- (void)awakeFromNib {
  [typeTable setTarget:self];
  [typeTable setDoubleAction:@selector(revealType:)];
  [classTable setTarget:self];
  [classTable setDoubleAction:@selector(revealClass:)];
  [commandTable setTarget:self];
  [commandTable setDoubleAction:@selector(revealCommand:)];
  [eventTable setTarget:self];
  [eventTable setDoubleAction:@selector(revealEvent:)];
}

- (NSMenu *)typeMenu {
  if (!sd_typeMenu) {
    sd_typeMenu = [[NSMenu alloc] init];
    NSMenuItem *item;
    
    item = [[NSMenuItem alloc] initWithTitle:@"Value" action:@selector(newType:) keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:[SdefValue defaultIconName]]];
    [item setTag:kSdefValueType];
    [sd_typeMenu addItem:item];
    [item setTarget:self];
    [item release];
    
    item = [[NSMenuItem alloc] initWithTitle:@"Record" action:@selector(newType:) keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:[SdefRecord defaultIconName]]];
    [item setTag:kSdefRecordType];
    [sd_typeMenu addItem:item];
    [item setTarget:self];
    [item release];
    
    item = [[NSMenuItem alloc] initWithTitle:@"Enumeration" action:@selector(newType:) keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:[SdefEnumeration defaultIconName]]];
    [item setTag:kSdefEnumerationType];
    [sd_typeMenu addItem:item];
    [item setTarget:self];
    [item release];
  }
  return sd_typeMenu;
}

- (IBAction)addType:(id)sender {
  [NSMenu popUpContextMenu:[self typeMenu] withEvent:[[sender window] currentEvent] forView:sender];
}

- (IBAction)newType:(id)sender {
  Class class = Nil;
  switch ([sender tag]) {
    case kSdefValueType:
      class = [SdefValue class];
      break;
    case kSdefRecordType:
      class = [SdefRecord class];
      break;
    case kSdefEnumerationType:
      class = [SdefEnumeration class];
      break;
  }
  if (!class) {
    NSBeep();
    return;
  }
  id item = [[class alloc] init];
  [types addObject:item];
  [item release];
}

- (IBAction)addClass:(id)sender {
  // Tiger implementation
  SdefObject *item = [[SdefClass alloc] init];
  [classes addObject:item];
  [item release];
}

- (IBAction)newClass:(id)sender {
  Class class = Nil;
  switch ([sender tag]) {
    case 0:
      class = [SdefClass class];
      break;
    case 1:
      class = [SdefClassExtension class];
      break;
  }
  if (!class) {
    NSBeep();
    return;
  }
  SdefObject *item = [[class alloc] init];
  [classes addObject:item];
  [item release];
}

- (void)revealType:(id)sender {
  int row = [sender clickedRow];
  SdefObject *objs = [(SdefSuite *)[self object] types];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealClass:(id)sender {
  int row = [sender clickedRow];
  SdefObject *objs = [[self object] classes];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealCommand:(id)sender {
  int row = [sender clickedRow];
  SdefObject *objs = [(SdefSuite *)[self object] commands];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealEvent:(id)sender {
  int row = [sender clickedRow];
  SdefObject *objs = [[self object] events];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)setObject:(SdefObject *)anObject {
  [super setObject:anObject];
  sd_idx = -1;
}

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  SdefSuite *content = [self object];
  if (anObject == content) idx = sd_idx;
  else {
    idx = [content indexOfChild:anObject];
    if (idx == NSNotFound) idx = -1;
    else idx++;
  }
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
  /* Value specific behaviour */
  if ([anObject objectType] == kSdefValueType) {
    [types setSelectedObject:anObject];
    [tab selectTabViewItemAtIndex:1];
  }
  sd_idx = 0;
}

@end

@implementation SdefTypeHasClassTransformer

+ (id)transformer {
  return [[[self alloc] init] autorelease];
}

// information that can be used to analyze available transformer instances (especially used inside Interface Builder)
// class of the "output" objects, as returned by transformedValue:
+ (Class)transformedValueClass {
  return [NSNumber class];
}

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation {
  return NO;
}

/* Transform */
- (id)transformedValue:(id)value {
  /* Negation because use with hidden */
  return SKBool([value intValue] != kSdefValueType);
}

/* Returns access value */
//- (id)reverseTransformedValue:(id)value {
//}

@end
