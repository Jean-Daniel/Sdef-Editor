//
//  SdefClass.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

/*
 <!-- CLASS DEFINITION -->
 <!ELEMENT class (documentation?, %implementation;?, synonyms?, contents?, elements?, properties?, responds-to-commands?, responds-to-events?)>
 <!ATTLIST class
 name       %Classname;     #REQUIRED
 code       %OSType;        #IMPLIED 
 hidden     (hidden)        #IMPLIED 
 plural     %Classname;     #IMPLIED 
 inherits   %Classname;     #IMPLIED 
 description  %Text;        #IMPLIED 
 >
 
 <!-- contents -->
 <!ELEMENT contents (%implementation;?)>
 <!ATTLIST contents
 name       %Classname;     #IMPLIED
 code       %OSType;        #IMPLIED 
 type       %Classname;     #REQUIRED
 access     (r | w | rw)    "rw"     
 hidden     (hidden)        #IMPLIED 
 description  %Text;        #IMPLIED 
 >
 
 <!-- element access -->
 <!ELEMENT elements (element+)>
 <!ELEMENT element (%implementation;?, accessor*)>
 <!ATTLIST element
 type       %Classname;     #REQUIRED
 access     (r | w | rw)    "rw"     
 hidden     (hidden)        #IMPLIED 
 description  %Text;        #IMPLIED 
 >
 
 <!ENTITY % accessor-type "(index | name | id | range | relative | test)">
 <!ELEMENT accessor EMPTY>
 <!ATTLIST accessor
 style      %accessor-type;  #REQUIRED
 >
 
 <!-- properties -->
 <!ELEMENT properties (property+)>
 <!ELEMENT property (documentation?, %implementation;?, synonyms?)>
 <!ATTLIST property
 name       %Term;          #REQUIRED
 code       %OSType;        #IMPLIED 
 hidden     (hidden)        #IMPLIED 
 type       %Typename;      #REQUIRED 
 access     (r | w | rw)    "rw"     
 not-in-properties  (not-in-properties)  #IMPLIED 
 description  %Text;        #IMPLIED 
 >
 
 <!-- supported verbs -->
 <!ELEMENT responds-to-commands (responds-to+)>
 <!ELEMENT responds-to-events (responds-to+)>
 <!ELEMENT responds-to (%implementation;?)>
 <!ATTLIST responds-to
 name       %Verbname;      #REQUIRED
 hidden     (hidden)        #IMPLIED 
 >
*/

enum {
  kSdefAccessRead = 1 << 0,
  kSdefAccessWrite = 1 << 1,
};

enum {
  kSdefAccessorIndex = 1 << 0,
  kSdefAccessorName = 1 << 1,
  kSdefAccessorID = 1 << 2,
  kSdefAccessorRange = 1 << 3,
  kSdefAccessorRelative = 1 << 4,
  kSdefAccessorTest = 1 << 5
};

extern NSString *SDAccessStringFromFlag(unsigned flag);
extern unsigned SDAccessFlagFromString(NSString *str);

/* class, property, and contents */
@class SdefDocumentation, SdefContents;
@interface SdefClass : SdefTerminologyElement <NSCopying, NSCoding> {
  SdefContents *sd_contents;
  /* Attributes */
  NSString *sd_plural; 
  NSString *sd_inherits;
}

- (SdefContents *)contents;
- (void)setContents:(SdefContents *)contents;

- (SdefCollection *)properties;
- (SdefCollection *)elements;
- (SdefCollection *)commands;
- (SdefCollection *)events;

- (NSString *)plural;
- (void)setPlural:(NSString *)newPlural;

- (NSString *)inherits;
- (void)setInherits:(NSString *)newInherits;


@end

@interface SdefElement : SdefTerminologyElement <NSCopying, NSCoding> {
  unsigned int sd_accessors; /* index | name | id | range | relative | test */
  
  /* Attributs */
  unsigned sd_access; /* ( kSdefAccessRead | kSdefAccessWrite ) */
}

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (unsigned)access;
- (void)setAccess:(unsigned)newAccess;

- (unsigned)accessors;
- (void)setAccessors:(unsigned)accessors;

@end

@interface SdefProperty : SdefTerminologyElement <NSCopying, NSCoding> {
  NSString *sd_type;
  unsigned sd_access;
  BOOL sd_notInProperties; 
}

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (unsigned)access;
- (void)setAccess:(unsigned)newAccess;

- (BOOL)isNotInProperties;
- (void)setNotInProperties:(BOOL)flag;

@end

@interface SdefRespondsTo : SdefTerminologyElement <NSCopying, NSCoding> {
}

@end