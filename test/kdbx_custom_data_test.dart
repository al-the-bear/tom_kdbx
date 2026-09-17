import 'package:test/test.dart';

import 'internal/test_utils.dart';

/// `KdbxCustomData.remove` — the map-like surface's missing operation.
///
/// Custom data could be written and read but never unwritten, so a consumer
/// that wanted a key gone could only blank it. A key holding the empty string
/// is a different artifact from an absent one to *every* reader of the file,
/// so the distinction is the format's, not one application's.
///
/// The claims are: a removal survives a save/reload round trip (the one that
/// matters, because an in-memory removal that does not reach the XML is worse
/// than none); it reports what it removed; and it leaves the node alone when
/// there was nothing to remove.
void main() {
  final testUtil = TestUtil();

  group('KdbxCustomData.remove', () {
    test('removes a key so that it is absent after save and reload', () async {
      final file = testUtil.createEmptyFile();
      final meta = file.body.meta.customData;
      meta['keep.this'] = 'kept';
      meta['drop.this'] = 'dropped';

      final saved = await testUtil.readKdbxFileBytes(await file.save());
      expect(saved.body.meta.customData.containsKey('drop.this'), isTrue);

      saved.body.meta.customData.remove('drop.this');

      final reloaded = await testUtil.readKdbxFileBytes(await saved.save());
      final reloadedData = reloaded.body.meta.customData;
      expect(
        reloadedData.containsKey('drop.this'),
        isFalse,
        reason: 'the key is gone from the file, not blanked in it',
      );
      expect(reloadedData['drop.this'], isNull);
      expect(
        reloadedData['keep.this'],
        'kept',
        reason: 'its neighbours are untouched',
      );
    });

    test('returns the removed value, and null when the key was absent', () {
      final file = testUtil.createEmptyFile();
      final meta = file.body.meta.customData;
      meta['present'] = 'value';

      expect(meta.remove('present'), 'value');
      expect(meta.containsKey('present'), isFalse);
      expect(meta.remove('present'), isNull, reason: 'already gone');
      expect(meta.remove('never.existed'), isNull);
    });

    test('marks the node modified when it removed something, and not when it '
        'did not', () async {
      final file = testUtil.createEmptyFile();
      file.body.meta.customData['doomed'] = 'value';

      // The assertion is about the custom-data node, and it has to be a node
      // that was *read* rather than created: `KdbxNode.create` marks itself
      // dirty from birth, and `KdbxFile.onSaved` never cleans it, because it
      // cleans `dirtyObjects` — entries and groups — and meta is neither. So
      // a freshly created file's custom data is permanently dirty and can
      // witness nothing.
      final reloaded = await testUtil.readKdbxFileBytes(await file.save());
      final data = reloaded.body.meta.customData;
      expect(data.isDirty, isFalse, reason: 'read, not created');

      data.remove('never.existed');
      expect(
        data.isDirty,
        isFalse,
        reason: 'removing nothing changes nothing, and a node that did not '
            'change must not report that it did',
      );

      data.remove('doomed');
      expect(data.isDirty, isTrue);
    });

    test('an entry\'s custom data removes on the same terms', () async {
      final file = testUtil.createEmptyFile();
      final entry = testUtil.createEntry(
        file,
        file.body.rootGroup,
        'user',
        'pass',
      );
      entry.customData['app.marker'] = 'set';

      final saved = await testUtil.readKdbxFileBytes(await file.save());
      final savedEntry = saved.body.rootGroup.entries.first;
      expect(savedEntry.customData['app.marker'], 'set');

      expect(savedEntry.customData.remove('app.marker'), 'set');

      final reloaded = await testUtil.readKdbxFileBytes(await saved.save());
      expect(
        reloaded.body.rootGroup.entries.first.customData
            .containsKey('app.marker'),
        isFalse,
      );
    });
  });
}
