//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_item.g.dart';

/// ExportItem
///
/// Properties:
/// * [format] 
/// * [url] 
/// * [contentType] 
/// * [description] 
@BuiltValue()
abstract class ExportItem implements Built<ExportItem, ExportItemBuilder> {
  @BuiltValueField(wireName: r'format')
  ExportItemFormatEnum get format;
  // enum formatEnum {  json,  md,  html,  zip,  odp,  };

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'content_type')
  String get contentType;

  @BuiltValueField(wireName: r'description')
  String? get description;

  ExportItem._();

  factory ExportItem([void updates(ExportItemBuilder b)]) = _$ExportItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportItem> get serializer => _$ExportItemSerializer();
}

class _$ExportItemSerializer implements PrimitiveSerializer<ExportItem> {
  @override
  final Iterable<Type> types = const [ExportItem, _$ExportItem];

  @override
  final String wireName = r'ExportItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(ExportItemFormatEnum),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExportItemFormatEnum),
          ) as ExportItemFormatEnum;
          result.format = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'content_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentType = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportItemBuilder();
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


class ExportItemFormatEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'json')
  static const ExportItemFormatEnum json = _$exportItemFormatEnum_json;
  @BuiltValueEnumConst(wireName: r'md')
  static const ExportItemFormatEnum md = _$exportItemFormatEnum_md;
  @BuiltValueEnumConst(wireName: r'html')
  static const ExportItemFormatEnum html = _$exportItemFormatEnum_html;
  @BuiltValueEnumConst(wireName: r'zip')
  static const ExportItemFormatEnum zip = _$exportItemFormatEnum_zip;
  @BuiltValueEnumConst(wireName: r'odp')
  static const ExportItemFormatEnum odp = _$exportItemFormatEnum_odp;

  static Serializer<ExportItemFormatEnum> get serializer => _$exportItemFormatEnumSerializer;

  const ExportItemFormatEnum._(String name): super(name);

  static BuiltSet<ExportItemFormatEnum> get values => _$exportItemFormatEnumValues;
  static ExportItemFormatEnum valueOf(String name) => _$exportItemFormatEnumValueOf(name);
}

