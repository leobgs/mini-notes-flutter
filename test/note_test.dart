import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mini_notes/models/note.dart';
import 'package:mini_notes/screens/note_form_screen.dart';

void main() {
  group('Note Model Tests', () {
    test('Note creation and copyWith works properly', () {
      final now = DateTime.now();
      final note = Note(
        id: 'test-123',
        title: 'Judul Catatan',
        content: 'Isi catatan pengujian',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, 'test-123');
      expect(note.title, 'Judul Catatan');
      expect(note.content, 'Isi catatan pengujian');

      final updated = note.copyWith(title: 'Judul Baru');
      expect(updated.title, 'Judul Baru');
      expect(updated.id, 'test-123');
      expect(updated.content, 'Isi catatan pengujian');
    });

    test('Hive Box CRUD with NoteAdapter works properly', () async {
      final tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(NoteAdapter());
      }

      final box = await Hive.openBox<Note>('test_notes_box');

      final now = DateTime.now();
      final note = Note(
        id: 'note-crud-1',
        title: 'Beli Kebutuhan',
        content: 'Susu, Telur, Kopi',
        createdAt: now,
        updatedAt: now,
      );

      // Create
      await box.put(note.id, note);
      expect(box.length, 1);

      // Read
      final retrieved = box.get(note.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Beli Kebutuhan');
      expect(retrieved.content, 'Susu, Telur, Kopi');

      // Update
      final updatedNote = retrieved.copyWith(title: 'Beli Kebutuhan Mingguan');
      await box.put(note.id, updatedNote);
      final afterUpdate = box.get(note.id);
      expect(afterUpdate!.title, 'Beli Kebutuhan Mingguan');

      // Delete
      await box.delete(note.id);
      expect(box.get(note.id), isNull);
      expect(box.isEmpty, isTrue);

      await box.close();
      await tempDir.delete(recursive: true);
    });
  });

  group('NoteFormScreen UI & Validation Tests', () {
    testWidgets('Shows validation error when title is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NoteFormScreen(),
        ),
      );

      // Find the Simpan button
      final saveButton = find.widgetWithText(FilledButton, 'Simpan');
      expect(saveButton, findsOneWidget);

      // Tap Simpan with empty title
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Check validation message (Requirement 3: judul tidak boleh kosong)
      expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Renders input fields properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NoteFormScreen(),
        ),
      );

      expect(find.text('Catatan Baru'), findsOneWidget);
      expect(find.text('Judul Catatan *'), findsOneWidget);
      expect(find.text('Isi Catatan'), findsOneWidget);
    });
  });
}
