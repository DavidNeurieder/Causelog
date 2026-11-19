//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/export_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_manifest.g.dart';

/// ExportManifest
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class ExportManifest implements Built<ExportManifest, ExportManifestBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ExportItem> get items;

  ExportManifest._();

  factory ExportManifest([void updates(ExportManifestBuilder b)]) = _$ExportManifest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportManifestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportManifest> get serializer => _$ExportManifestSerializer();
}

class _$ExportManifestSerializer implements PrimitiveSerializer<ExportManifest> {
  @override
  final Iterable<Type> types = const [ExportManifest, _$ExportManifest];

  @override
  final String wireName = r'ExportManifest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportManifest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ExportItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportManifest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportManifestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ExportItem)]),
          ) as BuiltList<ExportItem>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportManifest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportManifestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


