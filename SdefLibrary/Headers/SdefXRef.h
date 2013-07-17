/*
 *  SdefXRef.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

/* 
 <!ELEMENT xref EMPTY>
 <!ATTLIST xref
 %common.attrib;
 target     CDATA           #REQUIRED
 hidden     %yorn;          #IMPLIED
 >
*/

@interface SdefXRef : SdefLeaf <NSCopying, NSCoding> {
@private
  NSString *_target;
}

@property(nonatomic, copy) NSString *target;

@end
