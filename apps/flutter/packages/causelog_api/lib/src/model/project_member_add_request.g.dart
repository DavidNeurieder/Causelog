// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_member_add_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProjectMemberAddRequestRoleEnum _$projectMemberAddRequestRoleEnum_owner =
    const ProjectMemberAddRequestRoleEnum._('owner');
const ProjectMemberAddRequestRoleEnum _$projectMemberAddRequestRoleEnum_member =
    const ProjectMemberAddRequestRoleEnum._('member');

ProjectMemberAddRequestRoleEnum _$projectMemberAddRequestRoleEnumValueOf(
    String name) {
  switch (name) {
    case 'owner':
      return _$projectMemberAddRequestRoleEnum_owner;
    case 'member':
      return _$projectMemberAddRequestRoleEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProjectMemberAddRequestRoleEnum>
    _$projectMemberAddRequestRoleEnumValues = BuiltSet<
        ProjectMemberAddRequestRoleEnum>(const <ProjectMemberAddRequestRoleEnum>[
  _$projectMemberAddRequestRoleEnum_owner,
  _$projectMemberAddRequestRoleEnum_member,
]);

Serializer<ProjectMemberAddRequestRoleEnum>
    _$projectMemberAddRequestRoleEnumSerializer =
    _$ProjectMemberAddRequestRoleEnumSerializer();

class _$ProjectMemberAddRequestRoleEnumSerializer
    implements PrimitiveSerializer<ProjectMemberAddRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'owner': 'owner',
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'owner': 'owner',
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[ProjectMemberAddRequestRoleEnum];
  @override
  final String wireName = 'ProjectMemberAddRequestRoleEnum';

  @override
  Object serialize(
          Serializers serializers, ProjectMemberAddRequestRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProjectMemberAddRequestRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProjectMemberAddRequestRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProjectMemberAddRequest extends ProjectMemberAddRequest {
  @override
  final ProjectMemberAddRequestRoleEnum? role;
  @override
  final String userId;
  @override
  final String? csrfToken;

  factory _$ProjectMemberAddRequest(
          [void Function(ProjectMemberAddRequestBuilder)? updates]) =>
      (ProjectMemberAddRequestBuilder()..update(updates))._build();

  _$ProjectMemberAddRequest._({this.role, required this.userId, this.csrfToken})
      : super._();
  @override
  ProjectMemberAddRequest rebuild(
          void Function(ProjectMemberAddRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectMemberAddRequestBuilder toBuilder() =>
      ProjectMemberAddRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectMemberAddRequest &&
        role == other.role &&
        userId == other.userId &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectMemberAddRequest')
          ..add('role', role)
          ..add('userId', userId)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class ProjectMemberAddRequestBuilder
    implements
        Builder<ProjectMemberAddRequest, ProjectMemberAddRequestBuilder>,
        CsrfBodyBuilder {
  _$ProjectMemberAddRequest? _$v;

  ProjectMemberAddRequestRoleEnum? _role;
  ProjectMemberAddRequestRoleEnum? get role => _$this._role;
  set role(covariant ProjectMemberAddRequestRoleEnum? role) =>
      _$this._role = role;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(covariant String? userId) => _$this._userId = userId;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  ProjectMemberAddRequestBuilder() {
    ProjectMemberAddRequest._defaults(this);
  }

  ProjectMemberAddRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _userId = $v.userId;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ProjectMemberAddRequest other) {
    _$v = other as _$ProjectMemberAddRequest;
  }

  @override
  void update(void Function(ProjectMemberAddRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectMemberAddRequest build() => _build();

  _$ProjectMemberAddRequest _build() {
    final _$result = _$v ??
        _$ProjectMemberAddRequest._(
          role: role,
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'ProjectMemberAddRequest', 'userId'),
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
