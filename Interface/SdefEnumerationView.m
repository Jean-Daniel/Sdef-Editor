/*
 *  SdefEnumerationView.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKAppKitExtensions.h>
#import "SdefEnumerationView.h"
#import "SdefTypedef.h"

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
  int idx = -1;
  SdefEnumeration *content = [self object];
  if (anObject == content) idx = 0;
  else if ([anObject parent] == content) {
    idx = 1;
    [enumerators setSelectedObject:anObject];
  }
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
}

//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
//  ShadowTrace();
//  id table = [aNotification object];
//  int row = [table selectedRow];
//  if (row >= 0 && row < [[self object] count]) {
//    [self revealObjectInTree:[[self object] childAtIndex:row]];
//  }
//}

@end

@implementation SdefRecordView

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  SdefRecord *content = [self object];
  if (anObject == content) idx = 0;
  else if ([anObject parent] == content) {
    idx = 1;
    [properties setSelectedObject:anObject];
  }
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
}

- (id)editedObject:(id)sender {
  return [properties selectedObject];
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
  int inlin = [value intValue];
  return (kSdefInlineAll == inlin) ? nil : value;
}

/* Returns access value */
- (id)reverseTransformedValue:(id)value {
  return (value) ? value : SKInt(kSdefInlineAll);
}

@end
