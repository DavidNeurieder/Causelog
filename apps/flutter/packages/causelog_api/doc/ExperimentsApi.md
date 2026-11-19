# openapi.api.ExperimentsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createExperiment**](ExperimentsApi.md#createexperiment) | **POST** /api/v1/projects/{projectId}/experiments | Create an experiment
[**createExperimentEvent**](ExperimentsApi.md#createexperimentevent) | **POST** /api/v1/experiments/{experimentId}/events | Add an observation/measurement/milestone
[**deleteExperiment**](ExperimentsApi.md#deleteexperiment) | **DELETE** /api/v1/experiments/{experimentId} | Delete an experiment
[**deleteExperimentEvent**](ExperimentsApi.md#deleteexperimentevent) | **DELETE** /api/v1/experiments/{experimentId}/events/{eventId} | Delete an experiment event
[**extractExperimentLesson**](ExperimentsApi.md#extractexperimentlesson) | **POST** /api/v1/experiments/{experimentId}/extract | Extract a lesson into a note
[**getExperiment**](ExperimentsApi.md#getexperiment) | **GET** /api/v1/experiments/{experimentId} | Get an experiment with events
[**listExperiments**](ExperimentsApi.md#listexperiments) | **GET** /api/v1/projects/{projectId}/experiments | List experiments
[**updateExperiment**](ExperimentsApi.md#updateexperiment) | **PATCH** /api/v1/experiments/{experimentId} | Update an experiment


# **createExperiment**
> Experiment createExperiment(projectId, experimentCreateRequest, idempotencyKey)

Create an experiment

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

final api = Openapi().getExperimentsApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ExperimentCreateRequest experimentCreateRequest = ; // ExperimentCreateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.createExperiment(projectId, experimentCreateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->createExperiment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **experimentCreateRequest** | [**ExperimentCreateRequest**](ExperimentCreateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Experiment**](Experiment.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createExperimentEvent**
> ExperimentEvent createExperimentEvent(experimentId, experimentEventCreateRequest, idempotencyKey)

Add an observation/measurement/milestone

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

final api = Openapi().getExperimentsApi();
final String experimentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ExperimentEventCreateRequest experimentEventCreateRequest = ; // ExperimentEventCreateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.createExperimentEvent(experimentId, experimentEventCreateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->createExperimentEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **experimentId** | **String**|  | 
 **experimentEventCreateRequest** | [**ExperimentEventCreateRequest**](ExperimentEventCreateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**ExperimentEvent**](ExperimentEvent.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteExperiment**
> deleteExperiment(experimentId, idempotencyKey, csrfBody)

Delete an experiment

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

final api = Openapi().getExperimentsApi();
final String experimentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.
final CsrfBody csrfBody = ; // CsrfBody | 

try {
    api.deleteExperiment(experimentId, idempotencyKey, csrfBody);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->deleteExperiment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **experimentId** | **String**|  | 
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

# **deleteExperimentEvent**
> deleteExperimentEvent(experimentId, eventId, idempotencyKey, csrfBody)

Delete an experiment event

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

final api = Openapi().getExperimentsApi();
final String experimentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String eventId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.
final CsrfBody csrfBody = ; // CsrfBody | 

try {
    api.deleteExperimentEvent(experimentId, eventId, idempotencyKey, csrfBody);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->deleteExperimentEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **experimentId** | **String**|  | 
 **eventId** | **String**|  | 
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

# **extractExperimentLesson**
> Note extractExperimentLesson(experimentId, extractLessonRequest, idempotencyKey)

Extract a lesson into a note

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

final api = Openapi().getExperimentsApi();
final String experimentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ExtractLessonRequest extractLessonRequest = ; // ExtractLessonRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.extractExperimentLesson(experimentId, extractLessonRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->extractExperimentLesson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **experimentId** | **String**|  | 
 **extractLessonRequest** | [**ExtractLessonRequest**](ExtractLessonRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Note**](Note.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExperiment**
> ExperimentDetail getExperiment(experimentId)

Get an experiment with events

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

final api = Openapi().getExperimentsApi();
final String experimentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getExperiment(experimentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->getExperiment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **experimentId** | **String**|  | 

### Return type

[**ExperimentDetail**](ExperimentDetail.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listExperiments**
> ExperimentPage listExperiments(projectId, page, perPage)

List experiments

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

final api = Openapi().getExperimentsApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int page = 56; // int | 
final int perPage = 56; // int | 

try {
    final response = api.listExperiments(projectId, page, perPage);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->listExperiments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **page** | **int**|  | [optional] [default to 1]
 **perPage** | **int**|  | [optional] [default to 50]

### Return type

[**ExperimentPage**](ExperimentPage.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateExperiment**
> Experiment updateExperiment(experimentId, experimentUpdateRequest, idempotencyKey)

Update an experiment

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

final api = Openapi().getExperimentsApi();
final String experimentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ExperimentUpdateRequest experimentUpdateRequest = ; // ExperimentUpdateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.updateExperiment(experimentId, experimentUpdateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExperimentsApi->updateExperiment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **experimentId** | **String**|  | 
 **experimentUpdateRequest** | [**ExperimentUpdateRequest**](ExperimentUpdateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Experiment**](Experiment.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

