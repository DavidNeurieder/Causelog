// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NoteCreateRequestSourceTypeEnum
    _$noteCreateRequestSourceTypeEnum_experiment =
    const NoteCreateRequestSourceTypeEnum._('experiment');
const NoteCreateRequestSourceTypeEnum
    _$noteCreateRequestSourceTypeEnum_decision =
    const NoteCreateRequestSourceTypeEnum._('decision');

NoteCreateRequestSourceTypeEnum _$noteCreateRequestSourceTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'experiment':
      return _$noteCreateRequestSourceTypeEnum_experiment;
    case 'decision':
      return _$noteCreateRequestSourceTypeEnum_decision;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<NoteCreateRequestSourceTypeEnum>
    _$noteCreateRequestSourceTypeEnumValues = BuiltSet<
        NoteCreateRequestSourceTypeEnum>(const <NoteCreateRequestSourceTypeEnum>[
  _$noteCreateRequestSourceTypeEnum_experiment,
  _$noteCreateRequestSourceTypeEnum_decision,
]);

Serializer<NoteCreateRequestSourceTypeEnum>
    _$noteCreateRequestSourceTypeEnumSerializer =
    _$NoteCreateRequestSourceTypeEnumSerializer();

class _$NoteCreateRequestSourceTypeEnumSerializer
    implements PrimitiveSerializer<NoteCreateRequestSourceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'experiment': 'experiment',
    'decision': 'decision',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'experiment': 'experiment',
    'decision': 'decision',
  };

  @override
  final Iterable<Type> types = const <Type>[NoteCreateRequestSourceTypeEnum];
  @override
  final String wireName = 'NoteCreateRequestSourceTypeEnum';

  @override
  Object serialize(
          Serializers serializers, NoteCreateRequestSourceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  NoteCreateRequestSourceTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      NoteCreateRequestSourceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$NoteCreateRequest extends NoteCreateRequest {
  @override
  final String? sourceId;
  @override
  final NoteCreateRequestSourceTypeEnum? sourceType;
  @override
  final String title;
  @override
  final String? body;
  @override
  final String? csrfToken;

  factory _$NoteCreateRequest(
          [void Function(NoteCreateRequestBuilder)? updates]) =>
      (NoteCreateRequestBuilder()..update(updates))._build();

  _$NoteCreateRequest._(
      {this.sourceId,
      this.sourceType,
      required this.title,
      this.body,
      this.csrfToken})
      : super._();
  @override
  NoteCreateRequest rebuild(void Function(NoteCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NoteCreateRequestBuilder toBuilder() =>
      NoteCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NoteCreateRequest &&
        sourceId == other.sourceId &&
        sourceType == other.sourceType &&
        title == other.title &&
        body == other.body &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, sourceType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NoteCreateRequest')
          ..add('sourceId', sourceId)
          ..add('sourceType', sourceType)
          ..add('title', title)
          ..add('body', body)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class NoteCreateRequestBuilder
    implements
        Builder<NoteCreateRequest, NoteCreateRequestBuilder>,
        CsrfBodyBuilder {
  _$NoteCreateRequest? _$v;

  String? _sourceId;
  String? get sourceId => _$this._sourceId;
  set sourceId(covariant String? sourceId) => _$this._sourceId = sourceId;

  NoteCreateRequestSourceTypeEnum? _sourceType;
  NoteCreateRequestSourceTypeEnum? get sourceType => _$this._sourceType;
  set sourceType(covariant NoteCreateRequestSourceTypeEnum? sourceType) =>
      _$this._sourceType = sourceType;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(covariant String? body) => _$this._body = body;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  NoteCreateRequestBuilder() {
    NoteCreateRequest._defaults(this);
  }

  NoteCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceId = $v.sourceId;
      _sourceType = $v.sourceType;
      _title = $v.title;
      _body = $v.body;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant NoteCreateRequest other) {
    _$v = other as _$NoteCreateRequest;
  }

  @override
  void update(void Function(NoteCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NoteCreateRequest build() => _build();

  _$NoteCreateRequest _build() {
    final _$result = _$v ??
        _$NoteCreateRequest._(
          sourceId: sourceId,
          sourceType: sourceType,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'NoteCreateRequest', 'title'),
          body: body,
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
