/*
 *  SdefObject.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

@interface SdefDocumentedObject : SdefObject <NSCopying, NSCoding> {
@private
  SdefDocumentation *sd_documentation;
}

@end

#pragma mark -
@interface SdefImplementedObject : SdefDocumentedObject <NSCopying, NSCoding> {
@private
  SdefImplementation *sd_impl;
}

- (NSString *)cocoaKey;
- (NSString *)cocoaName;
- (NSString *)cocoaClass;
- (NSString *)cocoaMethod;

@end

#pragma mark -
@class SdefSynonym;
@interface SdefTerminologyObject : SdefImplementedObject <NSCopying, NSCoding> {
@private
  NSString *sd_code; 
  NSString *sd_desc;
  NSMutableArray *sd_synonyms;
}

- (NSString *)code;
- (void)setCode:(NSString *)str;

- (NSString *)desc;
- (void)setDesc:(NSString *)newDesc;

#pragma mark Synonyms KVC
- (unsigned)countOfSynonyms;
- (NSArray *)synonyms;
- (void)setSynonyms:(NSArray *)synonyms;
- (void)addSynonym:(SdefSynonym *)aSynonym;
- (id)objectInSynonymsAtIndex:(unsigned)index;
- (void)insertObject:(id)object inSynonymsAtIndex:(unsigned)index;
- (void)removeObjectFromSynonymsAtIndex:(unsigned)index;
- (void)replaceObjectInSynonymsAtIndex:(unsigned)index withObject:(id)object;

@end

#pragma mark -
@class SdefType;
@interface SdefTypedObject : SdefTerminologyObject <NSCopying, NSCoding> {
@private
  NSMutableArray *sd_types;
}

/* Simple Type */
- (BOOL)hasType;
- (NSString *)type;
- (void)setType:(NSString *)aType;

/* Complex Type */
- (BOOL)hasCustomType;

- (NSArray *)types;
- (unsigned)countOfTypes;
- (void)addType:(SdefType *)aType;
- (void)setTypes:(NSArray *)objects;
- (id)objectInTypesAtIndex:(unsigned)index;
- (void)removeObjectFromTypesAtIndex:(unsigned)index;
- (void)insertObject:(id)object inTypesAtIndex:(unsigned)index;
- (void)replaceObjectInTypesAtIndex:(unsigned)index withObject:(id)object;

@end

extern NSArray *SdefTypesForTypeString(NSString *type);
extern NSString *SdefTypeStringForTypes(NSArray *types);

#pragma mark -
@interface SdefTypedOrphanObject : SdefTypedObject <NSCopying, NSCoding> {
@private
  SdefObject *sd_owner;
}

- (id)owner;
- (void)setOwner:(SdefObject *)anObject;

@end
