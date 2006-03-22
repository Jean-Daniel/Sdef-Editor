/*
 *  SdefWindowController.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

extern NSString * const SdefTreePboardType;
extern NSString * const SdefInfoPboardType;

extern NSString * const SdefDictionarySelectionDidChangeNotification;

@class SdefObject;
@interface SdefWindowController : NSWindowController {
  IBOutlet NSOutlineView *outline;
  IBOutlet NSTabView *inspector;
  
  NSMutableDictionary *sd_viewControllers;
}

- (id)initWithOwner:(id)owner;

- (void)displayObject:(SdefObject *)anObject;

- (SdefObject *)selection;
- (void)setSelection:(SdefObject *)anObject;

@end
