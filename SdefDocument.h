//
//  SdefDocument.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefDictionary, SdefClassManager, SdefImports;
@interface SdefDocument : NSDocument {
@private
  SdefDictionary *dictionary;
  SdefClassManager *_manager;
  SdefImports *_imports;
}

- (SdefImports *)imports;
- (SdefDictionary *)dictionary;
- (void)setDictionary:(SdefDictionary *)dictionary;

@end
