import 'package:clock/clock.dart';
import 'package:kdbx/src/kdbx_entry.dart';
import 'package:kdbx/src/kdbx_file.dart';
import 'package:kdbx/src/kdbx_group.dart';
import 'package:kdbx/src/kdbx_object.dart';

/// Helper object for accessing and modifing data inside
/// a kdbx file.
extension KdbxDao on KdbxFile {
  KdbxGroup createGroup({
    required KdbxGroup parent,
    required String name,
  }) {
    final newGroup = KdbxGroup.create(ctx: ctx, parent: parent, name: name);
    parent.addGroup(newGroup);
    return newGroup;
  }

  KdbxGroup findGroupByUuid(KdbxUuid? uuid) =>
      body.rootGroup.getAllGroups().firstWhere(
        (group) => group.uuid == uuid,
        orElse: (() =>
            throw StateError('Unable to find group with uuid $uuid')),
      );

  void deleteGroup(KdbxGroup group) {
    move(group, getRecycleBinOrCreate());
  }

  void deleteEntry(KdbxEntry entry) {
    move(entry, getRecycleBinOrCreate());
  }

  void move(KdbxObject kdbxObject, KdbxGroup toGroup) {
    kdbxObject.times.locationChanged.setToNow();
    if (kdbxObject is KdbxGroup) {
      kdbxObject.parent!.internalRemoveGroup(kdbxObject);
      kdbxObject.internalChangeParent(toGroup);
      toGroup.addGroup(kdbxObject);
    } else if (kdbxObject is KdbxEntry) {
      kdbxObject.parent!.internalRemoveEntry(kdbxObject);
      kdbxObject.internalChangeParent(toGroup);
      toGroup.addEntry(kdbxObject);
    }
  }

  void deletePermanently(KdbxObject kdbxObject) {
    final parent = kdbxObject.parent;
    if (parent == null) {
      throw StateError(
        'Unable to delete object. Object as no parent, already deleted?',
      );
    }
    final now = clock.now().toUtc();
    if (kdbxObject is KdbxGroup) {
      for (final object in kdbxObject.getAllGroupsAndEntries()) {
        ctx.addDeletedObject(object.uuid, now);
      }
      parent.internalRemoveGroup(kdbxObject);
    } else if (kdbxObject is KdbxEntry) {
      ctx.addDeletedObject(kdbxObject.uuid, now);
      parent.internalRemoveEntry(kdbxObject);
    } else {
      throw StateError('Invalid object type. ${kdbxObject.runtimeType}');
    }
    kdbxObject.times.locationChanged.set(now);
    kdbxObject.internalChangeParent(null);
  }

  /// Whether the file records [uuid] as permanently deleted.
  bool isDeleted(KdbxUuid uuid) => ctx.hasDeletedObject(uuid);

  /// Forgets that [uuid] was permanently deleted, and says whether the file
  /// had recorded it.
  ///
  /// For a caller that puts an object with that UUID back into the file. A
  /// file that holds an object and a tombstone for one UUID contradicts
  /// itself, and a client that merges two copies settles the contradiction
  /// by time: an object last modified before its tombstone is removed. An
  /// object that returns with the times it had is older than the deletion,
  /// so it would be deleted a second time.
  ///
  /// It changes nothing else. The file is not marked dirty, as
  /// [deletePermanently] does not mark it: the object that was put back is
  /// what the caller saves for.
  bool clearDeletion(KdbxUuid uuid) => ctx.removeDeletedObject(uuid);
}
