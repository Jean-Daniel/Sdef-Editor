//
//  SdefViewController.m
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefViewController.h"
#import "SdefClass.h"
#import "SdefDocument.h"
#import "ShadowMacros.h"
#import "SdefClassManager.h"

@implementation SdefViewController

+ (void)initialize {
  static BOOL tooLate = NO;
  if (!tooLate) {
    tooLate = YES;
    [NSValueTransformer setValueTransformer:[SdefAccessTransformer transformer] forName:@"SdefAccessTransformer"];
    [NSValueTransformer setValueTransformer:[SdefObjectNameTransformer transformer] forName:@"SdefObjectNameTransformer"];
  }
  [self setKeys:[NSArray arrayWithObject:@"object"] triggerChangeNotificationsForDependentKey:@"document"];
  [self setKeys:[NSArray arrayWithObject:@"object"] triggerChangeNotificationsForDependentKey:@"types"];
  [self setKeys:[NSArray arrayWithObject:@"object"] triggerChangeNotificationsForDependentKey:@"classes"];
  [self setKeys:[NSArray arrayWithObject:@"object"] triggerChangeNotificationsForDependentKey:@"commands"];
  [self setKeys:[NSArray arrayWithObject:@"object"] triggerChangeNotificationsForDependentKey:@"events"];
}

- (id)initWithNibName:(NSString *)name {
  if (self = [super init]) {
    id nib = [[NSNib alloc] initWithNibNamed:name bundle:nil];
    [nib instantiateNibWithOwner:self topLevelObjects:&_nibTopLevelObjects];
    [_nibTopLevelObjects retain];
    [nib release];
    [_nibTopLevelObjects makeObjectsPerformSelector:@selector(release)];
  }
  return self;
}

- (void)dealloc {
  [_types release];
  [_object release];
  [_nibTopLevelObjects release];
  [super dealloc];
}

#pragma mark -
- (void)documentWillClose:(SdefDocument *)aDocument {
  [ownerController setContent:nil];
  [objectController unbind:@"contentObject"];
}

- (NSView *)sdefView {
  return sdefView;
}

- (SdefObject *)object {
  return _object;
}

- (void)setObject:(SdefObject *)newObject {
  if (_object != newObject) {
    [_object release];
    _object = [newObject retain];
  }
  [_types release];
  _types = nil;
}

- (void)selectObject:(SdefObject*)object {
}

- (SdefDocument *)document {
  return [[self object] document];
}

- (SdefClassManager *)classManager {
  return [[self document] manager];
}

- (NSArray *)types {
  if (!_types) {
    _types = [[self classManager] types];
    [_types retain];
  }
  return _types;
}

- (NSArray *)classes {
  return [[self classManager] classes];
}

- (NSArray *)commands {
  return [[self classManager] commands];
}

- (NSArray *)events {
  return [[self classManager] events];
}

@end

@implementation SdefAccessTransformer

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
  return YES;
}

/* Returns menu idx */
- (id)transformedValue:(id)value {
  unsigned access = [value unsignedIntValue];
  unsigned idx = 0;
  if (!access || ((access & kSDElementRead) && (access & kSDElementWrite))) {
    idx = 0;
  } else if (access & kSDElementRead) {
    idx = 1;
  } else if (access & kSDElementWrite) {
    idx = 2;
  }
  return SKUInt(idx);
}

/* Returns access value */
- (id)reverseTransformedValue:(id)value {
  switch([value unsignedIntValue]) {
    case 0:
      return SKUInt(0);
    case 1:
      return SKUInt(kSDElementRead);
    case 2:
      return SKUInt(kSDElementWrite);
    default:
      return SKUInt(0);
  }
}

@end

@implementation SdefObjectNameTransformer

+ (id)transformer {
  return [[[self alloc] init] autorelease];
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
  id names = [[NSMutableArray alloc] init];
  id objects = [value objectEnumerator];
  id object;
  while (object = [objects nextObject]) {
    if ([object name])
      [names addObject:[object name]];
  }
  return [names autorelease];
}

/* Returns access value */
//- (id)reverseTransformedValue:(id)value {
//  switch([value unsignedIntValue]) {
//    case 0:
//      return SKUInt(0);
//    case 1:
//      return SKUInt(kSDElementRead);
//    case 2:
//      return SKUInt(kSDElementWrite);
//    default:
//      return SKUInt(0);
//  }
//}

@end
