/*
 *  SdefTypeWindow.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import WBHEADER(WBWindowController.h)

@class SdefTypedObject;
@interface SdefTypesEditor : WBWindowController {
  NSView *sd_field;
  NSArray *sd_types;
  SdefTypedObject *sd_object;
}

- (NSView *)field;
- (void)setField:(NSView *)field;
- (SdefTypedObject *)object;
- (void)setObject:(SdefTypedObject *)object;

@end
