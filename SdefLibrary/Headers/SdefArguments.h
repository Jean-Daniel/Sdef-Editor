/*
 *  SdefArguments.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

@interface SdefParameter : SdefTypedObject <NSCopying, NSCoding> {
@private
  uint32_t _requiresAccess;
}

@property(nonatomic) uint32_t requiresAccess;
@property(nonatomic, getter = isOptional) BOOL optional;

@end

#pragma mark -
@interface SdefDirectParameter : SdefTypedOrphanObject <NSCopying, NSCoding> {
@private
  uint32_t _requiresAccess;
}

@property(nonatomic) uint32_t requiresAccess;
@property(nonatomic, getter = isOptional) BOOL optional;

@end

#pragma mark -
@interface SdefResult : SdefTypedOrphanObject <NSCopying, NSCoding> {

}

@end
