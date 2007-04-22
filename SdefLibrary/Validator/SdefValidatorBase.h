/*
 *  SdefValidatorBase.h
 *  Sdef Editor
 *
 *  Created by Grayfox on 22/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

@interface SdefValidatorItem : NSObject {
  @private
  UInt8 sd_level;
  NSString *sd_message;
  NSObject<SdefObject> *sd_object;
}

+ (id)noteItemWithNode:(NSObject<SdefObject> *)aNode message:(NSString *)msg, ...;
+ (id)errorItemWithNode:(NSObject<SdefObject> *)aNode message:(NSString *)msg, ...;
+ (id)warningItemWithNode:(NSObject<SdefObject> *)aNode message:(NSString *)msg, ...;

- (NSObject<SdefObject> *)object;

@end

@interface SdefObject (SdefValidator)

/* fill the message array with warnign and errors */
- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers;

@end

/* Private */
@interface NSObject (SdefValidatorInternal)
/* Internal functions */
/* if attr is nil => missing required value */
- (SdefValidatorItem *)invalidValue:(NSString *)attr forAttribute:(NSString *)attr;

- (SdefValidatorItem *)versionRequired:(SdefVersion)vers forAttribute:(NSString *)attr;
- (SdefValidatorItem *)versionRequired:(SdefVersion)vers forElement:(NSString *)element;

@end
