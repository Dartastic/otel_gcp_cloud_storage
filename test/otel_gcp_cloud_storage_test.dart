// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_gcp_cloud_storage/otel_gcp_cloud_storage.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_gcp_cloud_storage-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('objects.insert records bucket + size + class + CSEK', () async {
    await tracedGcpCloudStorage<String>(
      operation: 'objects.insert',
      invoke: () async => const GcpCloudStorageCallResult(
        value: 'ok',
        result: GcpCloudStorageResult(
          project: 'proj-1',
          bucket: 'my-bucket',
          location: 'US',
          locationType: 'multi-region',
          storageClass: 'STANDARD',
          objectName: 'images/cat.jpg',
          objectSizeBytes: 312500,
          contentType: 'image/jpeg',
          customerEncrypted: true,
        ),
      ),
    );
    final a =
        attrsOf(spans.findSpanByName('gcp_cloud_storage objects.insert')!);
    expect(a['gcp_cloud_storage.storage_class'], 'STANDARD');
    expect(a['gcp_cloud_storage.csek'], true);
  });

  test('compose records component count', () async {
    await tracedGcpCloudStorage<String>(
      operation: 'objects.compose',
      invoke: () async => const GcpCloudStorageCallResult(
        value: 'ok',
        result: GcpCloudStorageResult(
          bucket: 'b1',
          compose: true,
          composeComponentCount: 32,
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName('gcp_cloud_storage objects.compose')!,
    );
    expect(a['gcp_cloud_storage.compose.component_count'], 32);
  });

  test('PERMISSION_DENIED sets span error', () async {
    await tracedGcpCloudStorage<String>(
      operation: 'objects.get',
      invoke: () async => const GcpCloudStorageCallResult(
        value: 'ok',
        result: GcpCloudStorageResult(
          errorCode: 'PERMISSION_DENIED',
          statusCode: 403,
        ),
      ),
    );
    expect(
      spans.findSpanByName('gcp_cloud_storage objects.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('OK is non-error', () async {
    await tracedGcpCloudStorage<String>(
      operation: 'objects.get',
      invoke: () async => const GcpCloudStorageCallResult(
        value: 'ok',
        result: GcpCloudStorageResult(errorCode: 'OK'),
      ),
    );
    expect(
      spans.findSpanByName('gcp_cloud_storage objects.get')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutGcpCloudStorageInstrumentationAsync(() async {
      await tracedGcpCloudStorage<String>(
        operation: 'buckets.list',
        invoke: () async => const GcpCloudStorageCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('gcp_cloud_storage '), isEmpty);
  });
}
