//
//  SdefSuite.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

/*
 <!-- SUITE DEFINITION -->
 <!ELEMENT suite (documentation?, %implementation;?, types?, classes?, commands?, events?)>
 <!ATTLIST suite
 name       CDATA           #IMPLIED 
 code       %OSType;        #IMPLIED 
 description  %Text;        #IMPLIED
 hidden     (hidden)        #IMPLIED 
 >
 
 <!ELEMENT types (enumeration+)>
 <!ELEMENT classes (class+)>
 <!ELEMENT commands (command+)>
 <!ELEMENT events (event+)>
*/

@class SdefDocumentation;
@interface SdefSuite : SdefTerminologyElement <NSCopying, NSCoding> {
#if !defined (TIGER_SDEF)
  SdefCollection *sd_values;
#endif
}

- (SdefCollection *)types;
- (SdefCollection *)classes;
- (SdefCollection *)commands;
- (SdefCollection *)events;
- (SdefCollection *)values;

@end
