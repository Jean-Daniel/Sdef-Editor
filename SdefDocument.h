//
//  SdefDocument.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const SdefObjectDragType;

@class SdefObject, SdefDictionary, SdefClassManager, SdefImports;
@interface SdefDocument : NSDocument {
@private
  SdefDictionary *_dictionary;
  SdefClassManager *_manager;
  SdefImports *_imports;
}

- (SdefObject *)selection;

//- (SdefImports *)imports;
- (SdefClassManager *)manager;
- (SdefDictionary *)dictionary;
- (void)setDictionary:(SdefDictionary *)dictionary;

- (IBAction)exportTerminology:(id)sender;

@end
