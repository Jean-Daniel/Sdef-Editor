//
//  SdefArguments.h
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

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
