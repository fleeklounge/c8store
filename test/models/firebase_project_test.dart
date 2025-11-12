import 'package:flutter_test/flutter_test.dart';
import 'package:c8store/models/firebase_project.dart';

void main() {
  group('FirebaseProject', () {
    test('creates valid project', () {
      final connectedAt = DateTime.parse('2025-11-12T10:00:00Z');

      final project = FirebaseProject(
        projectId: 'test-project',
        projectNumber: '123456789',
        displayName: 'Test Project',
        location: 'us-central1',
        connectedAt: connectedAt,
        customLabel: 'Test Label',
      );

      expect(project.projectId, 'test-project');
      expect(project.projectNumber, '123456789');
      expect(project.displayName, 'Test Project');
      expect(project.location, 'us-central1');
      expect(project.connectedAt, connectedAt);
      expect(project.customLabel, 'Test Label');
    });

    test('validates required fields', () {
      final connectedAt = DateTime.now();

      expect(
        () => FirebaseProject(
          projectId: '',
          projectNumber: '123',
          displayName: 'Test',
          connectedAt: connectedAt,
        ),
        throwsArgumentError,
      );

      expect(
        () => FirebaseProject(
          projectId: 'test',
          projectNumber: '',
          displayName: 'Test',
          connectedAt: connectedAt,
        ),
        throwsArgumentError,
      );

      expect(
        () => FirebaseProject(
          projectId: 'test',
          projectNumber: '123',
          displayName: '',
          connectedAt: connectedAt,
        ),
        throwsArgumentError,
      );
    });

    test('serializes to JSON correctly', () {
      final connectedAt = DateTime.parse('2025-11-12T10:00:00Z');

      final project = FirebaseProject(
        projectId: 'test-project',
        projectNumber: '123456789',
        displayName: 'Test Project',
        location: 'us-central1',
        connectedAt: connectedAt,
        customLabel: 'Test Label',
      );

      final json = project.toJson();

      expect(json['projectId'], 'test-project');
      expect(json['projectNumber'], '123456789');
      expect(json['displayName'], 'Test Project');
      expect(json['location'], 'us-central1');
      expect(json['connectedAt'], connectedAt.toIso8601String());
      expect(json['customLabel'], 'Test Label');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'projectId': 'test-project',
        'projectNumber': '123456789',
        'displayName': 'Test Project',
        'location': 'us-central1',
        'connectedAt': '2025-11-12T10:00:00.000Z',
        'customLabel': 'Test Label',
      };

      final project = FirebaseProject.fromJson(json);

      expect(project.projectId, 'test-project');
      expect(project.projectNumber, '123456789');
      expect(project.displayName, 'Test Project');
      expect(project.location, 'us-central1');
      expect(project.connectedAt, DateTime.parse('2025-11-12T10:00:00Z'));
      expect(project.customLabel, 'Test Label');
    });

    test('round-trip serialization works', () {
      final original = FirebaseProject(
        projectId: 'test-project',
        projectNumber: '123456789',
        displayName: 'Test Project',
        location: 'us-central1',
        connectedAt: DateTime.parse('2025-11-12T10:00:00Z'),
        customLabel: 'Test Label',
      );

      final json = original.toJson();
      final deserialized = FirebaseProject.fromJson(json);

      expect(deserialized.projectId, original.projectId);
      expect(deserialized.projectNumber, original.projectNumber);
      expect(deserialized.displayName, original.displayName);
      expect(deserialized.location, original.location);
      expect(deserialized.connectedAt, original.connectedAt);
      expect(deserialized.customLabel, original.customLabel);
    });

    test('copyWith creates new instance with updated values', () {
      final original = FirebaseProject(
        projectId: 'test-project',
        projectNumber: '123',
        displayName: 'Original',
        connectedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        displayName: 'Updated',
        customLabel: 'New Label',
      );

      expect(original.displayName, 'Original');
      expect(updated.displayName, 'Updated');
      expect(updated.projectId, original.projectId);
      expect(updated.customLabel, 'New Label');
    });

    test('equality works correctly', () {
      final connectedAt = DateTime.parse('2025-11-12T10:00:00Z');

      final project1 = FirebaseProject(
        projectId: 'test',
        projectNumber: '123',
        displayName: 'Test',
        connectedAt: connectedAt,
      );

      final project2 = FirebaseProject(
        projectId: 'test',
        projectNumber: '123',
        displayName: 'Test',
        connectedAt: connectedAt,
      );

      final project3 = FirebaseProject(
        projectId: 'different',
        projectNumber: '123',
        displayName: 'Test',
        connectedAt: connectedAt,
      );

      expect(project1, equals(project2));
      expect(project1, isNot(equals(project3)));
    });
  });
}
