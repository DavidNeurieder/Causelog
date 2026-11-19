# openapi.api.DecisionsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**compareDecisionRevisions**](DecisionsApi.md#comparedecisionrevisions) | **GET** /api/v1/decisions/{decisionId}/revisions/compare | Compare two decision revisions (Markdown diff)
[**createDecision**](DecisionsApi.md#createdecision) | **POST** /api/v1/projects/{projectId}/decisions | Create a decision (appends initial revision)
[**deleteDecision**](DecisionsApi.md#deletedecision) | **DELETE** /api/v1/decisions/{decisionId} | Delete a decision
[**getDecision**](DecisionsApi.md#getdecision) | **GET** /api/v1/decisions/{decisionId} | Get a decision
[**listDecisionRevisions**](DecisionsApi.md#listdecisionrevisions) | **GET** /api/v1/decisions/{decisionId}/revisions | List decision revisions (newest first)
[**listDecisions**](DecisionsApi.md#listdecisions) | **GET** /api/v1/projects/{projectId}/decisions | List decisions
[**resolveDecision**](DecisionsApi.md#resolvedecision) | **POST** /api/v1/decisions/{decisionId}/resolve | Resolve a decision (appends revision)
[**updateDecision**](DecisionsApi.md#updatedecision) | **PATCH** /api/v1/decisions/{decisionId} | Update a decision (appends revision)


# **compareDecisionRevisions**
> RevisionComparison compareDecisionRevisions(decisionId, from, to)

Compare two decision revisions (Markdown diff)

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String decisionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String from = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String to = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.compareDecisionRevisions(decisionId, from, to);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->compareDecisionRevisions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **decisionId** | **String**|  | 
 **from** | **String**|  | 
 **to** | **String**|  | 

### Return type

[**RevisionComparison**](RevisionComparison.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createDecision**
> Decision createDecision(projectId, decisionCreateRequest, idempotencyKey)

Create a decision (appends initial revision)

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final DecisionCreateRequest decisionCreateRequest = ; // DecisionCreateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.createDecision(projectId, decisionCreateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->createDecision: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **decisionCreateRequest** | [**DecisionCreateRequest**](DecisionCreateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Decision**](Decision.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteDecision**
> deleteDecision(decisionId, idempotencyKey, csrfBody)

Delete a decision

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String decisionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.
final CsrfBody csrfBody = ; // CsrfBody | 

try {
    api.deleteDecision(decisionId, idempotencyKey, csrfBody);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->deleteDecision: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **decisionId** | **String**|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 
 **csrfBody** | [**CsrfBody**](CsrfBody.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDecision**
> Decision getDecision(decisionId)

Get a decision

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String decisionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getDecision(decisionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->getDecision: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **decisionId** | **String**|  | 

### Return type

[**Decision**](Decision.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDecisionRevisions**
> RevisionPage listDecisionRevisions(decisionId)

List decision revisions (newest first)

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String decisionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.listDecisionRevisions(decisionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->listDecisionRevisions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **decisionId** | **String**|  | 

### Return type

[**RevisionPage**](RevisionPage.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDecisions**
> DecisionPage listDecisions(projectId, page, perPage, status)

List decisions

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int page = 56; // int | 
final int perPage = 56; // int | 
final DecisionStatus status = ; // DecisionStatus | 

try {
    final response = api.listDecisions(projectId, page, perPage, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->listDecisions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **page** | **int**|  | [optional] [default to 1]
 **perPage** | **int**|  | [optional] [default to 50]
 **status** | [**DecisionStatus**](.md)|  | [optional] 

### Return type

[**DecisionPage**](DecisionPage.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resolveDecision**
> Decision resolveDecision(decisionId, decisionResolveRequest, idempotencyKey)

Resolve a decision (appends revision)

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String decisionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final DecisionResolveRequest decisionResolveRequest = ; // DecisionResolveRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.resolveDecision(decisionId, decisionResolveRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->resolveDecision: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **decisionId** | **String**|  | 
 **decisionResolveRequest** | [**DecisionResolveRequest**](DecisionResolveRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Decision**](Decision.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateDecision**
> Decision updateDecision(decisionId, decisionUpdateRequest, idempotencyKey)

Update a decision (appends revision)

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure API key authorization: csrfToken
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('csrfToken').apiKeyPrefix = 'Bearer';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = Openapi().getDecisionsApi();
final String decisionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final DecisionUpdateRequest decisionUpdateRequest = ; // DecisionUpdateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.updateDecision(decisionId, decisionUpdateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DecisionsApi->updateDecision: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **decisionId** | **String**|  | 
 **decisionUpdateRequest** | [**DecisionUpdateRequest**](DecisionUpdateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Decision**](Decision.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

