//
//  SdefDocument.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocument.h"

#import "ShadowMacros.h"

#import "SdefWindowController.h"
#import "SdefClassManager.h"
#import "SdefDictionary.h"
#import "SdefObject.h"
#import "SdefSuite.h"

#import "SdefParser.h"
#import "SdefXMLGenerator.h"

@implementation SdefDocument

- (id)init {
  if (self = [super init]) {
    dictionary = [[SdefDictionary alloc] init];
    [dictionary appendChild:[SdefSuite node]];
    _imports = [[SdefImports alloc] init];
    _manager = [[SdefClassManager alloc] initWithDocument:self];
    [[NSNotificationCenter defaultCenter] addObserver:_manager
                                             selector:@selector(didAddDictionary:)
                                                 name:@"SDTreeNodeDidAppendNodeNotification"
                                               object:_imports];
    [[NSNotificationCenter defaultCenter] addObserver:_manager
                                             selector:@selector(willRemoveDictionary:)
                                                 name:@"SDTreeNodeWillRemoveNodeNotification"
                                               object:_imports];
  }
  return self;
}

- (void)dealloc {
  [dictionary release];
  [_imports release];
  [_manager release];
  [super dealloc];
}

- (void)awakeFromNib {
//  [outline setIndentationPerLevel:10];
}

- (void)makeWindowControllers {
  id controller = [[SdefWindowController alloc] initWithOwner:nil];
  [self addWindowController:controller];
  [controller release];
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
  SdefXMLGenerator *gen = [[SdefXMLGenerator alloc] initWithRoot:[self dictionary]];
  id data = [gen xmlData];
  [gen release];
  return data;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
  id parser = [[SdefParser alloc] init];
  BOOL result = [parser parseData:data];
  [self setDictionary:[parser document]];
  [parser release];
  return result;
}

- (SdefDictionary *)dictionary {
  return dictionary;
}

- (void)setDictionary:(SdefDictionary *)newDictionary {
  if (dictionary != newDictionary) {
    [dictionary release];
    dictionary = [newDictionary retain];
  }
}

- (SdefImports *)imports {
  return _imports;
}

#pragma mark -

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return (nil == item) ? YES : [item firstChild] != nil;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  return (nil == item) ? 2 : [item childCount];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
  if (nil == item) {
    return (index == 0) ? (id)_imports : (id)dictionary;
  }
  return [item childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return item;
}

@end
