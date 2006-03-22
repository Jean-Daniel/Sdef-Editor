/*
 *  SdefObjectInspector.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class SdefObject, SdefDocument;
@interface SdefObjectInspector : NSWindowController {
  SdefDocument *sd_doc;
  BOOL needsUpdate;
}

+ (id)sharedInspector;

- (SdefObject *)content;

- (SdefDocument *)displayedDocument;
- (void)setDisplayedDocument:(SdefDocument *)aDocument;

@end
