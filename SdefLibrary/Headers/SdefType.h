/*
 *  SdefType.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
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

@interface SdefType : SdefLeaf <NSCopying, NSCoding> {

}

- (BOOL)isList;
- (void)setList:(BOOL)list;

@end
