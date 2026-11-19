//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'capture_response.g.dart';

/// CaptureResponse
///
/// Properties:
/// * [kind] 
/// * [id] 
@BuiltValue()
abstract class CaptureResponse implements Built<CaptureResponse, CaptureResponseBuilder> {
  @BuiltValueField(wireName: r'kind')
  CaptureResponseKindEnum get kind;
  // enum kindEnum {  note,  observation,  decision_draft,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  CaptureResponse._();

  factory CaptureResponse([void updates(CaptureResponseBuilder b)]) = _$CaptureResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CaptureResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CaptureResponse> get serializer => _$CaptureResponseSerializer();
}

class _$CaptureResponseSerializer implements PrimitiveSerializer<CaptureResponse> {
  @override
  final Iterable<Type> types = const [CaptureResponse, _$CaptureResponse];

  @override
  final String wireName = r'CaptureResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CaptureResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(CaptureResponseKindEnum),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CaptureResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CaptureResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CaptureResponseKindEnum),
          ) as CaptureResponseKindEnum;
          result.kind = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CaptureResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CaptureResponseBuilder();
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


class CaptureResponseKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'note')
  static const CaptureResponseKindEnum note = _$captureResponseKindEnum_note;
  @BuiltValueEnumConst(wireName: r'observation')
  static const CaptureResponseKindEnum observation = _$captureResponseKindEnum_observation;
  @BuiltValueEnumConst(wireName: r'decision_draft')
  static const CaptureResponseKindEnum decisionDraft = _$captureResponseKindEnum_decisionDraft;

  static Serializer<CaptureResponseKindEnum> get serializer => _$captureResponseKindEnumSerializer;

  const CaptureResponseKindEnum._(String name): super(name);

  static BuiltSet<CaptureResponseKindEnum> get values => _$captureResponseKindEnumValues;
  static CaptureResponseKindEnum valueOf(String name) => _$captureResponseKindEnumValueOf(name);
}

