/*
 *  SdefWindowController.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

extern NSString * const SdefTreePboardType;
extern NSString * const SdefInfoPboardType;

extern NSString * const SdefDictionarySelectionDidChangeNotification;

@class SKSplitView;
@class SdefObject;
@class SdefDictionary, SKOutlineViewController;
@interface SdefWindowController : NSWindowController {
  IBOutlet NSOutlineView *outline;
  IBOutlet NSTabView *inspector;
  IBOutlet SKSplitView *uiSplitview;
  
  @private
    BOOL sd_remove;
  SKOutlineViewController *sd_tree;
  NSMutableDictionary *sd_viewControllers;
}

- (id)init;
- (void)setDictionary:(SdefDictionary *)dictionary;

- (void)displayObject:(SdefObject *)anObject;

- (SdefObject *)selection;
- (void)setSelection:(SdefObject *)anObject;

@end
