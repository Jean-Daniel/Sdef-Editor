//
//  SdefSynonym.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefBase.h"

/*
 <!-- SYNONYMS -->
 <!ELEMENT synonym ((%implementation;)?)>
 <!ATTLIST synonym
 name       %Term;          #IMPLIED
 code       %OSType;		 #IMPLIED
 hidden     %yorn;          #IMPLIED 
 >
 <!-- at least one of "name" and "code" is required. -->
 */

@interface SdefSynonym : SdefObject <NSCopying, NSCoding> {
  NSString *sd_code;
}

- (NSString *)code;
- (void)setCode:(NSString *)code;

@end
