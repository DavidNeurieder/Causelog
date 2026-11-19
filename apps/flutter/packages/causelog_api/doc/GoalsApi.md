# openapi.api.GoalsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createGoal**](GoalsApi.md#creategoal) | **POST** /api/v1/projects/{projectId}/goals | Create a goal
[**deleteGoal**](GoalsApi.md#deletegoal) | **DELETE** /api/v1/goals/{goalId} | Delete a goal
[**getGoal**](GoalsApi.md#getgoal) | **GET** /api/v1/goals/{goalId} | Get a goal
[**listGoals**](GoalsApi.md#listgoals) | **GET** /api/v1/projects/{projectId}/goals | List goals
[**updateGoal**](GoalsApi.md#updategoal) | **PATCH** /api/v1/goals/{goalId} | Update a goal


# **createGoal**
> Goal createGoal(projectId, goalCreateRequest, idempotencyKey)

Create a goal

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

final api = Openapi().getGoalsApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final GoalCreateRequest goalCreateRequest = ; // GoalCreateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.createGoal(projectId, goalCreateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GoalsApi->createGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **goalCreateRequest** | [**GoalCreateRequest**](GoalCreateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Goal**](Goal.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteGoal**
> deleteGoal(goalId, idempotencyKey, csrfBody)

Delete a goal

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

final api = Openapi().getGoalsApi();
final String goalId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.
final CsrfBody csrfBody = ; // CsrfBody | 

try {
    api.deleteGoal(goalId, idempotencyKey, csrfBody);
} on DioException catch (e) {
    print('Exception when calling GoalsApi->deleteGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalId** | **String**|  | 
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

# **getGoal**
> Goal getGoal(goalId)

Get a goal

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

final api = Openapi().getGoalsApi();
final String goalId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getGoal(goalId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GoalsApi->getGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalId** | **String**|  | 

### Return type

[**Goal**](Goal.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGoals**
> GoalPage listGoals(projectId, page, perPage, status)

List goals

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

final api = Openapi().getGoalsApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int page = 56; // int | 
final int perPage = 56; // int | 
final GoalStatus status = ; // GoalStatus | 

try {
    final response = api.listGoals(projectId, page, perPage, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GoalsApi->listGoals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **page** | **int**|  | [optional] [default to 1]
 **perPage** | **int**|  | [optional] [default to 50]
 **status** | [**GoalStatus**](.md)|  | [optional] 

### Return type

[**GoalPage**](GoalPage.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateGoal**
> Goal updateGoal(goalId, goalUpdateRequest, idempotencyKey)

Update a goal

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

final api = Openapi().getGoalsApi();
final String goalId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final GoalUpdateRequest goalUpdateRequest = ; // GoalUpdateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.updateGoal(goalId, goalUpdateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GoalsApi->updateGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalId** | **String**|  | 
 **goalUpdateRequest** | [**GoalUpdateRequest**](GoalUpdateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Goal**](Goal.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

