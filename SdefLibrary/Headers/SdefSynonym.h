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

extern NSString * const kSDSynonymsCollection;

@interface SdefSynonym : SdefObject {
  BOOL hidden;
  OSType code;
}

- (BOOL)hidden;
- (void)setHidden:(BOOL)newHidden;

- (OSType)code;
- (void)setCode:(OSType)newCode;

@end
