//
//  SdefViewController.h
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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

- (id)object;
- (void)setObject:(SdefObject *)newObject;

- (void)selectObject:(SdefObject*)object;

- (void)revealObjectInTree:(SdefObject *)anObject;

- (SdefDocument *)document;
- (SdefClassManager *)classManager;

@end

@interface SdefAccessTransformer : NSValueTransformer {
}

+ (id)transformer;

@end

@interface SdefObjectNameTransformer : NSValueTransformer {
}

+ (id)transformer;

@end
