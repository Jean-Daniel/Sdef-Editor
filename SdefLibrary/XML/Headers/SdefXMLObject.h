//
//  SdefXMLObject.h
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

extern NSMutableArray *sd_childComments;

extern NSString *SDAccessStringFromFlag(unsigned flag);
extern unsigned SDAccessFlagFromString(NSString *str);

@class SdefXMLNode;
@interface SdefObject (SdefXMLManager)

- (id)initWithAttributes:(NSDictionary *)attributes;

#pragma mark -
- (void)setAttributes:(NSDictionary *)attrs;

- (SdefXMLNode *)xmlNode;
- (NSString *)xmlElementName;

@end
