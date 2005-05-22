//
//  SdefTypeWindow.h
//  Sdef Editor
//
//  Created by Grayfox on 21/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKWindowController.h"

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
