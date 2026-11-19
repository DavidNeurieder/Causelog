//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'setup_status.g.dart';

/// SetupStatus
///
/// Properties:
/// * [setupRequired] 
@BuiltValue()
abstract class SetupStatus implements Built<SetupStatus, SetupStatusBuilder> {
  @BuiltValueField(wireName: r'setup_required')
  bool get setupRequired;

  SetupStatus._();

  factory SetupStatus([void updates(SetupStatusBuilder b)]) = _$SetupStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetupStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetupStatus> get serializer => _$SetupStatusSerializer();
}

class _$SetupStatusSerializer implements PrimitiveSerializer<SetupStatus> {
  @override
  final Iterable<Type> types = const [SetupStatus, _$SetupStatus];

  @override
  final String wireName = r'SetupStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetupStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'setup_required';
    yield serializers.serialize(
      object.setupRequired,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SetupStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetupStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'setup_required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.setupRequired = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SetupStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetupStatusBuilder();
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


