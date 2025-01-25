//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

NSString* app_name_from_bundle_id(NSString *app_bundle_id) {
    return [[[app_bundle_id componentsSeparatedByString:@"."] lastObject] lowercaseString];
}

NSMutableDictionary* get_http_handlers() {
    NSArray *handlers =
      (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
        (__bridge CFStringRef) @"http"
      );

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < [handlers count]; i++) {
        NSString *handler = [handlers objectAtIndex:i];
        dict[app_name_from_bundle_id(handler)] = handler;
    }

    return dict;
}

NSString* get_current_http_handler() {
    NSString *handler =
        (__bridge NSString *) LSCopyDefaultHandlerForURLScheme(
            (__bridge CFStringRef) @"http"
        );

    return app_name_from_bundle_id(handler);
}

void set_default_handler(NSString *url_scheme, NSString *handler) {
    LSSetDefaultHandlerForURLScheme(
        (__bridge CFStringRef) url_scheme,
        (__bridge CFStringRef) handler
    );
}

int main(int argc, const char *argv[]) {
    NSString *target = (argc > 1) ? [NSString stringWithUTF8String:argv[1]] : nil;

    @autoreleasepool {
        // Get all HTTP handlers
        NSMutableDictionary *handlers = get_http_handlers();

        // Get current HTTP handler
        NSString *current_handler_name = get_current_http_handler();

        if (target == nil) {
            // List all HTTP handlers, marking the current one with a star
            for (NSString *key in handlers) {
                NSString *value = handlers[key];
                char *mark = [key caseInsensitiveCompare:current_handler_name] == NSOrderedSame ? "* " : "  ";

                if ([key caseInsensitiveCompare:@"browser"] == NSOrderedSame) {
                    key = @"arc";
                }
                printf("%s%s\n", mark, [key UTF8String]);
            }
        } else {
            NSString *display_name = [target copy];
            NSString *lookup_name = [target copy];

            // Convert arc/browser names for display and lookup
            if ([target caseInsensitiveCompare:@"browser"] == NSOrderedSame) {
                display_name = @"arc";
                lookup_name = @"browser";
            } else if ([target caseInsensitiveCompare:@"arc"] == NSOrderedSame) {
                display_name = @"arc";
                lookup_name = @"browser";
            }

            if ([lookup_name caseInsensitiveCompare:current_handler_name] == NSOrderedSame) {
                printf("%s is already set as the default HTTP handler\n", [display_name UTF8String]);
            } else {
                NSString *target_handler = handlers[lookup_name];

                if (target_handler != nil) {
                    // Set new HTTP handler (HTTP and HTTPS separately)
                    set_default_handler(@"http", target_handler);
                    set_default_handler(@"https", target_handler);
                } else {
                    printf("%s is not available as an HTTP handler\n", [display_name UTF8String]);

                    return 1;
                }
            }
        }
    }

    return 0;
}
