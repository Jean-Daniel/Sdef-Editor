/*
 *  SdefImplementation.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

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

enum {
  kSdefValueTypeNone    = 0,
  kSdefValueTypeString  = 1,
  kSdefValueTypeInteger = 2,
  kSdefValueTypeBoolean = 3,
};

@class SdefDocument;
@interface SdefImplementation : SdefLeaf <NSCopying, NSCoding> {
@private
  id sd_value;
  UInt8 sd_vtype; /* value type */
  
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

/* value support */
- (UInt8)valueType;
- (void)setValueType:(UInt8)aType;

- (NSString *)textValue;
- (void)setTextValue:(NSString *)value;

- (NSInteger)integerValue;
- (void)setIntegerValue:(NSInteger)value;

- (BOOL)booleanValue;
- (void)setBooleanValue:(BOOL)value;

@end
