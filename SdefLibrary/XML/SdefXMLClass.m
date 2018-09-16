/*
 *  SdefXMLClass.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"

#import "SdefImplementation.h"
#import "SdefClassManager.h"
#import "SdefContents.h"
#import "SdefClass.h"

static
uint32_t SdefXMLAccessorFlagFromString(NSString *str);
static
NSArray *SdefXMLAccessorStringsFromFlag(NSUInteger flag);

#pragma mark -
@implementation SdefClass (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self isExtension]) {
    if ([self inherits] && (node = [super xmlNodeForVersion:version])) {
      if (version >=  /* kSdefTigerVersion */ kSdefLeopardVersion) {
        [node removeAttributeForKey:@"name"];
        [node removeAttributeForKey:@"code"];
        [node setAttribute:[[self inherits] stringByEscapingEntities:nil] forKey:@"extends"];
      } else {
        [node setElementName:@"class"];
        [node setMeta:@"YES" forKey:@"class-extension"];
        [node setAttribute:[[self inherits] stringByEscapingEntities:nil] forKey:@"name"];
        [node setAttribute:[[self inherits] stringByEscapingEntities:nil] forKey:@"inherits"];
        if (![self code] && [self inherits]) {
          SdefClass *parent = [[self classManager] classWithName:[self inherits]];
          if (parent) {
            NSString *code = [parent code];
            if (code)
              [node setAttribute:code forKey:@"code"];
            if (![self impl]) {
              SdefXMLNode *impl = [[parent impl] xmlNodeForVersion:version];
              if (impl)
                [node prependChild:impl];
            }
          }
        }
      }
    }
  } else if ((node = [super xmlNodeForVersion:version])) {
    if ([self plural]) [node setAttribute:[[self plural] stringByEscapingEntities:nil] forKey:@"plural"];
    if ([self inherits]) [node setAttribute:[[self inherits] stringByEscapingEntities:nil] forKey:@"inherits"];
  }
  
  /* undocumented type */
  if ([self type]) {
    SdefXMLNode *type = [SdefXMLNode nodeWithElementName:@"type"];
    [type setAttribute:[[self type] stringByEscapingEntities:nil] forKey:@"type"];
    [node appendChild:type];
  }
  
  /* contents */
  if (_contents) {
    SdefXMLNode *contents = [_contents xmlNodeForVersion:version];
    if (contents) {
      if ([[[node firstChild] elementName] isEqualToString:@"documentation"]) {
        [node insertChild:contents atIndex:1];
      } else {
        [node prependChild:contents];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return [self isExtension] ? @"class-extension" : @"class";
}

#pragma mark Parsing

- (void)setXMLMetas:(NSDictionary *)metas {
  NSString *ext = [metas objectForKey:@"class-extension"];
  if (ext && [ext isEqualToString:@"YES"]) {
    [self setInherits:[self name]];
    [self setExtension:YES];
    [self setCode:nil];
  }
  [super setXMLMetas:metas];
}

- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  if ([attrs objectForKey:@"extends"]) {
    [self setInherits:[[attrs objectForKey:@"extends"] stringByUnescapingEntities:nil]];
  } else {
    [self setPlural:[[attrs objectForKey:@"plural"] stringByUnescapingEntities:nil]];
    [self setInherits:[[attrs objectForKey:@"inherits"] stringByUnescapingEntities:nil]];
  }
}

- (void)addXMLChild:(id<SdefObject>)child {
  switch ([child objectType]) {
    case kSdefType_Contents:
      [self setContents:(SdefContents *)child];
      break;
    case kSdefType_Property:
      [[self properties] appendChild:(SdefProperty *)child];
      break;
    case kSdefType_Element:
      [[self elements] appendChild:(SdefElement *)child];
      break;
    case kSdefType_RespondsTo:
      [[self commands] appendChild:(SdefRespondsTo *)child];
      break;
      /* Undocumented type element support */
    case kSdefType_Type:
      [self setType:[child name]];
      break;
    default:
      [super addXMLChild:child];
      break;
  }
}

@end

#pragma mark -
@implementation SdefContents (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    if (![self name]) [node setAttribute:@"contents" forKey:@"name"];
    
    NSString *attr = SdefXMLAccessStringFromFlag([self access]);
    if (attr) [node setAttribute:attr forKey:@"access"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"contents";
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
}

@end

#pragma mark -
@implementation SdefElement (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = [super xmlNodeForVersion:version];
  if (node) {
    [node removeAttributeForKey:@"name"];
    NSString *attr = [self name];
    if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"type"];
    
    attr = SdefXMLAccessStringFromFlag([self access]);
    if (attr) [node setAttribute:attr forKey:@"access"];
    
    /* Accessors */
    NSArray *accessors = SdefXMLAccessorStringsFromFlag([self accessors]);
    NSUInteger idx = [accessors count];
    while (idx-- > 0) {
      SdefXMLNode *accNode = [SdefXMLNode nodeWithElementName:@"accessor"];
      [accNode setAttribute:[accessors objectAtIndex:idx] forKey:@"style"];
      [node appendChild:accNode];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"element";
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  
  [self setName:[[attrs objectForKey:@"type"] stringByUnescapingEntities:nil]];
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
}

- (void)addXMLAccessor:(NSString *)style {
  if (style)
    [self setAccessors:[self accessors] | SdefXMLAccessorFlagFromString(style)];
}

@end

#pragma mark -
@implementation SdefProperty (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = [super xmlNodeForVersion:version];
  if (node) {
    NSString *attr = SdefXMLAccessStringFromFlag([self access]);
    if (attr) [node setAttribute:attr forKey:@"access"];
    
    if ([self isNotInProperties]) {
      if (version >= kSdefTigerVersion) {
        [node setAttribute:@"no" forKey:@"in-properties"];
      } else {
        [node setAttribute:@"not-in-properties" forKey:@"not-in-properties"];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"property";
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
  if ([[attrs objectForKey:@"in-properties"] isEqualToString:@"no"] ||
      ([attrs objectForKey:@"not-in-properties"])) {
    [self setNotInProperties:YES];
  }
}

@end

#pragma mark -
@implementation SdefRespondsTo (SdefXMLManager)

#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self name] && (node = [super xmlNodeForVersion:version])) {
    NSString *key = @"name";
    if (version >= kSdefLeopardVersion)
      key = @"command";
    [node setAttribute:[[self name] stringByEscapingEntities:nil] forKey:key];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"responds-to";
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  
  NSString *cmd = [attrs objectForKey:@"command"];
  if (cmd)
    [super setName:[cmd stringByUnescapingEntities:nil]];
}

@end

NSArray *SdefXMLAccessorStringsFromFlag(NSUInteger flag) {
  NSMutableArray *strings = [NSMutableArray array];
  if (flag & kSdefAccessorIndex) [strings addObject:@"index"];
  if (flag & kSdefAccessorID) [strings addObject:@"id"];
  if (flag & kSdefAccessorName) [strings addObject:@"name"];
  if (flag & kSdefAccessorRange) [strings addObject:@"range"];
  if (flag & kSdefAccessorRelative) [strings addObject:@"relative"];
  if (flag & kSdefAccessorTest) [strings addObject:@"test"];
  return strings;
}

uint32_t SdefXMLAccessorFlagFromString(NSString *str) {
  uint32_t flag = 0;
  if (str && [str rangeOfString:@"index"].location != NSNotFound) {
    flag |= kSdefAccessorIndex;
  } else if (str && [str rangeOfString:@"name"].location != NSNotFound) {
    flag |= kSdefAccessorName;
  } else if (str && [str rangeOfString:@"id"].location != NSNotFound) {
    flag |= kSdefAccessorID;
  } else if (str && [str rangeOfString:@"range"].location != NSNotFound) {
    flag |= kSdefAccessorRange;
  } else if (str && [str rangeOfString:@"relative"].location != NSNotFound) {
    flag |= kSdefAccessorRelative;
  } else if (str && [str rangeOfString:@"test"].location != NSNotFound) {
    flag |= kSdefAccessorTest;
  }
  return flag;
}
