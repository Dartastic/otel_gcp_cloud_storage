// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_gcp_cloud_storage_suppression.dart';

const _tracerName = 'dartastic_otel_libs_gcp_cloud_storage';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class GcpCloudStorageResult {
  const GcpCloudStorageResult({
    this.project,
    this.bucket,
    this.location,
    this.locationType,
    this.storageClass,
    this.objectName,
    this.objectSizeBytes,
    this.bytesTransferred,
    this.contentType,
    this.generation,
    this.metageneration,
    this.crc32c,
    this.md5Hash,
    this.kmsKeyName,
    this.customerEncrypted,
    this.compose,
    this.composeComponentCount,
    this.resumableUploadId,
    this.iamRole,
    this.signedUrlMethod,
    this.signedUrlExpiresSec,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// GCP project id.
  final String? project;

  final String? bucket;

  /// Bucket location (`US`, `EU`, `ASIA`, `us-central1`, ...).
  final String? location;

  /// `region`, `dual-region`, `multi-region`.
  final String? locationType;

  /// `STANDARD`, `NEARLINE`, `COLDLINE`, `ARCHIVE`,
  /// `MULTI_REGIONAL`, `REGIONAL`, `DURABLE_REDUCED_AVAILABILITY`.
  final String? storageClass;

  final String? objectName;

  /// `metadata.size` (bytes).
  final int? objectSizeBytes;

  /// Bytes transferred so far on a resumable upload.
  final int? bytesTransferred;

  final String? contentType;

  final int? generation;
  final int? metageneration;

  final String? crc32c;
  final String? md5Hash;

  /// `projects/<p>/locations/<l>/keyRings/<r>/cryptoKeys/<k>`.
  final String? kmsKeyName;

  /// CSEK customer-supplied encryption key in use.
  final bool? customerEncrypted;

  /// `compose` operation flag + components count.
  final bool? compose;
  final int? composeComponentCount;

  final String? resumableUploadId;

  /// Caller principal's IAM role for the call (`roles/storage.objectViewer`,
  /// `roles/storage.objectAdmin`, ...).
  final String? iamRole;

  /// Signed URL HTTP method.
  final String? signedUrlMethod;
  final int? signedUrlExpiresSec;

  /// Google `error.status` (`OK`, `INVALID_ARGUMENT`, `NOT_FOUND`,
  /// `PERMISSION_DENIED`, `UNAUTHENTICATED`, `RESOURCE_EXHAUSTED`,
  /// `FAILED_PRECONDITION`, `ALREADY_EXISTS`, `ABORTED`, `INTERNAL`).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class GcpCloudStorageCallResult<T> {
  const GcpCloudStorageCallResult({required this.value, this.result});
  final T value;
  final GcpCloudStorageResult? result;
}

/// Wraps a GCS call in a CLIENT span. [operation] is one of
/// `objects.insert`, `objects.get`, `objects.update`, `objects.patch`,
/// `objects.copy`, `objects.compose`, `objects.delete`, `objects.list`,
/// `objects.watchAll`, `objects.rewrite`, `objects.restore`,
/// `objects.bulkRestore`, `resumable.start`, `resumable.upload`,
/// `resumable.status`, `signedUrl.v4`, `signedUrl.v2`,
/// `buckets.insert`, `buckets.get`, `buckets.patch`, `buckets.delete`,
/// `buckets.list`, `buckets.lockRetentionPolicy`,
/// `iam.getIamPolicy`, `iam.setIamPolicy`, `iam.testIamPermissions`,
/// `acl.list`, `acl.update`, `notifications.insert`, `notifications.list`,
/// `notifications.delete`, `hmacKeys.create`, `hmacKeys.list`,
/// `hmacKeys.delete`, `serviceAccount.get`.
Future<T> tracedGcpCloudStorage<T>({
  required String operation,
  required Future<GcpCloudStorageCallResult<T>> Function() invoke,
}) async {
  if (gcpCloudStorageInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'gcp_cloud_storage',
    'rpc.method': operation,
    'gcp_cloud_storage.operation': operation,
  };

  final span = _tracer().startSpan(
    'gcp_cloud_storage $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.project != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.project',
          res.project!,
        ));
      }
      if (res.bucket != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.bucket',
          res.bucket!,
        ));
      }
      if (res.location != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.location',
          res.location!,
        ));
      }
      if (res.locationType != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.location.type',
          res.locationType!,
        ));
      }
      if (res.storageClass != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.storage_class',
          res.storageClass!,
        ));
      }
      if (res.objectName != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.object.name',
          res.objectName!,
        ));
      }
      if (res.objectSizeBytes != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_storage.object.size_bytes',
          res.objectSizeBytes!,
        ));
      }
      if (res.bytesTransferred != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_storage.bytes_transferred',
          res.bytesTransferred!,
        ));
      }
      if (res.contentType != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.content_type',
          res.contentType!,
        ));
      }
      if (res.generation != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_storage.generation',
          res.generation!,
        ));
      }
      if (res.metageneration != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_storage.metageneration',
          res.metageneration!,
        ));
      }
      if (res.crc32c != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.crc32c',
          res.crc32c!,
        ));
      }
      if (res.md5Hash != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.md5_hash',
          res.md5Hash!,
        ));
      }
      if (res.kmsKeyName != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.kms.key_name',
          res.kmsKeyName!,
        ));
      }
      if (res.customerEncrypted != null) {
        extras.add(OTel.attributeBool(
          'gcp_cloud_storage.csek',
          res.customerEncrypted!,
        ));
      }
      if (res.compose != null) {
        extras.add(OTel.attributeBool(
          'gcp_cloud_storage.compose',
          res.compose!,
        ));
      }
      if (res.composeComponentCount != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_storage.compose.component_count',
          res.composeComponentCount!,
        ));
      }
      if (res.resumableUploadId != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.resumable.upload_id',
          res.resumableUploadId!,
        ));
      }
      if (res.iamRole != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.iam.role',
          res.iamRole!,
        ));
      }
      if (res.signedUrlMethod != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.signed_url.method',
          res.signedUrlMethod!,
        ));
      }
      if (res.signedUrlExpiresSec != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_storage.signed_url.expires_sec',
          res.signedUrlExpiresSec!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.error.code',
          res.errorCode!,
        ));
        if (res.errorCode != 'OK') {
          span.setStatus(SpanStatusCode.Error, 'GCS ${res.errorCode}');
        }
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_storage.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'GCS HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
