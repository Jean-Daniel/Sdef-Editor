//
//  SdefObjectInspector.h
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

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
