//
//  SdefEnumeration.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObjects.h"

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

@interface SdefEnumeration : SdefTerminologyObject <NSCopying, NSCoding> {
}

@end

@interface SdefEnumerator : SdefTerminologyObject <NSCopying, NSCoding> {
}

@end

@interface SdefValue  : SdefTerminologyObject <NSCopying, NSCoding> {
}

@end

@interface SdefRecord : SdefTerminologyObject <NSCopying, NSCoding> {  
}

@end

