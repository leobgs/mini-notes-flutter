import 'package:flutter_test/flutter_test.dart';
import 'package:mini_notes/models/note.dart';

void main() {
  test('Smoke test - Note data integrity', () {
    final note = Note(
      id: 'smoke-test',
      title: 'Smoke Test Note',
      content: 'Testing initial state',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(note.title, equals('Smoke Test Note'));
    expect(note.id, equals('smoke-test'));
  });
}
