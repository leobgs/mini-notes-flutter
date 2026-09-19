import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NoteService {
  static const String boxName = 'notes_box';
  static final NoteService _instance = NoteService._internal();

  factory NoteService() => _instance;

  NoteService._internal();

  late Box<Note> _box;
  final Uuid _uuid = const Uuid();

  /// Initialize Hive, register adapters, open box and seed initial data if needed
  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }

    _box = await Hive.openBox<Note>(boxName);

    // Seed sample notes if box is completely empty for a great first-time experience
    if (_box.isEmpty) {
      await _seedSampleNotes();
    }
  }

  Box<Note> get box => _box;

  /// Returns ValueListenable for reactive UI updates
  ValueListenable<Box<Note>> getListenable() {
    return _box.listenable();
  }

  /// Get all notes sorted by updatedAt descending
  List<Note> getAllNotes() {
    final notes = _box.values.toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// Get note by ID
  Note? getNote(String id) {
    try {
      return _box.get(id);
    } catch (_) {
      return null;
    }
  }

  /// Add a new note
  Future<Note> addNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title.trim(),
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _box.put(note.id, note);
    return note;
  }

  /// Update an existing note
  Future<Note?> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final existing = _box.get(id);
    if (existing == null) return null;

    final updated = existing.copyWith(
      title: title.trim(),
      content: content.trim(),
      updatedAt: DateTime.now(),
    );

    await _box.put(id, updated);
    return updated;
  }

  /// Delete note by ID
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  /// Seed initial notes for demonstration
  Future<void> _seedSampleNotes() async {
    final now = DateTime.now();
    final sampleNotes = [
      Note(
        id: _uuid.v4(),
        title: 'Selamat Datang di Mini Notes! 📝',
        content: 'Aplikasi catatan modern yang cepat dan ringan.\n'
            '• Simpan catatan secara lokal dengan Hive CE.\n'
            '• Tap catatan untuk mengedit atau melihat detail.\n'
            '• Tekan tombol + di pojok kanan bawah untuk menambah catatan baru.',
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
      ),
      Note(
        id: _uuid.v4(),
        title: 'Tips & Shortcut 💡',
        content: '• Kamu bisa menghapus catatan lewat tombol hapus pada card atau di dalam halaman edit.\n'
            '• Judul catatan wajib diisi, sedangkan isi catatan bersifat opsional.\n'
            '• Semua perubahan disimpan seketika di local storage.',
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];

    for (final note in sampleNotes) {
      await _box.put(note.id, note);
    }
  }
}
