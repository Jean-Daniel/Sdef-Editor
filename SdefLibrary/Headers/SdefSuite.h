//
//  SdefSuite.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObjects.h"

/*
 <!-- SUITES -->
 <!ELEMENT suite ((%implementation;)?, (class | class-extension | command | documentation | enumeration | event | record-type | value-type)+)>
 <!ATTLIST suite
 name       CDATA           #IMPLIED 
 code       %OSType;        #IMPLIED 
 description  %Text;        #IMPLIED
 hidden     %yorn;          #IMPLIED 
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
