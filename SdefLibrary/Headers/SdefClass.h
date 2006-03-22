/*
 *  SdefClass.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
<!-- CLASSES -->
<!ENTITY % class-contents "(contents | documentation | element | property | responds-to | synonym)">
<!ELEMENT class ((%implementation;)?, (%class-contents;)*)>
  <!-- not quite accurate; there can be at most one contents element. -->
<!ATTLIST class
name       %Classname;     #REQUIRED
code       %OSType;        #REQUIRED 
hidden     %yorn;          #IMPLIED 
plural     %Classname;     #IMPLIED 
inherits   %Classname;     #IMPLIED 
description  %Text;        #IMPLIED 
>

<!-- element access -->
<!ELEMENT element ((%implementation;)?, accessor*)>
<!ATTLIST element
type       %Classname;     #REQUIRED
access     (r | w | rw)    "rw"     
hidden     %yorn;          #IMPLIED 
description  %Text;        #IMPLIED 
>

<!ENTITY % accessor-type "(index | name | id | range | relative | test)">
<!ELEMENT accessor EMPTY>
<!ATTLIST accessor
style      %accessor-type;  #REQUIRED
>

<!-- properties -->
<!ELEMENT property ((%implementation;)?, (type | synonym | documentation)*)>
<!ATTLIST property
name       %Term;          #REQUIRED
code       %OSType;        #REQUIRED 
hidden     %yorn;          #IMPLIED 
type       %Typename;      #IMPLIED 
access     (r | w | rw)    "rw"     
in-properties  %yorn;      #IMPLIED 
description  %Text;        #IMPLIED 
>

<!-- supported verbs -->
<!ELEMENT responds-to ((%implementation;)?)>
<!ATTLIST responds-to
name       %Verbname;      #REQUIRED
hidden     %yorn;          #IMPLIED 
>

<!-- class extensions -->
<!ELEMENT class-extension ((%implementation;)?, (%class-contents;)*)>
<!ATTLIST class-extension
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
  SdefContents *sd_contents;
  /* Attributes */
  NSString *sd_type;
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

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (NSString *)inherits;
- (void)setInherits:(NSString *)newInherits;


@end

@interface SdefElement : SdefTerminologyObject <NSCopying, NSCoding> {
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
@interface SdefProperty : SdefTypedObject <NSCopying, NSCoding> {
  unsigned sd_access;
}

- (unsigned)access;
- (void)setAccess:(unsigned)newAccess;

- (BOOL)isNotInProperties;
- (void)setNotInProperties:(BOOL)flag;

@end

@interface SdefRespondsTo : SdefImplementedObject <NSCopying, NSCoding> {
}

@end