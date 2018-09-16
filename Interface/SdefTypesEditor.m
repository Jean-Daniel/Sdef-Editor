/*
 *  SdefTypeWindow.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefTypesEditor.h"
#import "SdefObjects.h"
#import "SdefClassManager.h"

@implementation SdefTypesEditor

#pragma mark -
- (IBAction)close:(id)sender {
  [sd_object willChangeValueForKey:@"type"];
  [sd_object didChangeValueForKey:@"type"];
  [super close:sender];
}

- (NSView *)field {
  return sd_field;
}
- (void)setField:(NSView *)field {
  sd_field = field;
}

- (SdefTypedObject *)object {
  return sd_object;
}
- (void)setObject:(SdefTypedObject *)object {
  sd_object = object;
}

- (NSArray *)types {
  if (!sd_types) {
    sd_types = [[sd_object classManager] types];
  }
  return sd_types;
}

@end
