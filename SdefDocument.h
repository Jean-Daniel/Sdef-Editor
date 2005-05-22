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
@class SdefWindowController, SdefSymbolBrowser;

extern SdefDictionary *SdefLoadDictionary(NSString *filename);
extern SdefDictionary *SdefLoadDictionaryData(NSData *data);

@interface SdefDocument : NSDocument {
@private
  SdefDictionary *sd_dictionary;
}

- (SdefObject *)selection;
- (SdefSymbolBrowser *)symbolBrowser;
- (SdefWindowController *)documentWindow;

- (SdefDictionary *)dictionary;
- (void)setDictionary:(SdefDictionary *)dictionary;

- (IBAction)exportTerminology:(id)sender;

@end
