# openapi.api.NotesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**capture**](NotesApi.md#capture) | **POST** /api/v1/capture | Quick capture (note, observation, or decision draft)
[**compareNoteRevisions**](NotesApi.md#comparenoterevisions) | **GET** /api/v1/notes/{noteId}/revisions/compare | Compare two note revisions (Markdown diff)
[**createNote**](NotesApi.md#createnote) | **POST** /api/v1/projects/{projectId}/notes | Create a note (appends initial revision)
[**deleteNote**](NotesApi.md#deletenote) | **DELETE** /api/v1/notes/{noteId} | Delete a note
[**getNote**](NotesApi.md#getnote) | **GET** /api/v1/notes/{noteId} | Get a note
[**listNoteRevisions**](NotesApi.md#listnoterevisions) | **GET** /api/v1/notes/{noteId}/revisions | List note revisions (newest first)
[**listNotes**](NotesApi.md#listnotes) | **GET** /api/v1/projects/{projectId}/notes | List notes
[**updateNote**](NotesApi.md#updatenote) | **PATCH** /api/v1/notes/{noteId} | Update a note (appends revision)


# **capture**
> CaptureResponse capture(captureRequest, idempotencyKey)

Quick capture (note, observation, or decision draft)

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

final api = Openapi().getNotesApi();
final CaptureRequest captureRequest = ; // CaptureRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.capture(captureRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotesApi->capture: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **captureRequest** | [**CaptureRequest**](CaptureRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**CaptureResponse**](CaptureResponse.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **compareNoteRevisions**
> RevisionComparison compareNoteRevisions(noteId, from, to)

Compare two note revisions (Markdown diff)

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

final api = Openapi().getNotesApi();
final String noteId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String from = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String to = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.compareNoteRevisions(noteId, from, to);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotesApi->compareNoteRevisions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **noteId** | **String**|  | 
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

# **createNote**
> Note createNote(projectId, noteCreateRequest, idempotencyKey)

Create a note (appends initial revision)

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

final api = Openapi().getNotesApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final NoteCreateRequest noteCreateRequest = ; // NoteCreateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.createNote(projectId, noteCreateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotesApi->createNote: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **noteCreateRequest** | [**NoteCreateRequest**](NoteCreateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Note**](Note.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNote**
> deleteNote(noteId, idempotencyKey, csrfBody)

Delete a note

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

final api = Openapi().getNotesApi();
final String noteId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.
final CsrfBody csrfBody = ; // CsrfBody | 

try {
    api.deleteNote(noteId, idempotencyKey, csrfBody);
} on DioException catch (e) {
    print('Exception when calling NotesApi->deleteNote: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **noteId** | **String**|  | 
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

# **getNote**
> Note getNote(noteId)

Get a note

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

final api = Openapi().getNotesApi();
final String noteId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getNote(noteId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotesApi->getNote: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **noteId** | **String**|  | 

### Return type

[**Note**](Note.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNoteRevisions**
> RevisionPage listNoteRevisions(noteId)

List note revisions (newest first)

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

final api = Openapi().getNotesApi();
final String noteId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.listNoteRevisions(noteId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotesApi->listNoteRevisions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **noteId** | **String**|  | 

### Return type

[**RevisionPage**](RevisionPage.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNotes**
> NotePage listNotes(projectId, page, perPage)

List notes

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

final api = Openapi().getNotesApi();
final String projectId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int page = 56; // int | 
final int perPage = 56; // int | 

try {
    final response = api.listNotes(projectId, page, perPage);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotesApi->listNotes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectId** | **String**|  | 
 **page** | **int**|  | [optional] [default to 1]
 **perPage** | **int**|  | [optional] [default to 50]

### Return type

[**NotePage**](NotePage.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateNote**
> Note updateNote(noteId, noteUpdateRequest, idempotencyKey)

Update a note (appends revision)

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

final api = Openapi().getNotesApi();
final String noteId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final NoteUpdateRequest noteUpdateRequest = ; // NoteUpdateRequest | 
final String idempotencyKey = idempotencyKey_example; // String | Optional client-generated key for safe retries of mutating requests.

try {
    final response = api.updateNote(noteId, noteUpdateRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotesApi->updateNote: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **noteId** | **String**|  | 
 **noteUpdateRequest** | [**NoteUpdateRequest**](NoteUpdateRequest.md)|  | 
 **idempotencyKey** | **String**| Optional client-generated key for safe retries of mutating requests. | [optional] 

### Return type

[**Note**](Note.md)

### Authorization

[csrfToken](../README.md#csrfToken), [cookieAuth](../README.md#cookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

