//
//  SdefViewController.h
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefObject;
@interface SdefViewController : NSObject {
  IBOutlet NSView *sdefView;
@private
  NSArray *_types;
  SdefObject *_object;
  NSArray *_nibTopLevelObjects;
}

- (id)initWithNibName:(NSString *)name;

- (NSView *)sdefView;

- (id)object;
- (void)setObject:(SdefObject *)newObject;

- (void)selectObject:(SdefObject*)object;

@end

@interface SdefAccessTransformer : NSValueTransformer {
}

+ (id)transformer;

@end

@interface SdefObjectNameTransformer : NSValueTransformer {
}

+ (id)transformer;

@end
