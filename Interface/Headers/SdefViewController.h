/*
 *  SdefViewController.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

@class SdefObject, SdefDocument, SdefClassManager;
@interface SdefViewController : NSObject {
  IBOutlet NSView *sdefView;
  IBOutlet NSObjectController *ownerController;
  IBOutlet NSObjectController *objectController;
@private
  NSArray *sd_types;
  SdefObject *sd_object;
  NSArray *sd_nibTopLevelObjects;
}

- (id)initWithNibName:(NSString *)name;

- (NSView *)sdefView;

- (IBAction)editType:(id)sender;

- (id)object;
- (id)editedObject:(id)sender;
- (void)setObject:(SdefObject *)newObject;

- (void)selectObject:(SdefObject*)object;

- (void)revealObjectInTree:(SdefObject *)anObject;

- (SdefDocument *)document;
- (SdefClassManager *)classManager;

@end

@interface SdefTypeButton : NSButton {
  IBOutlet NSTextField *typeField; 
}
- (NSView *)typeField;
@end

@interface SdefTypeColorTransformer : NSValueTransformer {
}
+ (id)transformer;
@end

@interface SdefAccessTransformer : NSValueTransformer {
}
+ (id)transformer;
@end

@interface SdefObjectNameTransformer : NSValueTransformer {
}
+ (id)transformer;
@end
