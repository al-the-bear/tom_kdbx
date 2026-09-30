import 'package:kdbx/kdbx.dart';
import 'package:test/test.dart';

import 'internal/test_utils.dart';

/// `KdbxDao.clearDeletion` — forgetting a permanent deletion.
///
/// Emptying a recycle bin removes an object and records its UUID in
/// `DeletedObjects`. A caller that then puts an object with that UUID back
/// leaves a file holding both, and a client merging two copies removes an
/// object that is older than its tombstone. The tombstones could be added
/// and read, and never removed.
///
/// The claims: the removal survives a save and reload; it reports whether
/// there was anything to remove; it leaves the other tombstones alone.
void main() {
  final testUtil = TestUtil();

  KdbxEntry purged(KdbxFile file, String title) {
    final entry = testUtil.createEntry(file, file.body.rootGroup, title, 'x');
    file.deleteEntry(entry);
    file.deletePermanently(entry);
    return entry;
  }

  group('KdbxDao.clearDeletion', () {
    test('a cleared tombstone is absent after save and reload', () async {
      final file = testUtil.createEmptyFile();
      final gone = purged(file, 'gone');
      final back = purged(file, 'back');
      expect(file.isDeleted(gone.uuid), isTrue);
      expect(file.isDeleted(back.uuid), isTrue);

      final saved = await testUtil.readKdbxFileBytes(await file.save());
      expect(saved.body.deletedObjects, hasLength(2));

      expect(saved.clearDeletion(back.uuid), isTrue);

      final reloaded = await testUtil.readKdbxFileBytes(await saved.save());
      expect(reloaded.isDeleted(back.uuid), isFalse);
      expect(
        reloaded.isDeleted(gone.uuid),
        isTrue,
        reason: 'its neighbour is untouched',
      );
      expect(reloaded.body.deletedObjects, hasLength(1));
    });

    test('reports false when the UUID was never deleted', () {
      final file = testUtil.createEmptyFile();
      final live = testUtil.createEntry(file, file.body.rootGroup, 'a', 'b');
      purged(file, 'other');

      expect(file.clearDeletion(live.uuid), isFalse);
      expect(file.body.deletedObjects, hasLength(1));
    });

    test('removes every tombstone a UUID has', () {
      final file = testUtil.createEmptyFile();
      final entry = purged(file, 'twice');
      file.ctx.addDeletedObject(entry.uuid);
      expect(file.body.deletedObjects, hasLength(2));

      expect(file.clearDeletion(entry.uuid), isTrue);
      expect(file.body.deletedObjects, isEmpty);
    });

    test('does not mark the file dirty', () {
      final file = testUtil.createEmptyFile();
      final entry = purged(file, 'quiet');
      final before = Set.of(file.dirtyObjects);

      file.clearDeletion(entry.uuid);
      expect(file.dirtyObjects, before);
    });
  });
}
