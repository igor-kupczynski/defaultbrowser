defaultbrowser
==============

Command line tool for setting the default browser (HTTP handler) in macOS X.

Install
-------

Build it (universal binary for both Apple Silicon (arm64) and Intel (x86_64) Macs):

```
make
```

This will compile the code for both architectures and create a single universal binary named `defaultbrowser` using `lipo`.

Install it into your executable path:

```
make install
```

Usage
-----

Set the default browser with, e.g.:

```
defaultbrowser chrome
```

Running `defaultbrowser` without arguments lists available HTTP handlers and shows the current setting.

How does it work?
-----------------

The tool uses a combination of the [macOS Launch Services API](https://developer.apple.com/documentation/coreservices/launch_services) (for setting the default handler) and [AppKit's NSWorkspace APIs](https://developer.apple.com/documentation/appkit/nsworkspace) (for querying available and current browser handlers). This ensures compatibility with modern macOS versions and avoids deprecated APIs.

Additional Resources
--------------------

- [Bash completion](https://github.com/jonasbn/bash_completion_defaultbrowser) for `defaultbrowser`

License
-------

MIT
