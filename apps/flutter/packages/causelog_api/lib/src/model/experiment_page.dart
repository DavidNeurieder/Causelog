//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/experiment.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/page_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment_page.g.dart';

/// ExperimentPage
///
/// Properties:
/// * [items] 
/// * [page] 
@BuiltValue()
abstract class ExperimentPage implements Built<ExperimentPage, ExperimentPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Experiment> get items;

  @BuiltValueField(wireName: r'page')
  PageInfo get page;

  ExperimentPage._();

  factory ExperimentPage([void updates(ExperimentPageBuilder b)]) = _$ExperimentPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExperimentPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExperimentPage> get serializer => _$ExperimentPageSerializer();
}

class _$ExperimentPageSerializer implements PrimitiveSerializer<ExperimentPage> {
  @override
  final Iterable<Type> types = const [ExperimentPage, _$ExperimentPage];

  @override
  final String wireName = r'ExperimentPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExperimentPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Experiment)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(PageInfo),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExperimentPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExperimentPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Experiment)]),
          ) as BuiltList<Experiment>;
          result.items.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PageInfo),
          ) as PageInfo;
          result.page.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExperimentPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExperimentPageBuilder();
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


