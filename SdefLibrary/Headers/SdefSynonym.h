//
//  SdefSynonym.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefLeave.h"

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

@class SdefImplementation;
@interface SdefSynonym : SdefLeave <NSCopying, NSCoding> {
  NSString *sd_code;
  SdefImplementation *sd_impl; 
}

- (NSImage *)icon;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)flag;

- (NSString *)code;
- (void)setCode:(NSString *)code;

- (SdefImplementation *)impl;
- (void)setImpl:(SdefImplementation *)anImpl;

@end
