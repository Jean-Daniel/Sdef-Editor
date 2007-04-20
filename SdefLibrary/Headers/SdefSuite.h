/*
 *  SdefSuite.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
 <!-- SUITES -->
 <!ELEMENT suite ((%implementation;)?, (class | class-extension | command | documentation | enumeration | event | record-type | value-type)+)>
 <!ATTLIST suite
 name       CDATA           #REQUIRED
 code       %OSType;        #REQUIRED 
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
