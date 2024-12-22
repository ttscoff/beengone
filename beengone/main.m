/*******************************************************************************
 * Copyright (c) 2011, Jean-David Gadina <macmade@eosgarden.com>
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

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <IOKit/IOKitLib.h>
#include <Cocoa/Cocoa.h>

#include "argparse.h"

/******************************************************************************/

@interface IdleTime: NSObject
{
@protected
    
    mach_port_t   _ioPort;
    io_iterator_t _ioIterator;
    io_object_t   _ioObject;
    
@private
    
    id r1;
    id r2;
}

@property( readonly ) uint64_t   timeIdle;
@property( readonly ) NSUInteger secondsIdle;

@end

/******************************************************************************/

@implementation IdleTime

- ( id )init
{
    kern_return_t status = 0;
    
    if( ( self = [ super init ] ) )
    {
        _ioPort = kIOMainPortDefault;
        
        status = IOServiceGetMatchingServices
        (
            _ioPort,
            IOServiceMatching( "IOHIDSystem" ),
            &_ioIterator
        );
        
        if( status != KERN_SUCCESS )
        {
            @throw [ NSException
                        exceptionWithName:  @"IdleTimeIOHIDError"
                        reason:             @"Error accessing IOHIDSystem"
                        userInfo:           nil
                   ];
        }
        
        _ioObject = IOIteratorNext( _ioIterator );
        
        if( _ioObject == 0 )
        {
            IOObjectRelease( _ioIterator );
            
            @throw [ NSException
                        exceptionWithName:  @"IdleTimeIteratorError"
                        reason:             @"Invalid iterator"
                        userInfo:           nil
                   ];
        }
        
        IOObjectRetain( _ioObject );
        IOObjectRetain( _ioIterator );
    }
    
    return self;
}

- ( void )dealloc
{
    IOObjectRelease( _ioObject );
    IOObjectRelease( _ioIterator );
}

- ( uint64_t )timeIdle
{
    kern_return_t          status;
    CFTypeRef              idle;
    CFTypeID               type;
    uint64_t               time;
    CFMutableDictionaryRef properties;
    
    properties = NULL;
    status     = IORegistryEntryCreateCFProperties
    (
        _ioObject,
        &properties,
        kCFAllocatorDefault,
        0
    );
    
    if( status != KERN_SUCCESS || properties == NULL )
    {
        @throw [ NSException
                    exceptionWithName:  @"IdleTimeSystemPropError"
                    reason:             @"Cannot get system properties"
                    userInfo:           nil
               ];
    }
    
    idle = CFDictionaryGetValue( properties, CFSTR( "HIDIdleTime" ) );
    
    if( !idle )
    {
        CFRelease( ( CFTypeRef )properties );
        
        @throw [ NSException
                    exceptionWithName:  @"IdleTimeSystemTimeError"
                    reason:             @"Cannot get system idle time"
                    userInfo:           nil
               ];
    }
    
    CFRetain( idle );
    
    type = CFGetTypeID( idle );
    
    if( type == CFDataGetTypeID() )
    {
        CFDataGetBytes
        (
            ( CFDataRef )idle,
            CFRangeMake( 0, sizeof( time ) ),
            ( UInt8 * )&time
        );
        
    }
    else if( type == CFNumberGetTypeID() )
    {
        CFNumberGetValue
        (
            ( CFNumberRef )idle,
            kCFNumberSInt64Type,
            &time
        );
    }
    else
    {
        CFRelease( idle );
        CFRelease( ( CFTypeRef )properties );
        
        @throw [ NSException
                    exceptionWithName:  @"IdleTimeTypeError"
                    reason:             [ NSString stringWithFormat: @"Unsupported type: %d\n", ( int )type ]
                    userInfo:           nil
               ];
    }
    
    CFRelease( idle );
    CFRelease( ( CFTypeRef )properties );
    
    return time;
}

- ( NSUInteger )secondsIdle
{
    uint64_t time;
    
    time = self.timeIdle;
    
    return ( NSUInteger )( time >> 30 );
}

@end

/******************************************************************************/
static const char *const usages[] = {
    "beengone [options]",
    NULL,
};

int main( int argc, char * argv[] )
{
    @autoreleasepool {
        int newline = 0;
        int limit = 0;
        struct argparse_option options[] = {
            OPT_HELP(),
            OPT_GROUP("Basic options"),
            OPT_BOOLEAN('n', "no-newline", &newline, "print without newline", NULL, 0, 0),
            OPT_INTEGER('m', "minimum", &limit, "text for minimum idle time", NULL, 0, 0),
            OPT_END(),
        };

        struct argparse argparse;
        argparse_init(&argparse, options, usages, 0);
        argparse_describe(&argparse, "\nPrint the system idle time in seconds", "");
        argc = argparse_parse(&argparse, argc, argv);
        
        if (limit != 0) {
            if ((unsigned long)[[[IdleTime alloc] init] secondsIdle] > limit)
                return EXIT_SUCCESS;
            else
                return EXIT_FAILURE;
        }
            
        if (newline != 0)
            printf("%lu", (unsigned long)[[[IdleTime alloc] init] secondsIdle]);
        else
            printf("%lu\n", (unsigned long)[[[IdleTime alloc] init] secondsIdle]);
        
    }
    
    return EXIT_SUCCESS;
}
                
