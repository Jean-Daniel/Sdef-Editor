/*
 *  SdefTypeWindow.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@class SdefTypedObject;
@interface SdefTypesEditor : SKWindowController {
  NSView *sd_field;
  NSArray *sd_types;
  SdefTypedObject *sd_object;
}

- (NSView *)field;
- (void)setField:(NSView *)field;
- (SdefTypedObject *)object;
- (void)setObject:(SdefTypedObject *)object;

@end
