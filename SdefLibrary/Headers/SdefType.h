//
//  SdefType.h
//  Sdef Editor
//
//  Created by Grayfox on 09/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefLeave.h"

/*
 <!-- TYPES -->
 <!ELEMENT type EMPTY>
 <!ATTLIST type
 type       %Typename;      #REQUIRED 
 list       %yorn;          #IMPLIED
 >
 */

@class SdefTypedObject;
@interface SdefType : SdefLeave <NSCopying, NSCoding> {

}

- (BOOL)isList;
- (void)setList:(BOOL)list;

@end
