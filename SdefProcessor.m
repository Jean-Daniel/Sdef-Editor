/*
 *  SdefProcessor.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefProcessor.h"
#import "SdefEditor.h"

@implementation SdefProcessor

- (id)initWithInput:(id)input {
  if (self = [super init]) {
    [self setInput:input];
  }
  return self;
}

- (id)initWithFile:(NSString *)aSdefFile {
  return [self initWithInput:aSdefFile];
}

- (id)initWithSdefDocument:(SdefDocument *)aDocument {
  return [self initWithInput:aDocument];
}

- (void)dealloc {
  [sd_input release];
  [sd_output release];
  [sd_version release];
  [sd_includes release];
  [super dealloc];
}

#pragma mark -
- (NSString *)process {
  NSFileHandle *input = nil;
  
  if (!sd_input) {
    [NSException raise:NSInternalInconsistencyException format:@"input cannot be nil."];
  }
  if (!sd_output || ![[NSFileManager defaultManager] fileExistsAtPath:sd_output]) {
    [NSException raise:NSInternalInconsistencyException format:@"ouptut cannot be nil."];
  }
  if (sd_format == kSdefUndefinedFormat) {
    [NSException raise:NSInternalInconsistencyException format:@"Undefined output format."];
  }
  
  NSTask *task = [[NSTask alloc] init];
  sd_msg = [[NSMutableString alloc] init];
  // The output of stdout and stderr is sent to a pipe so that we can catch it later
  // and send it along to the controller; notice that we don't bother to do anything with stdin,
  // so this class isn't as useful for a task that you need to send info to, not just receive.
  [task setStandardOutput:[NSPipe pipe]];
  [task setStandardError:[task standardOutput]];
  
  // The path to the binary is the first argument that was passed in
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SdefBuildInSdp"])
    [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"sdp" ofType:@""]];
  else {
    [task setLaunchPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"SdefSdpToolPath"]];
  }
  
  NSMutableArray *args = [[NSMutableArray alloc] init];
  
  /* Set format */
  NSMutableString *format = [NSMutableString stringWithCapacity:3];
  if (sd_format & kSdefResourceFormat) {
    [format appendString:@"a"];
  }
  if (sd_format & kSdefScriptSuiteFormat) {
    [format appendString:@"s"];
  }
  if (sd_format & kSdefScriptTerminologyFormat) {
    [format appendString:@"t"];
  }
  [args addObject:@"-f"];
  [args addObject:format];
  
  /* Set Output */
  [args addObject:@"-o"];
  [args addObject:sd_output];
  
  /* Set Includes */
  if ([sd_includes count] > 0) {
    for (NSUInteger idx = 0; idx < [sd_includes count]; idx++) {
      [args addObject:@"-i"];
      [args addObject:[sd_includes objectAtIndex:idx]];
    }
  }
  
  /* Set version */
  if ([self version]) {
    [args addObject:@"-V"];
    [args addObject:[self version]];
  }
  
  /* Set input */
  if ([sd_input isKindOfClass:[NSString class]]) {
    [args addObject:sd_input];
  } else {
    [task setStandardInput:[NSPipe pipe]];
    input = [[task standardInput] fileHandleForWriting];
  }
  
  [task setArguments:args];
  [args release];
  
  // Here we register as an observer of the NSFileHandleReadCompletionNotification, which lets
  // us know when there is data waiting for us to grab it in the task's file handle (the pipe
  // to which we connected stdout and stderr above).  -getData: will be called when there
  // is data waiting.  The reason we need to do this is because if the file handle gets
  // filled up, the task will block waiting to send data and we'll never get anywhere.
  // So we have to keep reading data from the file handle as we go.
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(getData:) 
                                               name: NSFileHandleReadCompletionNotification 
                                             object: [[task standardOutput] fileHandleForReading]];
  // We tell the file handle to go ahead and read in the background asynchronously, and notify
  // us via the callback registered above when we signed up as an observer.  The file handle will
  // send a NSFileHandleReadCompletionNotification when it has data that is available.
  [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
  
  // launch the task asynchronously
  [task launch];
  
  if (input) {
    NSError *error = nil;
    NSData *data = [sd_input dataOfType:ScriptingDefinitionFileType error:&error];
    if (data) {
      @try {
        [input writeData:data];
      } @catch (id exception) {
        SKLogException(exception);
      }
    }
    [input closeFile];
  }
  [task waitUntilExit];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];
  
  NSData *data;
  while ((data = [[[task standardOutput] fileHandleForReading] availableData]) && [data length]) {
    [sd_msg appendString:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
  }
  
  [task release];
  
  [sd_msg autorelease];
  NSString *result = [sd_msg length] ? sd_msg : nil;
  sd_msg = nil;
  return result;
}

// This method is called asynchronously when data is available from the task's file handle.
// We just pass the data along to the controller as an NSString.
- (void)getData:(NSNotification *)aNotification {
  NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
  if ([data length]) {
    [sd_msg appendString:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
  }
  // we need to schedule the file handle go read more data in the background again.
  [[aNotification object] readInBackgroundAndNotify];  
}

#pragma mark -

- (id)input {
  return sd_input;
}
- (void)setInput:(id)input {
  if (sd_input != input) {
    [sd_input release];
    sd_input = [input retain];
  }
}

- (NSString *)output {
  return sd_output;
}
- (void)setOutput:(NSString *)output {
  if (sd_output != output) {
    [sd_output release];
    sd_output = [output copy];
  }
}

- (NSString *)version {
  return sd_version;
}
- (void)setVersion:(NSString *)aVersion {
  if (sd_version != aVersion) {
    [sd_version release];
    sd_version = [aVersion copy];
  }
}

- (NSArray *)includes {
  return sd_includes;
}
- (void)setIncludes:(NSArray *)includes {
  if (sd_includes != includes) {
    [sd_includes release];
    sd_includes = [includes copy];
  }
}

- (SdefProcessorFormat)format {
  return sd_format;
}
- (void)setFormat:(SdefProcessorFormat)aFormat {
  sd_format = aFormat;
}

@end
