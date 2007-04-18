/*
 *  SdefDocument.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class SdefObject, SdefDictionary, SdefClassManager, SdefImports;
@class SdefWindowController, SdefSymbolBrowser;

SK_PRIVATE 
SdefDictionary *SdefLoadDictionary(NSString *filename, NSInteger *version, id delegate);
SK_PRIVATE
SdefDictionary *SdefLoadDictionaryData(NSData *data, NSInteger *version, id delegate);

@interface SdefDocument : NSDocument {
@private
  SdefDictionary *sd_dictionary;
  SdefClassManager *sd_manager;
}

- (SdefObject *)selection;
- (SdefSymbolBrowser *)symbolBrowser;
- (SdefWindowController *)documentWindow;

- (SdefDictionary *)dictionary;
- (void)setDictionary:(SdefDictionary *)dictionary;

- (IBAction)exportTerminology:(id)sender;

- (SdefClassManager *)classManager;

@end
