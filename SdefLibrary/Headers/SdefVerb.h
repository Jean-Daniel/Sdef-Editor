/*
 *  SdefVerb.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
 <!-- VERBS (COMMANDS OR EVENTS) -->
 <!ELEMENT command ((%implementation;)?, access-group*, synonym*, direct-parameter?, parameter*, result?, documentation*, xref*)>
 <!ATTLIST command
 %common.attrib;
 name       %Verbname;      #REQUIRED
 id         ID              #IMPLIED
 code       %EventCode;     #REQUIRED
 description  %Text;        #IMPLIED
 hidden     %yorn;          #IMPLIED
 >

 <!ELEMENT event ((%implementation;)?, synonym*, documentation*, direct-parameter?, (documentation | parameter)*, result?, documentation*, xref*)>
 <!ATTLIST event
 %common.attrib;
 name       %Verbname;      #REQUIRED
 id         ID              #IMPLIED
 code       %EventCode;     #REQUIRED
 description  %Text;        #IMPLIED
 hidden     %yorn;          #IMPLIED
 >

 <!ELEMENT direct-parameter (type*)>
 <!ATTLIST direct-parameter
 %common.attrib;
 type       %Typename;      #IMPLIED
 optional   %yorn;          #IMPLIED
 requires-access %rw;       #IMPLIED
 description  %Text;        #IMPLIED
 >

 <!ELEMENT result (type*)>
 <!ATTLIST result
 %common.attrib;
 type       %Typename;      #IMPLIED
 description  %Text;        #IMPLIED
 >

 <!ELEMENT parameter ((%implementation;)?, (type*))>
 <!ATTLIST parameter
 %common.attrib;
 name       %Term;          #REQUIRED
 code       %OSType;        #REQUIRED
 hidden     %yorn;          #IMPLIED
 type       %Typename;      #IMPLIED
 optional   %yorn;          #IMPLIED
 requires-access %rw;       #IMPLIED
 description  %Text;        #IMPLIED
 >
 */

@class SdefDocumentation, SdefDirectParameter, SdefResult;
@interface SdefVerb : SdefTerminologyObject <NSCopying, NSCoding> {
  @private
  SdefResult *_result;
  SdefDirectParameter *_direct;
  // Code into verb are split into class & ID that are two concat four char codes (i.e. eavtquit).
}

/* -isCommand may returns something different that what was set by setComment: */
@property(nonatomic, getter = isCommand) BOOL command;

- (BOOL)hasResult;
@property(nonatomic, retain) SdefResult *result;

- (BOOL)hasDirectParameter;
@property(nonatomic, retain) SdefDirectParameter *directParameter;

@end
