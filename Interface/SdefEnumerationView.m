/*
 *  SdefEnumerationView.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefEnumerationView.h"
#import "SdefTypedef.h"

#import <WonderBox/NSArrayController+WonderBox.h>

@interface SdefEnumerationInlineTransformer : NSValueTransformer {
}

+ (id)transformer;

@end


@implementation SdefEnumerationView

+ (void)initialize {
  if ([SdefEnumerationView class] == self) {
    [NSValueTransformer setValueTransformer:[SdefEnumerationInlineTransformer transformer] forName:@"SdefEnumerationInline"];
  }
}

- (void)selectObject:(SdefObject*)anObject {
  NSInteger idx = -1;
  SdefEnumeration *content = [self object];
  if (anObject == content) idx = 0;
  else if ([anObject parent] == content) {
    idx = 1;
    [ibEnumerators setSelectedObject:anObject];
  }
  if (idx >= 0)
    [uiTab selectTabViewItemAtIndex:idx];
}

//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
//  WBTrace();
//  id table = [aNotification object];
//  NSInteger row = [table selectedRow];
//  if (row >= 0 && row < [[self object] count]) {
//    [self revealObjectInTree:[[self object] childAtIndex:row]];
//  }
//}

@end

@implementation SdefRecordView

- (void)selectObject:(SdefObject*)anObject {
  NSInteger idx = -1;
  SdefRecord *content = [self object];
  if (anObject == content) idx = 0;
  else if ([anObject parent] == content) {
    idx = 1;
    [ibProperties setSelectedObject:anObject];
  }
  if (idx >= 0)
    [uiTab selectTabViewItemAtIndex:idx];
}

- (id)editedObject:(id)sender {
  return [ibProperties selectedObject];
}

@end

@implementation SdefEnumerationInlineTransformer

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

/* Transform */
- (id)transformedValue:(id)value {
  NSInteger inlin = [value integerValue];
  return (kSdefInlineAll == inlin) ? nil : value;
}

/* Returns access value */
- (id)reverseTransformedValue:(id)value {
  return (value) ? value : SPXInteger(kSdefInlineAll);
}

@end
