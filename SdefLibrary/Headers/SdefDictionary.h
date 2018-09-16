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
 %common.attrib;
 title      CDATA           #IMPLIED
 >
*/

@class SdefDocument, SdefClassManager;
@interface SdefDictionary : SdefDocumentedObject <NSCopying, NSCoding>

@property(nonatomic, assign) SdefDocument *document; // TODO: remove layer violation

@property(nonatomic) SdefVersion version;

- (SdefClassManager *)classManager;

// Sdef properties
@property(nonatomic, copy) NSString *title;

- (NSArray *)suites;

@end
