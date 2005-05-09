//
//  SdefSuite.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObjects.h"

/*
 <!-- SUITE DEFINITION -->
 <!ELEMENT suite (documentation?, %implementation;?, enumeration*, class*, command*, event*, value-type*, record-type*)>
 <!ATTLIST suite
 name       CDATA           #IMPLIED 
 code       %OSType;        #IMPLIED 
 description  %Text;        #IMPLIED
 hidden     (hidden)        #IMPLIED 
 >
*/

@interface SdefTypeCollection : SdefCollection <NSCopying, NSCoding> {
}

@end

@interface SdefSuite : SdefTerminologyObject <NSCopying, NSCoding> {
}

- (SdefCollection *)classes;
- (SdefCollection *)commands;
- (SdefCollection *)events;
- (SdefTypeCollection *)types;

@end
