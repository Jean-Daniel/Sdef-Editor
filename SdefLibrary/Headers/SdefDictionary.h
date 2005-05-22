//
//  SdefDictionary.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObjects.h"

/*
 <!-- DICTIONARY (ROOT ELEMENT) -->
 <!ELEMENT dictionary (documentation*, suite+)>
 <!ATTLIST dictionary
 title      CDATA           #IMPLIED 
 >
*/

@class SdefDocument, SdefClassManager;
@interface SdefDictionary : SdefDocumentedObject <NSCopying, NSCoding> {
@private
  SdefDocument *sd_document;
  SdefClassManager *sd_manager;
}

- (NSString *)title;
- (void)setTitle:(NSString *)newTitle;

- (NSArray *)suites;
- (SdefDocument *)document;
- (void)setDocument:(SdefDocument *)document;

- (SdefClassManager *)classManager;
- (void)setClassManager:(SdefClassManager *)aManager;

@end
