//
//  SdefSynonym.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

/*
 <!-- SYNONYMS -->
 <!ELEMENT synonyms (synonym+)>
 <!ELEMENT synonym (%implementation;?)>
 <!ATTLIST synonym
 name       %Term;          #IMPLIED
 code       %OSType;		 #IMPLIED
 hidden     (hidden)        #IMPLIED 
 >
 <!-- at least one of "name" and "code" is required. -->
 */

@interface SdefSynonym : SdefTerminologyElement <NSCopying, NSCoding> {
}

- (NSString *)desc;
- (void)setDesc:(NSString *)description;

@end
