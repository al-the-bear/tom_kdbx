# tom_kdbx

KeepassX format implementation in pure dart.

**This is a fork** of [kdbx](https://github.com/authpass/kdbx.dart) 2.4.2 by the
AuthPass project, published as `tom_kdbx` for the Tom workspace. It is upstream
2.4.2 plus a public UUID-assignment API, `KdbxCustomData.remove`,
`KdbxDao.clearDeletion` / `isDeleted` and `xml` 7 support; see the CHANGELOG.
Import it as `package:tom_kdbx/tom_kdbx.dart`. The licence is upstream's, GPL-3.0.

Check out [AuthPass Password Manager](https://authpass.app/) for an app
which uses this library.

## Resources

* Code is very much based on https://github.com/keeweb/kdbxweb/
* https://gist.github.com/msmuenchen/9318327

## Usage

TODO

## Features and bugs

* Supports kdbx v3 with native dart implementation
* Supports kdbx v4 with combination with [argon2 ffi](https://github.com/authpass/argon2_ffi)

# Argon2 support

root directory contains shared libraris (libargon2*) which are built from
https://github.com/authpass/argon2_ffi

* MacOS:
  * argon2_ffi/ios/Classes
  * `cmake . && cmake --build .`
  * `cp libargon2_ffi.dylib kdbx.dart/`
  * Might need to run: `codesign --remove-signature /usr/local/bin/dart`
    https://github.com/dart-lang/sdk/issues/39231#issuecomment-579743656
* Linux:
  * argon2_ffi/ios/Classes
  * `cmake . && cmake --build .`
  * `cp libargon2_ffi.so kdbx.dart/`
* Windows:
  * Install Visual Studio Commnity Edition with C++ Development environment
  * Start "Developer Command Prompt for VS 2019"
  * argon2_ffi/ios/Classes:
    ```
    cmake .
    cmake --build .
    cp Debug\argon2_ffi.dll C:\kdbx.dart\argon2_ffi_plugin.dll
    ```
