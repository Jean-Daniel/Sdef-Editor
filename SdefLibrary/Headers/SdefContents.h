/*
 *  SdefContents.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
<!-- contents -->
<!ELEMENT contents ((%implementation;)?, (type*))>
<!ATTLIST contents
name       %Classname;     #IMPLIED
code       %OSType;        #IMPLIED 
type       %Typename;      #IMPLIED
access     (r | w | rw)    "rw"     
hidden     %yorn;          #IMPLIED 
description  %Text;        #IMPLIED 
>
*/

@interface SdefContents : SdefTypedObject <NSCopying, NSCoding> {
  unsigned sd_access;
  SdefObject *sd_owner;
}

- (unsigned)access;
- (void)setAccess:(unsigned)newAccess;

- (id)owner;
- (void)setOwner:(SdefObject *)anObject ;

@end
