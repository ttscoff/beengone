/*******************************************************************************
 * Copyright (c) 2024, Brett Terpstra
 * MIT License
 *
 * Based on code by Jean-David Gadina <macmade@eosgarden.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  -   Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *  -   Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *  -   Neither the name of 'Jean-David Gadina' nor the names of its
 *      contributors may be used to endorse or promote products derived from
 *      this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <IOKit/IOKitLib.h>

#include "argparse.h"

#define BEENGONE_VERSION "2.0.8"

/******************************************************************************/

@interface IdleTime : NSObject {
@protected

  mach_port_t _ioPort;
  io_iterator_t _ioIterator;
  io_object_t _ioObject;

@private

  id r1;
  id r2;
}

@property(readonly) uint64_t timeIdle;
@property(readonly) NSUInteger secondsIdle;

@end

/******************************************************************************/

@implementation IdleTime

- (id)init {
  kern_return_t status = 0;

  if ((self = [super init])) {
    if (@available(macOS 12.0, *)) {
      _ioPort = kIOMainPortDefault;
    } else {
      printf('%s', "macOS 12.0 or higher required.");
      exit(1);
    }

    status = IOServiceGetMatchingServices(
        _ioPort, IOServiceMatching("IOHIDSystem"), &_ioIterator);

    if (status != KERN_SUCCESS) {
      @throw [NSException exceptionWithName:@"IdleTimeIOHIDError"
                                     reason:@"Error accessing IOHIDSystem"
                                   userInfo:nil];
    }

    _ioObject = IOIteratorNext(_ioIterator);

    if (_ioObject == 0) {
      IOObjectRelease(_ioIterator);

      @throw [NSException exceptionWithName:@"IdleTimeIteratorError"
                                     reason:@"Invalid iterator"
                                   userInfo:nil];
    }

    IOObjectRetain(_ioObject);
    IOObjectRetain(_ioIterator);
  }

  return self;
}

- (void)dealloc {
  IOObjectRelease(_ioObject);
  IOObjectRelease(_ioIterator);
}

- (uint64_t)timeIdle {
  kern_return_t status;
  CFTypeRef idle;
  CFTypeID type;
  uint64_t time;
  CFMutableDictionaryRef properties;

  properties = NULL;
  status = IORegistryEntryCreateCFProperties(_ioObject, &properties,
                                             kCFAllocatorDefault, 0);

  if (status != KERN_SUCCESS || properties == NULL) {
    @throw [NSException exceptionWithName:@"IdleTimeSystemPropError"
                                   reason:@"Cannot get system properties"
                                 userInfo:nil];
  }

  idle = CFDictionaryGetValue(properties, CFSTR("HIDIdleTime"));

  if (!idle) {
    CFRelease((CFTypeRef)properties);

    @throw [NSException exceptionWithName:@"IdleTimeSystemTimeError"
                                   reason:@"Cannot get system idle time"
                                 userInfo:nil];
  }

  CFRetain(idle);

  type = CFGetTypeID(idle);

  if (type == CFDataGetTypeID()) {
    CFDataGetBytes((CFDataRef)idle, CFRangeMake(0, sizeof(time)),
                   (UInt8 *)&time);
  } else if (type == CFNumberGetTypeID()) {
    CFNumberGetValue((CFNumberRef)idle, kCFNumberSInt64Type, &time);
  } else {
    CFRelease(idle);
    CFRelease((CFTypeRef)properties);

    @throw [NSException
        exceptionWithName:@"IdleTimeTypeError"
                   reason:[NSString stringWithFormat:@"Unsupported type: %d\n",
                                                     (int)type]
                 userInfo:nil];
  }

  CFRelease(idle);
  CFRelease((CFTypeRef)properties);

  return time;
}

- (NSUInteger)secondsIdle {
  uint64_t time;

  time = self.timeIdle;

  return (NSUInteger)(time >> 30);
}

@end

/******************************************************************************/
static const char *const usages[] = {
    "beengone [options]",
    NULL,
};

