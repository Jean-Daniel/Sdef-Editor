/*
 *  SdefXMLClass.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"

#import "SdefClassManager.h"
#import "SdefContents.h"
#import "SdefClass.h"

static
NSString *SdefXMLAccessStringFromFlag(NSUInteger flag);
static
NSUInteger SdefXMLAccessFlagFromString(NSString *str);

static
NSUInteger SdefXMLAccessorFlagFromString(NSString *str);
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
  if (sd_contents) {
    SdefXMLNode *contents = [sd_contents xmlNodeForVersion:version];
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
    case kSdefContentsType:
      [self setContents:(SdefContents *)child];
      break;
    case kSdefPropertyType:
      [[self properties] appendChild:(SdefProperty *)child];
      break;
    case kSdefElementType:
      [[self elements] appendChild:(SdefElement *)child];
      break;
    case kSdefRespondsToType:
      [[self commands] appendChild:(SdefRespondsTo *)child];
      break;
      /* Undocumented type element support */
    case kSdefTypeAtomType:
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

NSString *SdefXMLAccessStringFromFlag(NSUInteger flag) {
  id str = nil;
  if (flag == (kSdefAccessRead | kSdefAccessWrite)) str = @"rw";
  else if (flag == kSdefAccessRead) str = @"r";
  else if (flag == kSdefAccessWrite) str = @"w";
  return str;
}

NSUInteger SdefXMLAccessFlagFromString(NSString *str) {
  NSUInteger flag = 0;
  if (str && [str rangeOfString:@"r"].location != NSNotFound) {
    flag |= kSdefAccessRead;
  }
  if (str && [str rangeOfString:@"w"].location != NSNotFound) {
    flag |= kSdefAccessWrite;
  }
  return flag;
}

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

NSUInteger SdefXMLAccessorFlagFromString(NSString *str) {
  NSUInteger flag = 0;
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
