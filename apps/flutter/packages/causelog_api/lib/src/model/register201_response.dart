//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register201_response.g.dart';

/// Register201Response
///
/// Properties:
/// * [pendingApproval] 
@BuiltValue()
abstract class Register201Response implements Built<Register201Response, Register201ResponseBuilder> {
  @BuiltValueField(wireName: r'pending_approval')
  bool get pendingApproval;

  Register201Response._();

  factory Register201Response([void updates(Register201ResponseBuilder b)]) = _$Register201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Register201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Register201Response> get serializer => _$Register201ResponseSerializer();
}

class _$Register201ResponseSerializer implements PrimitiveSerializer<Register201Response> {
  @override
  final Iterable<Type> types = const [Register201Response, _$Register201Response];

  @override
  final String wireName = r'Register201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Register201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pending_approval';
    yield serializers.serialize(
      object.pendingApproval,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Register201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Register201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pending_approval':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pendingApproval = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Register201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Register201ResponseBuilder();
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


