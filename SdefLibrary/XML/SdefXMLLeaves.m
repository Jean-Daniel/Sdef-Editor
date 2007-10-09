/*
 *  SdefXMLLeaves.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

#import "SdefDocumentation.h"
#import "SdefImplementation.h"

@implementation SdefLeaf (SdefXMLManager)

#pragma mark XML Generation
- (NSString *)xmlElementName {
  return nil;
}
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [[SdefXMLNode alloc] initWithElementName:[self xmlElementName]]) {
    /* Hidden */
    if ([self isHidden]) {
      if (version >= kSdefTigerVersion)
        [node setAttribute:@"yes" forKey:@"hidden"];
      else
        [node setAttribute:@"hidden" forKey:@"hidden"];
    }
    
    [node autorelease];
  }
  return node;
}

#pragma mark Parsing
- (void)addXMLChild:(id<SdefObject>)node {
  [NSException raise:NSInvalidArgumentException format:@"%@ does not support children", self];
}
- (void)addXMLComment:(NSString *)comment {
  ShadowTrace();
}

- (void)setXMLMetas:(NSDictionary *)metas {
  //DLog(@"Metas: %@, %@", self, metas);
}
- (void)setXMLAttributes:(NSDictionary *)attrs {
  NSString *hidden = [attrs objectForKey:@"hidden"];
  if (hidden && ![hidden isEqualToString:@"no"]) {
    [self setHidden:YES];
  }
}

@end

@implementation SdefSynonym (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"synonym";
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    /* Code */
    NSString *attr = [self code];
    if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"code"];
    /* Name */
    attr = [self name];
    if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"name"];

    /* Implementation */
    if (sd_impl) {
      SdefXMLNode *implNode = [sd_impl xmlNodeForVersion:version];
      if (implNode) {
        [node prependChild:implNode];
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return [node attributeCount] > 0 ? node : nil;
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  NSString *attr = [attrs objectForKey:@"name"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  
  attr = [attrs objectForKey:@"code"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  [self setCode:[attr stringByUnescapingEntities:nil]];
}

@end

#pragma mark -
@implementation SdefXRef (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"xref";
}
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self target] && version >= kSdefLeopardVersion) {
    if (node = [super xmlNodeForVersion:version]) {
      [node setEmpty:YES];
      /* Code */
      NSString *attr = [self target];
      if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"target"];
    }
  }
  return node;
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  NSString *attr = [attrs objectForKey:@"target"];
  if (attr)
    [self setTarget:[attr stringByUnescapingEntities:nil]];
}

@end

#pragma mark -
@implementation SdefType (SdefXMLManager)
- (NSString *)xmlElementName {
  return @"type";
}

#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self name] && version >= kSdefTigerVersion) {
    if (node = [super xmlNodeForVersion:version]) {
      [node setEmpty:YES];
      [node setAttribute:[[self name] stringByEscapingEntities:nil] forKey:@"type"];
      if ([self isList]) {
        [node setAttribute:@"yes" forKey:@"list"];
      }
    }
  }
  return node;
}

- (void)setXMLAttributes:(NSDictionary *)attrs {
  NSString *attr = [attrs objectForKey:@"type"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  
  attr = [attrs objectForKey:@"list"];
  if (attr && ![attr isEqualToString:@"no"]) {
    [self setList:YES];
  }
}

@end


#pragma mark -
@implementation SdefDocumentation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if (sd_content != nil) {
    if (node = [super xmlNodeForVersion:version]) {
      if (version >= kSdefTigerVersion && [self isHtml]) {
        SdefXMLNode *html = [[SdefXMLNode alloc] initWithElementName:@"html"];
        [html setContent:sd_content];
        /* Tiger also support CDData */
        [html setCDData:YES];
        [node appendChild:html];
        [html release];
      } else {
        [node setContent:[sd_content stringByEscapingEntities:nil]];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"documentation";
}

@end

#pragma mark -
@implementation SdefImplementation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    [node setEmpty:YES];
    NSString *attr = [self name];
    if (attr && [attr length] > 0)
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"name"];
    
    attr = [self sdClass];
    if (attr && [attr length] > 0)
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"class"];
    
    /* Key and method was change for Property and Element*/
    if (kSdefPantherVersion == version) {
      if ([[self owner] objectType] == kSdefPropertyType ||
          [[self owner] objectType] == kSdefElementType ||
          [[self owner] objectType] == kSdefContentsType) {
        attr = [self key];
        /* responds-to should allows empty command */
        if ([[self owner] objectType] == kSdefRespondsToType) {
          [node setAttribute:attr ? [attr stringByEscapingEntities:nil] : @"" forKey:@"method"]; 
        } else if (attr && [attr length] > 0) {
          [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"method"];
        }
      }
    } else {
      attr = [self key];
      if (attr && [attr length] > 0)
        [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"key"];
      
      attr = [self method];
      /* responds-to should allows empty command */
      if ([[self owner] objectType] == kSdefRespondsToType) {
        [node setAttribute:attr ? [attr stringByEscapingEntities:nil] : @"" forKey:@"method"]; 
      } else if (attr && [attr length] > 0) {
        [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"method"];
      }
    }
    if ([self valueType] != kSdefValueTypeNone) {
      if (version >= kSdefLeopardVersion) {
        switch ([self valueType]) {
          case kSdefValueTypeString:
            [node setAttribute:[[self textValue] stringByEscapingEntities:nil] forKey:@"string-value"];
            break;
          case kSdefValueTypeInteger:
            [node setAttribute:[NSString stringWithFormat:@"%ld", (long)[self integerValue]] forKey:@"integer-value"];
            break;
          case kSdefValueTypeBoolean:
            [node setAttribute:[self booleanValue] ? @"YES" : @"NO" forKey:@"boolean-value"];
            break;
        }
      } else {
        /* warning: *-value not supported */
      }
    }
  }
  return [node attributeCount] > 0 ? node : nil;
}

- (NSString *)xmlElementName {
  return @"cocoa";
}

#pragma mark Parsing
- (void)sd_setXMLValue:(NSDictionary *)attrs {
  NSString *attr;
  if (attr = [attrs objectForKey:@"boolean-value"]) {
    [self setValueType:kSdefValueTypeBoolean];
    [self setBooleanValue:[attr caseInsensitiveCompare:@"YES"] == 0];
  } else if (attr = [attrs objectForKey:@"integer-value"]) {
    [self setValueType:kSdefValueTypeInteger];
    [self setIntegerValue:SKIntegerValue(attr)];
  } else if (attr = [attrs objectForKey:@"string-value"]) {
    [self setValueType:kSdefValueTypeString];
    [self setTextValue:[attr stringByUnescapingEntities:nil]];
  }
}

- (void)setXMLMetas:(NSDictionary *)metas {
  [self sd_setXMLValue:metas];
  [super setXMLMetas:metas];
}

- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  [self setKey:[[attrs objectForKey:@"key"] stringByUnescapingEntities:nil]];
  [self setName:[[attrs objectForKey:@"name"] stringByUnescapingEntities:nil]];
  [self setMethod:[[attrs objectForKey:@"method"] stringByUnescapingEntities:nil]];
  [self setSdClass:[[attrs objectForKey:@"class"] stringByUnescapingEntities:nil]];
  
  [self sd_setXMLValue:attrs];
}

@end
