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
<!ENTITY % class-contents "(contents | documentation | element | property | responds-to | synonym | xref)">
<!ELEMENT class ((%implementation;)?, (%class-contents;)*)>
<!-- not quite accurate; there can be at most one contents element. -->
<!ATTLIST class
name       %Term;          #REQUIRED
id         ID              #IMPLIED
code       %OSType;        #REQUIRED 
hidden     %yorn;          #IMPLIED 
plural     %Term;          #IMPLIED 
inherits   %Classname;     #IMPLIED 
description  %Text;        #IMPLIED 
>

<!-- contents -->
<!ELEMENT contents ((%implementation;)?, (type*))>
<!ATTLIST contents
name       %Term;          #IMPLIED
code       %OSType;        #IMPLIED 
type       %Typename;      #IMPLIED
access     (r | w | rw)    "rw"     
hidden     %yorn;          #IMPLIED 
description  %Text;        #IMPLIED 
>

<!-- element access -->
<!ELEMENT element ((%implementation;)?, accessor*)>
<!ATTLIST element
type       %Typename;      #REQUIRED
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
command    %Verbname;      #REQUIRED
hidden     %yorn;          #IMPLIED 

name       %Verbname;      #IMPLIED
>
<!-- "name" is now "command"; "name" is still defined for backward compatibility. -->

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
  @private
  SdefContents *sd_contents;
  BOOL sd_extension;
  /* Attributes */
  NSString *sd_id;
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

- (NSString *)xmlid;
- (void)setXmlid:(NSString *)anId;

- (NSString *)plural;
- (void)setPlural:(NSString *)newPlural;

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (NSString *)inherits;
- (void)setInherits:(NSString *)newInherits;

- (BOOL)isExtension;
- (void)setExtension:(BOOL)extension;

@end

@interface SdefElement : SdefTerminologyObject <NSCopying, NSCoding> {
  NSUInteger sd_accessors; /* index | name | id | range | relative | test */
  
  /* Attributs */
  NSUInteger sd_access; /* ( kSdefAccessRead | kSdefAccessWrite ) */
}

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (NSUInteger)access;
- (void)setAccess:(NSUInteger)newAccess;

- (NSUInteger)accessors;
- (void)setAccessors:(NSUInteger)accessors;

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
  NSUInteger sd_access;
}

- (NSUInteger)access;
- (void)setAccess:(NSUInteger)newAccess;

- (BOOL)isNotInProperties;
- (void)setNotInProperties:(BOOL)flag;

@end

@interface SdefRespondsTo : SdefImplementedObject <NSCopying, NSCoding> {
}

@end
