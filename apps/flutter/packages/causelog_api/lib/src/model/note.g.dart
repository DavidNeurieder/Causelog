// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NoteSourceTypeEnum _$noteSourceTypeEnum_experiment =
    const NoteSourceTypeEnum._('experiment');
const NoteSourceTypeEnum _$noteSourceTypeEnum_decision =
    const NoteSourceTypeEnum._('decision');

NoteSourceTypeEnum _$noteSourceTypeEnumValueOf(String name) {
  switch (name) {
    case 'experiment':
      return _$noteSourceTypeEnum_experiment;
    case 'decision':
      return _$noteSourceTypeEnum_decision;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<NoteSourceTypeEnum> _$noteSourceTypeEnumValues =
    BuiltSet<NoteSourceTypeEnum>(const <NoteSourceTypeEnum>[
  _$noteSourceTypeEnum_experiment,
  _$noteSourceTypeEnum_decision,
]);

Serializer<NoteSourceTypeEnum> _$noteSourceTypeEnumSerializer =
    _$NoteSourceTypeEnumSerializer();

class _$NoteSourceTypeEnumSerializer
    implements PrimitiveSerializer<NoteSourceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'experiment': 'experiment',
    'decision': 'decision',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'experiment': 'experiment',
    'decision': 'decision',
  };

  @override
  final Iterable<Type> types = const <Type>[NoteSourceTypeEnum];
  @override
  final String wireName = 'NoteSourceTypeEnum';

  @override
  Object serialize(Serializers serializers, NoteSourceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  NoteSourceTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      NoteSourceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Note extends Note {
  @override
  final String id;
  @override
  final String projectId;
  @override
  final String title;
  @override
  final String body;
  @override
  final NoteSourceTypeEnum? sourceType;
  @override
  final String? sourceId;
  @override
  final String? createdBy;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;

  factory _$Note([void Function(NoteBuilder)? updates]) =>
      (NoteBuilder()..update(updates))._build();

  _$Note._(
      {required this.id,
      required this.projectId,
      required this.title,
      required this.body,
      this.sourceType,
      this.sourceId,
      this.createdBy,
      required this.createdAtMs,
      required this.updatedAtMs})
      : super._();
  @override
  Note rebuild(void Function(NoteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NoteBuilder toBuilder() => NoteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Note &&
        id == other.id &&
        projectId == other.projectId &&
        title == other.title &&
        body == other.body &&
        sourceType == other.sourceType &&
        sourceId == other.sourceId &&
        createdBy == other.createdBy &&
        createdAtMs == other.createdAtMs &&
        updatedAtMs == other.updatedAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, sourceType.hashCode);
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jc(_$hash, updatedAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Note')
          ..add('id', id)
          ..add('projectId', projectId)
          ..add('title', title)
          ..add('body', body)
          ..add('sourceType', sourceType)
          ..add('sourceId', sourceId)
          ..add('createdBy', createdBy)
          ..add('createdAtMs', createdAtMs)
          ..add('updatedAtMs', updatedAtMs))
        .toString();
  }
}

class NoteBuilder implements Builder<Note, NoteBuilder> {
  _$Note? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  NoteSourceTypeEnum? _sourceType;
  NoteSourceTypeEnum? get sourceType => _$this._sourceType;
  set sourceType(NoteSourceTypeEnum? sourceType) =>
      _$this._sourceType = sourceType;

  String? _sourceId;
  String? get sourceId => _$this._sourceId;
  set sourceId(String? sourceId) => _$this._sourceId = sourceId;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  int? _updatedAtMs;
  int? get updatedAtMs => _$this._updatedAtMs;
  set updatedAtMs(int? updatedAtMs) => _$this._updatedAtMs = updatedAtMs;

  NoteBuilder() {
    Note._defaults(this);
  }

  NoteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _projectId = $v.projectId;
      _title = $v.title;
      _body = $v.body;
      _sourceType = $v.sourceType;
      _sourceId = $v.sourceId;
      _createdBy = $v.createdBy;
      _createdAtMs = $v.createdAtMs;
      _updatedAtMs = $v.updatedAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Note other) {
    _$v = other as _$Note;
  }

  @override
  void update(void Function(NoteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Note build() => _build();

  _$Note _build() {
    final _$result = _$v ??
        _$Note._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Note', 'id'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'Note', 'projectId'),
          title: BuiltValueNullFieldError.checkNotNull(title, r'Note', 'title'),
          body: BuiltValueNullFieldError.checkNotNull(body, r'Note', 'body'),
          sourceType: sourceType,
          sourceId: sourceId,
          createdBy: createdBy,
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'Note', 'createdAtMs'),
          updatedAtMs: BuiltValueNullFieldError.checkNotNull(
              updatedAtMs, r'Note', 'updatedAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
