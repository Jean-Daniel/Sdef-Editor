//
//  SdefEnumeration.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

/*
 <!-- ENUMERATIONS -->
 <!ELEMENT enumeration (documentation?, %implementation;?, enumerator+)>
 <!ATTLIST enumeration
 name       %Typename;      #REQUIRED
 code       %OSType;        #IMPLIED
 hidden     (hidden)        #IMPLIED
 description  %Text;        #IMPLIED
 >
 <!ELEMENT enumerator (%implementation;?, synonyms?)>
 <!ATTLIST enumerator
 name       %Term;          #REQUIRED
 code       %OSType;        #IMPLIED 
 hidden     (hidden)        #IMPLIED 
 description  %Text;        #IMPLIED 
 >
*/

@class SdefDocumentation, SdefImplementation;
@interface SdefEnumeration : SdefTerminologyElement <NSCopying, NSCoding> {
}

@end

@interface SdefEnumerator : SdefTerminologyElement <NSCopying, NSCoding> {
}

@end
