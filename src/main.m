//
//  main.m
//  defaultbrowser
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <AppKit/AppKit.h>

NSString* app_name_from_bundle_id(NSString *app_bundle_id) {

    NSString *handler = app_bundle_id;
    NSString *shortname = @"";

    if ([handler caseInsensitiveCompare:@"company.thebrowser.Browser"] == NSOrderedSame) {
        shortname = @"arc";
    } else if ([handler caseInsensitiveCompare:@"com.brave.Browser"] == NSOrderedSame) {
        shortname = @"brave";
    } else {
        shortname = [[[app_bundle_id componentsSeparatedByString:@"."] lastObject] lowercaseString];
    }

    return shortname;
}

NSMutableDictionary* get_http_handlers() {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSURL *httpURL = [NSURL URLWithString:@"http://example.com"];
    NSArray<NSURL *> *appURLs = [[NSWorkspace sharedWorkspace] URLsForApplicationsToOpenURL:httpURL];

    for (NSURL *appURL in appURLs) {
        NSString *bundleID = [[NSBundle bundleWithURL:appURL] bundleIdentifier];
        if (bundleID) {
            NSString *shortname = app_name_from_bundle_id(bundleID);
            dict[shortname] = bundleID;
        }
    }
    return dict;
}

NSString* get_current_http_handler() {
    NSURL *httpURL = [NSURL URLWithString:@"http://example.com"];
    NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:httpURL];
    NSString *bundleID = nil;
    if (appURL) {
        bundleID = [[NSBundle bundleWithURL:appURL] bundleIdentifier];
    }
    if (!bundleID) {
        return @"unknown";
    }
    return app_name_from_bundle_id(bundleID);
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
                char *mark = [key caseInsensitiveCompare:current_handler_name] == NSOrderedSame ? "* " : "  ";
                printf("%s%s\n", mark, [key UTF8String]);
            }

        } else {
            NSString *target_handler_name = target;

            if ([target_handler_name caseInsensitiveCompare:current_handler_name] == NSOrderedSame) {
              printf("%s is already set as the default HTTP handler\n", [target UTF8String]);
            } else {
                NSString *target_handler = handlers[target];

                if (target_handler != nil) {
                    // Set new HTTP handler (HTTP and HTTPS separately)
                    set_default_handler(@"http", target_handler);
                    set_default_handler(@"https", target_handler);
                } else {
                    printf("%s is not available as an HTTP handler\n\nAvailable HTTP handlers are:\n", [target UTF8String]);
                    for (NSString *key in handlers) {
                        printf("  %s\n", [key UTF8String]);
                    }

                    return 1;
                }
            }
        }
    }

    return 0;
}
