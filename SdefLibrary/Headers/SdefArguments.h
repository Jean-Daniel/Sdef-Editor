/*
 *  SdefArguments.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

@interface SdefParameter : SdefTypedObject <NSCopying, NSCoding> {
}

@property(nonatomic, getter = isOptional) BOOL optional;

@end

#pragma mark -
@interface SdefDirectParameter : SdefTypedOrphanObject <NSCopying, NSCoding> {

}

@property(nonatomic, getter = isOptional) BOOL optional;

@end

#pragma mark -
@interface SdefResult : SdefTypedOrphanObject <NSCopying, NSCoding> {

}

@end
