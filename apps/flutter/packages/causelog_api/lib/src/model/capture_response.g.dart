// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CaptureResponseKindEnum _$captureResponseKindEnum_note =
    const CaptureResponseKindEnum._('note');
const CaptureResponseKindEnum _$captureResponseKindEnum_observation =
    const CaptureResponseKindEnum._('observation');
const CaptureResponseKindEnum _$captureResponseKindEnum_decisionDraft =
    const CaptureResponseKindEnum._('decisionDraft');

CaptureResponseKindEnum _$captureResponseKindEnumValueOf(String name) {
  switch (name) {
    case 'note':
      return _$captureResponseKindEnum_note;
    case 'observation':
      return _$captureResponseKindEnum_observation;
    case 'decisionDraft':
      return _$captureResponseKindEnum_decisionDraft;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CaptureResponseKindEnum> _$captureResponseKindEnumValues =
    BuiltSet<CaptureResponseKindEnum>(const <CaptureResponseKindEnum>[
  _$captureResponseKindEnum_note,
  _$captureResponseKindEnum_observation,
  _$captureResponseKindEnum_decisionDraft,
]);

Serializer<CaptureResponseKindEnum> _$captureResponseKindEnumSerializer =
    _$CaptureResponseKindEnumSerializer();

class _$CaptureResponseKindEnumSerializer
    implements PrimitiveSerializer<CaptureResponseKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'note': 'note',
    'observation': 'observation',
    'decisionDraft': 'decision_draft',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'note': 'note',
    'observation': 'observation',
    'decision_draft': 'decisionDraft',
  };

  @override
  final Iterable<Type> types = const <Type>[CaptureResponseKindEnum];
  @override
  final String wireName = 'CaptureResponseKindEnum';

  @override
  Object serialize(Serializers serializers, CaptureResponseKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CaptureResponseKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CaptureResponseKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CaptureResponse extends CaptureResponse {
  @override
  final CaptureResponseKindEnum kind;
  @override
  final String id;

  factory _$CaptureResponse([void Function(CaptureResponseBuilder)? updates]) =>
      (CaptureResponseBuilder()..update(updates))._build();

  _$CaptureResponse._({required this.kind, required this.id}) : super._();
  @override
  CaptureResponse rebuild(void Function(CaptureResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CaptureResponseBuilder toBuilder() => CaptureResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CaptureResponse && kind == other.kind && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CaptureResponse')
          ..add('kind', kind)
          ..add('id', id))
        .toString();
  }
}

class CaptureResponseBuilder
    implements Builder<CaptureResponse, CaptureResponseBuilder> {
  _$CaptureResponse? _$v;

  CaptureResponseKindEnum? _kind;
  CaptureResponseKindEnum? get kind => _$this._kind;
  set kind(CaptureResponseKindEnum? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  CaptureResponseBuilder() {
    CaptureResponse._defaults(this);
  }

  CaptureResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CaptureResponse other) {
    _$v = other as _$CaptureResponse;
  }

  @override
  void update(void Function(CaptureResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CaptureResponse build() => _build();

  _$CaptureResponse _build() {
    final _$result = _$v ??
        _$CaptureResponse._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'CaptureResponse', 'kind'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CaptureResponse', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
