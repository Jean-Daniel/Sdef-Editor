/*
 *  SdefImplementation.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

/*
 <!-- IMPLEMENTATION ELEMENTS -->
 <!ENTITY % implementation "(cocoa)">
 <!ELEMENT cocoa EMPTY>
 <!ATTLIST cocoa
 name       NMTOKEN         #IMPLIED
 class      NMTOKEN         #IMPLIED
 key        NMTOKEN         #IMPLIED
 method     NMTOKEN         #IMPLIED
 boolean-value (YES|NO)     #IMPLIED
 integer-value NMTOKEN      #IMPLIED
 string-value  CDATA        #IMPLIED
 >
*/

@class SdefDocument;
@interface SdefImplementation : SdefOrphanObject <NSCopying, NSCoding> {
@private
  NSString *sd_key;
  NSString *sd_class;
  NSString *sd_method;
}

- (NSString *)sdClass;
- (void)setSdClass:(NSString *)newSdClass;

- (NSString *)key;
- (void)setKey:(NSString *)newKey;

- (NSString *)method;
- (void)setMethod:(NSString *)newMethod;

@end
