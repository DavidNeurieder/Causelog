//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'capabilities_auth.g.dart';

/// CapabilitiesAuth
///
/// Properties:
/// * [mode] 
/// * [csrfHeader] 
/// * [sessionCookie] 
@BuiltValue()
abstract class CapabilitiesAuth implements Built<CapabilitiesAuth, CapabilitiesAuthBuilder> {
  @BuiltValueField(wireName: r'mode')
  CapabilitiesAuthModeEnum get mode;
  // enum modeEnum {  cookie_csrf,  };

  @BuiltValueField(wireName: r'csrf_header')
  String get csrfHeader;

  @BuiltValueField(wireName: r'session_cookie')
  String get sessionCookie;

  CapabilitiesAuth._();

  factory CapabilitiesAuth([void updates(CapabilitiesAuthBuilder b)]) = _$CapabilitiesAuth;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CapabilitiesAuthBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CapabilitiesAuth> get serializer => _$CapabilitiesAuthSerializer();
}

class _$CapabilitiesAuthSerializer implements PrimitiveSerializer<CapabilitiesAuth> {
  @override
  final Iterable<Type> types = const [CapabilitiesAuth, _$CapabilitiesAuth];

  @override
  final String wireName = r'CapabilitiesAuth';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CapabilitiesAuth object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(CapabilitiesAuthModeEnum),
    );
    yield r'csrf_header';
    yield serializers.serialize(
      object.csrfHeader,
      specifiedType: const FullType(String),
    );
    yield r'session_cookie';
    yield serializers.serialize(
      object.sessionCookie,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CapabilitiesAuth object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CapabilitiesAuthBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CapabilitiesAuthModeEnum),
          ) as CapabilitiesAuthModeEnum;
          result.mode = valueDes;
          break;
        case r'csrf_header':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.csrfHeader = valueDes;
          break;
        case r'session_cookie':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionCookie = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CapabilitiesAuth deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CapabilitiesAuthBuilder();
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


class CapabilitiesAuthModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'cookie_csrf')
  static const CapabilitiesAuthModeEnum cookieCsrf = _$capabilitiesAuthModeEnum_cookieCsrf;

  static Serializer<CapabilitiesAuthModeEnum> get serializer => _$capabilitiesAuthModeEnumSerializer;

  const CapabilitiesAuthModeEnum._(String name): super(name);

  static BuiltSet<CapabilitiesAuthModeEnum> get values => _$capabilitiesAuthModeEnumValues;
  static CapabilitiesAuthModeEnum valueOf(String name) => _$capabilitiesAuthModeEnumValueOf(name);
}

