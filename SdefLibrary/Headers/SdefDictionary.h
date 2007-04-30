/*
 *  SdefDictionary.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

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
  SdefVersion sd_version;
  SdefDocument *sd_document;
}

- (NSString *)title;
- (void)setTitle:(NSString *)newTitle;

- (NSArray *)suites;
- (SdefDocument *)document;
- (void)setDocument:(SdefDocument *)document;

- (SdefClassManager *)classManager;

- (SdefVersion)version;
- (void)setVersion:(SdefVersion)vers;

@end
