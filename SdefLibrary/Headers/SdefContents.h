/*
 *  SdefContents.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
 <!-- contents -->
 <!ELEMENT contents ((%implementation;)?, access-group*, (type*))>
 <!ATTLIST contents
 %common.attrib;
 name       %Term;          #IMPLIED
 code       %OSType;        #IMPLIED
 type       %Typename;      #IMPLIED
 access     %rw;            #IMPLIED
 hidden     %yorn;          #IMPLIED
 description  %Text;        #IMPLIED
 >
*/

@interface SdefContents : SdefTypedOrphanObject <NSCopying, NSCoding> {
  uint32_t _access;
}

@property(nonatomic) uint32_t access;

@end
