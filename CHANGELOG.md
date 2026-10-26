## 2.4.2+tom.4

Published as `tom_kdbx`, a fork of `kdbx` 2.4.2
(<https://github.com/authpass/kdbx.dart>, by the AuthPass project), from the
branch `tom/2.4.2-patches` of <https://github.com/al-the-bear/tom_kdbx>.
The main library is `package:tom_kdbx/tom_kdbx.dart` (upstream's
`lib/kdbx.dart`, renamed to match the package); the API is upstream's plus:

- `KdbxObjectUuidControl.assignUuid` — a public UUID-assignment API on
  `KdbxObject`, so an object's UUID can be chosen at creation.
- `KdbxCustomData.remove`, completing the map-like surface.
- `KdbxDao.clearDeletion` and `isDeleted`, so an object put back into a file is
  not left recorded as deleted.
- `xml: '>=4.4.0 <8.0.0'` — upstream caps `xml` below 7.

Versions keep upstream's number and count this fork's releases in the build
suffix (`+tom.4`, `+tom.5`, …); the upstream part changes only when the fork is
rebased onto a new upstream release.

## 2.4.2

- Update dependencies. (archive, pointycastle)

## 2.4.1

- Update dependencies.

## 2.4.0

- Migrate to latest dart version.

## 2.3.0

- Mark objects only as clean when saving was successful.
- Only mark objects as clean if they have not been modified since we started saving.
- Make credentials changeable.
- Add support for CustomData in entries.
- Upgrade dependencies.

## 2.2.0

- If argon2 ffi implementation is not available, fallback to pointycastle (dart-only) 
  implementation.

## 2.1.1

- Throw KdbxInvalidFileStructure for invalid files.

## 2.1.0

- Implement permanently removing entries and groups.
- Fix merging of files with incoming deleted objects.

## 2.0.0+1

- Small Null-safety improvement.
- add debugging to AES decryption.

## 2.0.0

- Null-safety migration

## 1.0.0

- Use kdbx 4.x by default when creating new files.
- Implemented support for custom icons.
- Implemented file merging/synchronization.
- Fixed threading problem on save: only allow one save at a time for each file.
- Support for V2 keyfile https://forum.authpass.app/t/issuues-with-keyfile/84/3

## 0.4.1

- fix bug saving files with history entries which contain attachments.
- fix bug which would create wrong history entries.

## 0.4.0+1

- Fix UsageCount typo (vs. Usagecount) #1

## 0.4.0

- Upgraded xml package dependency to 4.x

## 0.3.1

- Fixed error handling nil UUIDs in recycle bin.
  Also, only create recycle bin on demand (when deleting items).

## 0.3.0+1

- Minor fixes for kdbx 4.x

## 0.3.0

- Initial support for kdbx 4.x

## 0.2.1

- Throw unsupported exception when trying to read kdbx 4.x files.

## 0.2.0

- Fixed writing of packet index for payload.
- Fixed big endian vs. little endian encoding.
- Compatibility fixes with other kdbx apps.

## 0.1.0

- Support for reading and writing kdbx 2.x files
  (with a master password)


## 0.0.1

- Initial version, created by Stagehand
