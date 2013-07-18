/*
 *  SdefAccessGroup.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

/*
 <!-- ENTITLEMENTS -->
 <!ELEMENT access-group EMPTY>
 <!ATTLIST access-group
 identifier CDATA           #REQUIRED
 access     %rw;            #IMPLIED
 >
 */
@interface SdefAccessGroup : SdefLeaf <NSCopying, NSCoding> {
@private
  uint32_t _access;
}

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic) uint32_t access;

@end
