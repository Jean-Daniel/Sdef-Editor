/*
 *  SdefSynonym.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

/*
 <!-- SYNONYMS -->
 <!ELEMENT synonym ((%implementation;)?)>
 <!ATTLIST synonym
 %common.attrib;
 name       %Term;          #IMPLIED
 code       %OSType;		 #IMPLIED
 hidden     %yorn;          #IMPLIED
 >
 <!-- at least one of "name" and "code" is required. -->
 */

@class SdefImplementation;
@interface SdefSynonym : SdefLeaf <NSCopying, NSCoding> {
@private
  SdefImplementation *_impl;
}

@property(nonatomic, copy) NSString *code;
@property(nonatomic, retain) SdefImplementation *impl;

@end
