//
//  SdefImplementation.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefImplementation.h"
#import "SdefXMLNode.h"
#import "SdefDocument.h"

@implementation SdefImplementation

- (void)dealloc {
  [sd_class release];
  [sd_key release];
  [sd_method release];
  [super dealloc];
}

- (NSString *)sdClass {
  return sd_class;
}

- (void)setSdClass:(NSString *)newSdClass {
  if (sd_class != newSdClass) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_class];
    [sd_class release];
    sd_class = [newSdClass copy];
  }
}

- (NSString *)key {
  return sd_key;
}

- (void)setKey:(NSString *)newKey {
  if (sd_key != newKey) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_key];
    [sd_key release];
    sd_key = [newKey copy];
  }
}

- (NSString *)method {
  return sd_method;
}

- (void)setMethod:(NSString *)newMethod {
  if (sd_method != newMethod) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_method];
    [sd_method release];
    sd_method = [newMethod copy];
  }
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = [super xmlNode];
  id attr = [self name];
  if (nil != attr)
    [node setAttribute:attr forKey:@"name"];
  
  attr = [self sdClass];
  if (nil != attr)
    [node setAttribute:attr forKey:@"class"];
  
  attr = [self key];
  if ([self key])
    [node setAttribute:attr forKey:@"key"];
  
  attr = [self method];
  if (nil != attr)
    [node setAttribute:attr forKey:@"method"];
  [node setEmpty:YES];
  return [node attributeCount] > 0 ? node : nil;
}

- (NSString *)xmlElementName {
  return @"cocoa";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setKey:[attrs objectForKey:@"key"]];
  [self setMethod:[attrs objectForKey:@"method"]];
  [self setSdClass:[attrs objectForKey:@"class"]];
}

@end
