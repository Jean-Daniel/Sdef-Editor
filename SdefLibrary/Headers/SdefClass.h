/*
 *  SdefClass.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
 <!-- CLASSES -->
 <!ENTITY % class-contents "(contents | documentation | element | property | responds-to | synonym | xref)">
 <!ELEMENT class ((%implementation;)?, access-group*, (%class-contents;)*)>
 <!-- not quite accurate; there can be at most one contents element. -->
 <!ATTLIST class
 %common.attrib;
 name       %Term;          #REQUIRED
 id         ID              #IMPLIED
 code       %OSType;        #REQUIRED
 hidden     %yorn;          #IMPLIED
 plural     %Term;          #IMPLIED
 inherits   %Classname;     #IMPLIED
 description  %Text;        #IMPLIED
 >

 <!-- element access -->
 <!ELEMENT element ((%implementation;)?, access-group*, accessor*)>
 <!ATTLIST element
 %common.attrib;
 type       %Typename;      #REQUIRED
 access     %rw;            #IMPLIED
 hidden     %yorn;          #IMPLIED
 description  %Text;        #IMPLIED
 >

 <!ENTITY % accessor-type "(index | name | id | range | relative | test)">
 <!ELEMENT accessor EMPTY>
 <!ATTLIST accessor
 %common.attrib;
 style      %accessor-type;  #REQUIRED
 >

 <!-- properties -->
 <!ELEMENT property ((%implementation;)?, access-group*, (type | synonym | documentation)*)>
 <!ATTLIST property
 %common.attrib;
 name       %Term;          #REQUIRED
 code       %OSType;        #REQUIRED
 hidden     %yorn;          #IMPLIED
 type       %Typename;      #IMPLIED
 access     %rw;            #IMPLIED
 in-properties  %yorn;      #IMPLIED
 description  %Text;        #IMPLIED
 >

 <!-- supported verbs -->
 <!ELEMENT responds-to ((%implementation;)?, access-group*)>
 <!ATTLIST responds-to
 %common.attrib;
 command    %Verbname;      #REQUIRED
 hidden     %yorn;          #IMPLIED

 name       %Verbname;      #IMPLIED
 >
 <!-- "name" is now "command"; "name" is still defined for backward compatibility. -->

 <!-- class extensions -->
 <!ELEMENT class-extension ((%implementation;)?, access-group*, (%class-contents;)*)>
 <!ATTLIST class-extension
 %common.attrib;
 id         ID              #IMPLIED
 extends    %Classname;     #REQUIRED
 hidden     %yorn;          #IMPLIED
 description  %Text;        #IMPLIED
 >
 
*/

enum {
  kSdefAccessRead = 1 << 0,
  kSdefAccessWrite = 1 << 1,
};

enum {
  kSdefAccessorIndex 	= 1 << 0,
  kSdefAccessorName 	= 1 << 1,
  kSdefAccessorID 		= 1 << 2,
  kSdefAccessorRange 	= 1 << 3,
  kSdefAccessorRelative = 1 << 4,
  kSdefAccessorTest 	= 1 << 5
};

/* class, property, and contents */
@class SdefDocumentation, SdefContents;
@interface SdefClass : SdefTerminologyObject <NSCopying, NSCoding> {
@private
  NSString *_type;
  NSString *_inherits;
  SdefContents *_contents;
}

@property(nonatomic, retain) SdefContents *contents;

- (SdefCollection *)properties;
- (SdefCollection *)elements;
- (SdefCollection *)commands;
- (SdefCollection *)events;

@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *plural;
@property(nonatomic, copy) NSString *inherits;

@property(nonatomic, getter = isExtension) BOOL extension;

@end

@interface SdefElement : SdefTerminologyObject <NSCopying, NSCoding>

@property(nonatomic, copy) NSString *type;

@property(nonatomic) uint32_t access; /* ( kSdefAccessRead | kSdefAccessWrite ) */
@property(nonatomic) uint32_t accessors; /* index | name | id | range | relative | test */

#pragma mark Accessors
- (BOOL)accIndex;
- (void)setAccIndex:(BOOL)flag;

- (BOOL)accId;
- (void)setAccId:(BOOL)flag;

- (BOOL)accName;
- (void)setAccName:(BOOL)flag;

- (BOOL)accRange;
- (void)setAccRange:(BOOL)flag;

- (BOOL)accRelative;
- (void)setAccRelative:(BOOL)flag;

- (BOOL)accTest;
- (void)setAccTest:(BOOL)flag;

@end

#pragma mark -
@interface SdefProperty : SdefTypedObject <NSCopying, NSCoding>

@property(nonatomic) uint32_t access;

@property(nonatomic, getter = isNotInProperties) BOOL notInProperties;

@end

@interface SdefRespondsTo : SdefImplementedObject <NSCopying, NSCoding> {
}

@end
