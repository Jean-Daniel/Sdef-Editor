/*
 *  SdefValidatorBase.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"
#import "SdefLeaf.h"

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

WB_PRIVATE
BOOL SdefValidatorIsKeyword(NSString *str);

WB_PRIVATE
BOOL SdefValidatorCheckCode(NSString *code);

WB_PRIVATE
NSString *SdefValidatorCodeForName(NSString *name);

@interface SdefObject (SdefValidator)

/* fill the message array with warnign and errors */
- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers;

@end

@interface SdefLeaf (SdefValidator)

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
