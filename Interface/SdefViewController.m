/*
 *  SdefViewController.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefViewController.h"
#import "SdefClass.h"
#import "SdefDocument.h"
#import "SdefTypesEditor.h"
#import "SdefClassManager.h"
#import "SdefWindowController.h"

@implementation SdefViewController

+ (void)initialize {
  if ([SdefViewController class] == self) {
    [NSValueTransformer setValueTransformer:[SdefTypeColorTransformer transformer] forName:@"SdefTypeColor"];
    [NSValueTransformer setValueTransformer:[SdefAccessTransformer transformer] forName:@"SdefAccessTransformer"];
    [NSValueTransformer setValueTransformer:[SdefObjectNameTransformer transformer] forName:@"SdefObjectNameTransformer"];
  }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
  return ![key isEqualToString:@"object"];
}

- (id)initWithNibName:(NSString *)name {
  if (self = [super init]) {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:name bundle:nil];
    NSArray *objects = nil;
    [nib instantiateWithOwner:self topLevelObjects:&objects];
    sd_nibTopLevelObjects = objects;
  }
  return self;
}

#pragma mark -
- (void)documentWillClose:(SdefDocument *)aDocument {
  [ownerController setContent:nil];
  [objectController unbind:@"contentObject"];
}

- (NSView *)sdefView {
  return sdefView;
}

- (id)object {
  return sd_object;
}

- (void)setObject:(SdefObject *)newObject {
  if (sd_object != newObject) {
    [self willChangeValueForKey:@"object"];
    sd_object = newObject;
    [self didChangeValueForKey:@"object"];
  }
  sd_types = nil;
}

- (void)selectObject:(SdefObject*)object {
}

- (void)revealObjectInTree:(SdefObject *)anObject {
  id ctrl = [[self document] documentWindow];
  [ctrl setSelection:anObject];
}

- (void)revealInTree:(id)sender {
  NSInteger row = [sender clickedRow];
  if (row >= 0 && row < (int)[[self object] count]) {
    [self revealObjectInTree:[(SdefObject *)[self object] childAtIndex:row]];
  }
}

#pragma mark -
- (id)editedObject:(id)sender {
  return nil;
}

- (IBAction)editType:(id)sender {
  if ([sender respondsToSelector:@selector(typeField)]) {
    SdefTypesEditor *editor = [[SdefTypesEditor alloc] init];
    [editor setField:[sender typeField]];
    [editor setObject:[self editedObject:sender]];
    [editor setReleasedWhenClosed:YES];
    [[sender window] beginSheet:editor.window completionHandler:nil];
  }
}

#pragma mark -
#pragma mark Document accessor
+ (NSSet *)keyPathsForValuesAffectingDocument {
  return [NSSet setWithObject:@"object"];
}
- (SdefDocument *)document {
  return [[self object] document];
}

- (SdefClassManager *)classManager {
  return [[self object] classManager];
}

+ (NSSet *)keyPathsForValuesAffectingTypes {
  return [NSSet setWithObject:@"object"];
}
- (NSArray *)types {
  if (!sd_types) {
    sd_types = [[self classManager] types];
  }
  return sd_types;
}

+ (NSSet *)keyPathsForValuesAffectingClasses {
  return [NSSet setWithObject:@"object"];
}
- (NSArray *)classes {
  return [[self classManager] classes];
}

+ (NSSet *)keyPathsForValuesAffectingCommands {
  return [NSSet setWithObject:@"object"];
}
- (NSArray *)commands {
  return [[self classManager] commands];
}

+ (NSSet *)keyPathsForValuesAffectingEvents {
  return [NSSet setWithObject:@"object"];
}
- (NSArray *)events {
  return [[self classManager] events];
}

@end

#pragma mark -
@implementation SdefTypeButton

- (NSView *)typeField {
  return typeField;
}

@end

#pragma mark -
#pragma mark Transformers
@implementation SdefTypeColorTransformer

+ (id)transformer {
  return [[self alloc] init];
}

+ (Class)transformedValueClass {
  return [NSColor class];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

- (id)transformedValue:(id)value {
  static NSColor *color = nil;
  if (!color) {
    color = [NSColor colorWithCalibratedRed:.5 green:.5 blue:.75 alpha:1];
  }
  return ([value respondsToSelector:@selector(hasCustomType)] && [value hasCustomType]) ? color : [NSColor blackColor];
}

/* Returns access value */
- (id)reverseTransformedValue:(id)value {
  return nil;
}

@end

@implementation SdefAccessTransformer

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
  return YES;
}

/* Returns menu idx */
- (id)transformedValue:(id)value {
  NSUInteger rights = [value integerValue];
  NSUInteger idx = 0;
  if (!rights || ((rights & kSdefAccessRead) && (rights & kSdefAccessWrite))) {
    idx = 0;
  } else if (rights & kSdefAccessRead) {
    idx = 1;
  } else if (rights & kSdefAccessWrite) {
    idx = 2;
  }
  return @(idx);
}

/* Returns access value */
- (id)reverseTransformedValue:(id)value {
  switch([value integerValue]) {
    case 0:
      return @(0);
    case 1:
      return @(kSdefAccessRead);
    case 2:
      return @(kSdefAccessWrite);
    default:
      return @(0);
  }
}

@end

@implementation SdefObjectNameTransformer

+ (id)transformer {
  return [[self alloc] init];
}

// information that can be used to analyze available transformer instances (especially used inside Interface Builder)
// class of the "output" objects, as returned by transformedValue:
+ (Class)transformedValueClass {
  return [NSArray class];
}

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation {
  return NO;
}

/* Returns menu idx */
- (id)transformedValue:(id)value {
  id object;
  NSMutableArray *names = [[NSMutableArray alloc] init];
  NSEnumerator *objects = [value objectEnumerator];
  while (object = [objects nextObject]) {
    if ([object name])
      [names addObject:[object name]];
  }
  return names;
}

/* Returns access value */
//- (id)reverseTransformedValue:(id)value {
//  switch([value unsignedIntValue]) {
//    case 0:
//      return SPXUInt(0);
//    case 1:
//      return SPXUInt(kSdefAccessRead);
//    case 2:
//      return SPXUInt(kSdefAccessWrite);
//    default:
//      return SPXUInt(0);
//  }
//}

@end
