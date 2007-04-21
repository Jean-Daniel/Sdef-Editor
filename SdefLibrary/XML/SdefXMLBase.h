/*
 *  SdefXMLObject.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefType.h"
#import "SdefXRef.h"
#import "SdefClass.h"
#import "SdefSynonym.h"

#import <ShadowKit/SKExtensions.h>

@class SdefXMLNode;

@protocol SdefXMLObject <SdefObject>

#pragma mark Parser
- (void)addXMLChild:(id<SdefObject>)node;
- (void)setXMLAttributes:(NSDictionary *)attrs;

#pragma mark Generator
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;

@end

@interface SdefObject (SdefXMLObject) <SdefXMLObject>
#pragma mark Parser
- (void)addXMLChild:(id<SdefObject>)node;
- (void)setXMLAttributes:(NSDictionary *)attrs;

#pragma mark Generator
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;

@end

@interface SdefLeaf (SdefXMLObject) <SdefXMLObject>
#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs;

#pragma mark XML Generation
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;
@end

#pragma mark -
@interface SdefElement (SdefXMLManager)
- (void)addXMLAccessor:(NSString *)style;
@end
