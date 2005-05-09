//
//  SdefXMLObject.h
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefBase.h"
#import "SdefXMLParser.h"

@class SdefXMLNode;
@interface SdefObject (SdefXMLManager)

#pragma mark -
#pragma mark Parser
- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)setAttributes:(NSDictionary *)attrs;

- (int)acceptXMLElement:(NSString *)element;

#pragma mark -
#pragma mark Generator
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;

@end
