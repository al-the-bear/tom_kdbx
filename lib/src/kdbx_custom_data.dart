import 'package:kdbx/src/internal/extension_utils.dart';
import 'package:kdbx/src/kdbx_object.dart';
import 'package:kdbx/src/kdbx_xml.dart';
import 'package:xml/xml.dart' as xml;

class KdbxCustomData extends KdbxNode {
  KdbxCustomData.create() : _data = {}, super.create(TAG_NAME);

  KdbxCustomData.read(super.node)
    : _data = Map.fromEntries(
        node.findElements(KdbxXml.NODE_CUSTOM_DATA_ITEM).map((el) {
          final key = el.singleTextNode(KdbxXml.NODE_KEY);
          final value = el.singleTextNode(KdbxXml.NODE_VALUE);
          return MapEntry(key, value);
        }),
      ),
      super.read();

  static const String TAG_NAME = KdbxXml.NODE_CUSTOM_DATA;

  final Map<String, String> _data;

  Iterable<MapEntry<String, String>> get entries => _data.entries;

  String? operator [](String key) => _data[key];
  void operator []=(String key, String value) {
    modify(() => _data[key] = value);
  }

  bool containsKey(String key) => _data.containsKey(key);

  /// Removes [key], returning the value it held, or null when it was absent.
  ///
  /// Mirrors [Map.remove], and completes the map-like surface: without it a
  /// consumer can only *blank* a key it no longer wants, and a key holding the
  /// empty string is a different artifact from an absent one — to every other
  /// reader of the file, not just to the one that wrote it.
  ///
  /// The node is marked modified **only when something was actually removed**.
  /// [toXml] regenerates the whole element from [_data], so a removal that
  /// removed nothing produces byte-identical XML, and reporting it as a change
  /// would provoke a save of a file that did not change. This differs
  /// deliberately from [operator []=], which cannot make that distinction
  /// cheaply enough to be worth it: writing a value is nearly always a change,
  /// whereas removing an absent key is nearly always a no-op.
  String? remove(String key) {
    if (!_data.containsKey(key)) {
      return null;
    }
    return modify(() => _data.remove(key));
  }

  @override
  xml.XmlElement toXml() {
    final el = super.toXml();
    el.children.clear();
    el.children.addAll(
      _data.entries.map(
        (e) => XmlUtils.createNode(KdbxXml.NODE_CUSTOM_DATA_ITEM, [
          XmlUtils.createTextNode(KdbxXml.NODE_KEY, e.key),
          XmlUtils.createTextNode(KdbxXml.NODE_VALUE, e.value),
        ]),
      ),
    );
    return el;
  }

  void merge(KdbxCustomData other, bool otherIsNewer) {
    // merge custom data
    for (final otherCustomDataEntry in other.entries) {
      if (otherIsNewer || !containsKey(otherCustomDataEntry.key)) {
        this[otherCustomDataEntry.key] = otherCustomDataEntry.value;
      }
    }
  }

  void overwriteFrom(KdbxCustomData other) {
    _data.clear();
    _data.addAll(other._data);
  }
}
