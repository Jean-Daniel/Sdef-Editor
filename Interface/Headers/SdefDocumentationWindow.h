//
//  SdefDocumentationView.h
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefDocumentation;
@interface SdefDocumentationWindow : NSWindowController {
  IBOutlet id text;
  SdefDocumentation *_object;
}

- (SdefDocumentation *)object;
- (void)setObject:(SdefDocumentation *)newObject;

@end