unsigned long parse_time_string(const char *time_str) {
  unsigned long total_seconds = 0;
  unsigned long value = 0;
  char unit = '\0';

  while (*time_str) {
    if (sscanf(time_str, "%lu%c", &value, &unit) == 2) {
      switch (unit) {
      case 'd':
        total_seconds += value * 86400; // 1 day = 86400 seconds
        break;

      case 'h':
        total_seconds += value * 3600; // 1 hour = 3600 seconds
        break;

      case 'm':
        total_seconds += value * 60; // 1 minute = 60 seconds
        break;

      case 's':
        total_seconds += value;
        break;

      default:
        break;
      }

      // Advance the pointer past the current value and unit
      while (*time_str && *time_str != ' ' && *time_str != '\t')
        time_str++;
    } else if (sscanf(time_str, "%lu", &value) == 1) {
      total_seconds += value;
      break;
    } else {
      break;
    }

    // Skip any spaces or tabs
    while (*time_str && (*time_str == ' ' || *time_str == '\t'))
      time_str++;
  }

  return total_seconds;
}

int simulate_user_input(struct argparse *self,
                        const struct argparse_option *option) {
  CGEventRef click_down = CGEventCreateMouseEvent(
      NULL, kCGEventLeftMouseDown, CGPointMake(100, 100), kCGMouseButtonLeft);
  CGEventRef click_up = CGEventCreateMouseEvent(
      NULL, kCGEventLeftMouseUp, CGPointMake(100, 100), kCGMouseButtonLeft);

  if (click_down && click_up) {
    CGEventPost(kCGHIDEventTap, click_down);
    CGEventPost(kCGHIDEventTap, click_up);
    CFRelease(click_down);
    CFRelease(click_up);
  }

  exit(0);
}

void wait_for_idle_time(unsigned long target_idle_time) {
  IdleTime *idleTime = [[IdleTime alloc] init];
  unsigned long idle = 0;

  while (1) {
    idle = (unsigned long)[idleTime secondsIdle];
    if (idle >= target_idle_time) {
      break;
    }
    sleep(1); // Sleep for 1 second before checking again
  }
}

int beengone_version_cb(struct argparse *self,
                        const struct argparse_option *option) {
  printf("beengone version %s\n", BEENGONE_VERSION);
  exit(0);
}

int main(int argc, char *argv[]) {
  @autoreleasepool {
    int newline = 0;
    int debug = 0;
    unsigned long limit = 0;
    const char *minimum = NULL;
    const char *wait = NULL;

    struct argparse_option options[] = {

        OPT_GROUP("Options"),
        OPT_BOOLEAN('n', "no-newline", &newline,
                    "print idle seconds without newline", NULL, 0, OPT_NONEG),
        OPT_STRING('m', "minimum", &minimum,
                   "test for minimum idle time in seconds, exit 0 or 1 based "
                   "on condition, accepts strings like \"5h 30m\" or \"1d12h\"",
                   NULL, 0, OPT_NONEG),
        OPT_STRING(
            'w', "wait", &wait,
            "wait until the system has been idle for the specified "
            "number of seconds, accepts strings like \"5h 30m\" or \"1m30s\"",
            NULL, 0, OPT_NONEG),
        OPT_BOOLEAN('i', "input", NULL, "simulate user input",
                    simulate_user_input, 0, OPT_NONEG),
        OPT_GROUP("Other"),
        OPT_HELP(),
        OPT_BOOLEAN('d', "debug", &debug, "print debugging info", NULL, 0,
                    OPT_NONEG),
        OPT_BOOLEAN('v', "version", NULL, "show version and exit",
                    beengone_version_cb, 0, OPT_NONEG),
        OPT_END(),
    };

    struct argparse argparse;
    argparse_init(&argparse, options, usages, 0);
    argparse_describe(&argparse, "\nPrint the system idle time in seconds.",
                      "");
    argc = argparse_parse(&argparse, argc, argv);

    if (wait != NULL) {
      limit = parse_time_string(wait);

      wait_for_idle_time(limit);
      return EXIT_SUCCESS;
    }

    unsigned long idle = (unsigned long)[[[IdleTime alloc] init] secondsIdle];

    if (minimum != NULL) {
      limit = parse_time_string(minimum);

      if (limit > 0) {
        if (debug != 0)
          fprintf(stderr, "Limit: %lu seconds, idle time %lu: ", limit, idle);

        if (idle >= limit) {
          if (debug != 0)
            fprintf(stderr, "%s", "true\n");

          return EXIT_SUCCESS;
        } else {
          if (debug != 0)
            fprintf(stderr, "%s", "false\n");

          return EXIT_FAILURE;
        }
      }
    }

    if (newline != 0) {
      printf("%lu", idle);
    } else {
      printf("%lu\n", idle);
    }
  }

  return EXIT_SUCCESS;
}
