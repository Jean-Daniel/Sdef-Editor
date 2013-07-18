/*
 *  SdefImplementation.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

/*
 <!ENTITY % implementation "(cocoa)">
 <!ELEMENT cocoa EMPTY>
 <!ATTLIST cocoa
 %common.attrib;
 name       NMTOKEN         #IMPLIED
 class      NMTOKEN         #IMPLIED
 key        NMTOKEN         #IMPLIED
 method     NMTOKEN         #IMPLIED
 insert-at-beginning %yorn; #IMPLIED
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
  id _value;
  UInt8 _vtype; /* value type */
  
  NSString *_key;
  NSString *_class;
  NSString *_method;
}

@property(nonatomic, copy) NSString *className;

@property(nonatomic, copy) NSString *key;

@property(nonatomic, copy) NSString *method;

@property(nonatomic) BOOL insertAtBeginning;

/* value support */
@property(nonatomic) uint8_t valueType;

@property(nonatomic) BOOL booleanValue;
@property(nonatomic) NSInteger integerValue;
@property(nonatomic, copy) NSString *textValue;

@end
