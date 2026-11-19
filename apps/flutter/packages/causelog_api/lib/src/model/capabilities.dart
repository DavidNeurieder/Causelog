//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/capabilities_auth.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'capabilities.g.dart';

/// Capabilities
///
/// Properties:
/// * [apiVersion] 
/// * [serverVersion] 
/// * [auth] 
/// * [exportFormats] 
@BuiltValue()
abstract class Capabilities implements Built<Capabilities, CapabilitiesBuilder> {
  @BuiltValueField(wireName: r'api_version')
  String get apiVersion;

  @BuiltValueField(wireName: r'server_version')
  String get serverVersion;

  @BuiltValueField(wireName: r'auth')
  CapabilitiesAuth get auth;

  @BuiltValueField(wireName: r'export_formats')
  BuiltList<CapabilitiesExportFormatsEnum> get exportFormats;
  // enum exportFormatsEnum {  json,  md,  html,  zip,  odp,  };

  Capabilities._();

  factory Capabilities([void updates(CapabilitiesBuilder b)]) = _$Capabilities;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CapabilitiesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Capabilities> get serializer => _$CapabilitiesSerializer();
}

class _$CapabilitiesSerializer implements PrimitiveSerializer<Capabilities> {
  @override
  final Iterable<Type> types = const [Capabilities, _$Capabilities];

  @override
  final String wireName = r'Capabilities';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Capabilities object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'api_version';
    yield serializers.serialize(
      object.apiVersion,
      specifiedType: const FullType(String),
    );
    yield r'server_version';
    yield serializers.serialize(
      object.serverVersion,
      specifiedType: const FullType(String),
    );
    yield r'auth';
    yield serializers.serialize(
      object.auth,
      specifiedType: const FullType(CapabilitiesAuth),
    );
    yield r'export_formats';
    yield serializers.serialize(
      object.exportFormats,
      specifiedType: const FullType(BuiltList, [FullType(CapabilitiesExportFormatsEnum)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Capabilities object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CapabilitiesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'api_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.apiVersion = valueDes;
          break;
        case r'server_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serverVersion = valueDes;
          break;
        case r'auth':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CapabilitiesAuth),
          ) as CapabilitiesAuth;
          result.auth.replace(valueDes);
          break;
        case r'export_formats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CapabilitiesExportFormatsEnum)]),
          ) as BuiltList<CapabilitiesExportFormatsEnum>;
          result.exportFormats.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Capabilities deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CapabilitiesBuilder();
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


class CapabilitiesExportFormatsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'json')
  static const CapabilitiesExportFormatsEnum json = _$capabilitiesExportFormatsEnum_json;
  @BuiltValueEnumConst(wireName: r'md')
  static const CapabilitiesExportFormatsEnum md = _$capabilitiesExportFormatsEnum_md;
  @BuiltValueEnumConst(wireName: r'html')
  static const CapabilitiesExportFormatsEnum html = _$capabilitiesExportFormatsEnum_html;
  @BuiltValueEnumConst(wireName: r'zip')
  static const CapabilitiesExportFormatsEnum zip = _$capabilitiesExportFormatsEnum_zip;
  @BuiltValueEnumConst(wireName: r'odp')
  static const CapabilitiesExportFormatsEnum odp = _$capabilitiesExportFormatsEnum_odp;

  static Serializer<CapabilitiesExportFormatsEnum> get serializer => _$capabilitiesExportFormatsEnumSerializer;

  const CapabilitiesExportFormatsEnum._(String name): super(name);

  static BuiltSet<CapabilitiesExportFormatsEnum> get values => _$capabilitiesExportFormatsEnumValues;
  static CapabilitiesExportFormatsEnum valueOf(String name) => _$capabilitiesExportFormatsEnumValueOf(name);
}

