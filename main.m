//
//  main.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright Shadow Lab 2005 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSDebug.h>

int main(int argc, char *argv[]) {
  NSDebugEnabled = YES;
  NSHangOnUncaughtException = YES;
  return NSApplicationMain(argc, (const char **) argv);
}
