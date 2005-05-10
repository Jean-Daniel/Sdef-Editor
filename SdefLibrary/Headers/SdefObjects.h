//
//  SdefObject.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

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
@interface SdefTerminologyObject : SdefImplementedObject <NSCopying, NSCoding> {
@private
  NSString *sd_code; 
  NSString *sd_desc;
  SdefCollection *sd_synonyms;
}

- (NSString *)codeStr;
- (void)setCodeStr:(NSString *)str;

- (NSString *)desc;
- (void)setDesc:(NSString *)newDesc;

@end

#pragma mark -
@class SdefType;
@interface SdefTypedObject : SdefTerminologyObject <NSCopying, NSCoding> {
@private
  id sd_types;
}

- (BOOL)hasType;
- (NSString *)type;
- (void)setType:(NSString *)aType;

@end

#pragma mark -
@interface SdefTypedOrphanObject : SdefTypedObject <NSCopying, NSCoding> {
@private
  SdefObject *sd_owner;
}

- (id)owner;
- (void)setOwner:(SdefObject *)anObject;

@end