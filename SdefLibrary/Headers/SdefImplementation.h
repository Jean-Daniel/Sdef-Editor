//
//  SdefImplementation.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

/*
 <!-- IMPLEMENTATION ELEMENTS -->
 <!ENTITY % implementation "(cocoa)">
 <!ELEMENT cocoa EMPTY>
 <!ATTLIST cocoa
 name       NMTOKEN         #IMPLIED
 class      NMTOKEN         #IMPLIED
 key        NMTOKEN         #IMPLIED
 method     NMTOKEN         #IMPLIED
 >
*/

@interface SdefImplementation : SdefObject <NSCopying, NSCoding> {
@private
  NSString *sd_class;
  NSString *sd_key;
  NSString *sd_method;
}

- (NSString *)sdClass;
- (void)setSdClass:(NSString *)newSdClass;

- (NSString *)key;
- (void)setKey:(NSString *)newKey;

- (NSString *)method;
- (void)setMethod:(NSString *)newMethod;

@end
