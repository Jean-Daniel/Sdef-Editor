/*
 *  SdefXMLObject.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"
#import "SdefType.h"
#import "SdefXRef.h"
#import "SdefSynonym.h"
#import "SdefXMLParser.h"

#import <ShadowKit/SKExtensions.h>

@class SdefXMLNode;
@interface SdefObject (SdefXMLManager)
#pragma mark Parser
- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)setAttributes:(NSDictionary *)attrs;

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs;

#pragma mark Generator
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;

@end

@interface SdefType (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;
@end

@interface SdefXRef (SdefXMLManager)
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs;

#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;
@end

#pragma mark -
@interface SdefSynonym (SdefXMLManager)
#pragma mark Parser
- (void)setAttributes:(NSDictionary *)attrs;
- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs;

#pragma mark Generator
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;
@end
