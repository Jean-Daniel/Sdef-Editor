/*
 *  SdefSuiteView.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefSuiteView.h"
#import "SdefTypedef.h"
#import "SdefSuite.h"
#import "SdefClass.h"

#import <WonderBox/NSArrayController+WonderBox.h>

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
    [item setTag:kSdefType_ValueType];
    [sd_typeMenu addItem:item];
    [item setTarget:self];
    
    item = [[NSMenuItem alloc] initWithTitle:@"Record" action:@selector(newType:) keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:[SdefRecord defaultIconName]]];
    [item setTag:kSdefType_RecordType];
    [sd_typeMenu addItem:item];
    [item setTarget:self];
    
    item = [[NSMenuItem alloc] initWithTitle:@"Enumeration" action:@selector(newType:) keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:[SdefEnumeration defaultIconName]]];
    [item setTag:kSdefType_Enumeration];
    [sd_typeMenu addItem:item];
    [item setTarget:self];
  }
  return sd_typeMenu;
}

- (IBAction)addType:(id)sender {
  NSEvent *event = [[sender window] currentEvent];
  if ([event type] != NSEventTypeLeftMouseDown && [sender isKindOfClass:[NSView class]]) {
    NSPoint location = [sender convertPoint:NSMakePoint(3, 10) toView:nil];
    event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown
                               location:location
                          modifierFlags:0 timestamp:[event timestamp]
                           windowNumber:[event windowNumber] context:nil eventNumber:0 clickCount:1 pressure:0];
  }
  [NSMenu popUpContextMenu:[self typeMenu] withEvent:event forView:sender];
}

- (IBAction)newType:(id)sender {
  Class class = Nil;
  switch ([sender tag]) {
    case kSdefType_ValueType:
      class = [SdefValue class];
      break;
    case kSdefType_RecordType:
      class = [SdefRecord class];
      break;
    case kSdefType_Enumeration:
      class = [SdefEnumeration class];
      break;
  }
  if (!class) {
    NSBeep();
    return;
  }
  id item = [[class alloc] init];
  [types addObject:item];
}

- (void)revealType:(id)sender {
  NSInteger row = [sender clickedRow];
  SdefObject *objs = [(SdefSuite *)[self object] types];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealClass:(id)sender {
  NSInteger row = [sender clickedRow];
  SdefObject *objs = [[self object] classes];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealCommand:(id)sender {
  NSInteger row = [sender clickedRow];
  SdefObject *objs = [(SdefSuite *)[self object] commands];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealEvent:(id)sender {
  NSInteger row = [sender clickedRow];
  SdefObject *objs = [[self object] events];
  if (row >= 0 && row < (int)[objs count]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)setObject:(SdefObject *)anObject {
  [super setObject:anObject];
  sd_idx = NSNotFound;
}

- (void)selectObject:(SdefObject*)anObject {
  NSUInteger idx = NSNotFound;
  SdefSuite *content = [self object];
  if (anObject == content) idx = sd_idx;
  else {
    idx = [content indexOfChild:anObject];
    if (idx != NSNotFound) idx++;
  }
  if (idx != NSNotFound)
    [tab selectTabViewItemAtIndex:idx];
  /* Value specific behaviour */
  if ([anObject objectType] == kSdefType_ValueType) {
    [types setSelectedObject:anObject];
    [tab selectTabViewItemAtIndex:1];
  }
  sd_idx = 0;
}

@end

@implementation SdefTypeHasClassTransformer

+ (id)transformer {
  return [[self alloc] init];
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
  return @([value intValue] != kSdefType_ValueType);
}

/* Returns access value */
//- (id)reverseTransformedValue:(id)value {
//}

@end
