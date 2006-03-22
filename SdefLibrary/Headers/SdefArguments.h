/*
 *  SdefArguments.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

@interface SdefParameter : SdefTypedObject <NSCopying, NSCoding> {
}

- (BOOL)isOptional;
- (void)setOptional:(BOOL)flag;

@end

#pragma mark -
@interface SdefDirectParameter : SdefTypedOrphanObject <NSCopying, NSCoding> {

}

- (BOOL)isOptional;
- (void)setOptional:(BOOL)flag;

@end

#pragma mark -
@interface SdefResult : SdefTypedOrphanObject <NSCopying, NSCoding> {

}

@end
