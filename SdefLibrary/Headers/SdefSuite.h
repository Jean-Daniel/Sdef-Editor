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
extern NSString * const kSDTypesCollection;
extern NSString * const kSDClassesCollection;
extern NSString * const kSDCommandsCollection;
extern NSString * const kSDEventsCollection;

@class SdefDocumentation;
@interface SdefSuite : SdefTerminologyElement {
}

- (SdefCollection *)types;
- (SdefCollection *)classes;
- (SdefCollection *)commands;
- (SdefCollection *)events;

@end
