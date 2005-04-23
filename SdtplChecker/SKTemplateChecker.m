#import <Foundation/Foundation.h>
#import "SKTemplateParser.h"
#import "SKXMLTemplate.h"
#import "ShadowMacros.h"

#include <getopt.h>

static void usage() {
  printf("usage: %s [-xw] template1 ...\n", getprogname());
}

int main (int argc, char * const argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  extern char *optarg;
  extern int optind;
  int ch;
  
  Class cls = [SKTemplate class];

  /* options descriptor */
  static struct option longopts[] = {
  {"xml", no_argument, nil, 'x'},
  {"warning", no_argument, nil, 'w' },
  {nil, 0, nil, 0} };
  
  if (argc < 2) {
    usage();
    goto exit;
  }
  
  SKTemplateLogMessage = YES;
  SKTemplateLogWarning = YES;
  
  while ((ch = getopt_long(argc, argv, "xw", longopts, NULL)) != -1) {
    switch(ch) {
      case 'w':
        SKTemplateLogWarning = NO;
        break;
      case 'x':
        cls = [SKXMLTemplate class];
        break;
      case '?':
      default:
        usage();
        goto exit;
    }
  }
  
  NSArray *arguments = [[NSProcessInfo processInfo] arguments];
  if ([arguments count] == optind) {
    usage();
    goto exit;
  }
  
  unsigned idx = 0;
  for (idx = optind; idx<[arguments count]; idx++) {
    NSString *tplFile = [[arguments objectAtIndex:idx] stringByStandardizingPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tplFile]) {
      fprintf(stdout, "File %s not found\n", [tplFile cString]);
    } else {
      SKTemplate *tpl = [[cls alloc] initWithContentsOfFile:tplFile];
      [tpl load];
      fprintf(stdout, "\n");
      [tpl release];
    }
  }
  
exit:
  [pool release];
  return 0;
}
