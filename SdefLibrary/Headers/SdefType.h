/*
 *  SdefType.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

/*
 <!-- TYPES -->
 <!ELEMENT type EMPTY>
 <!ATTLIST type
 type       %Typename;      #REQUIRED 
 list       %yorn;          #IMPLIED
 >
 */

@class SdefTypedObject;
@interface SdefType : SdefLeaf <NSCopying, NSCoding> {

}

- (BOOL)isList;
- (void)setList:(BOOL)list;

@end
