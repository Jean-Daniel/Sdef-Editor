/*
 *  SdefDocument.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

@class SdefObject, SdefDictionary, SdefClassManager;
@class SdefWindowController, SdefSymbolBrowser, SdefValidator;

WB_PRIVATE 
SdefDictionary *SdefLoadDictionary(NSURL *file, NSInteger *version, id delegate, NSError **error);
WB_PRIVATE
SdefDictionary *SdefLoadDictionaryData(NSData *data, NSURL *base, NSInteger *version, id delegate, NSError **error);

@interface SdefDocument : NSDocument {
@private
  SdefDictionary *sd_dictionary;
  SdefClassManager *sd_manager;
  NSNotificationCenter *sd_center;
}

- (SdefObject *)selection;
- (SdefValidator *)validator;
- (SdefSymbolBrowser *)symbolBrowser;
- (SdefWindowController *)documentWindow;

- (SdefDictionary *)dictionary;
- (void)setDictionary:(SdefDictionary *)dictionary;

- (IBAction)exportTerminology:(id)sender;

- (SdefClassManager *)classManager;
- (NSNotificationCenter *)notificationCenter;

@end
