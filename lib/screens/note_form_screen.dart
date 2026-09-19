import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class NoteFormScreen extends StatefulWidget {
  final String? noteId;

  const NoteFormScreen({super.key, this.noteId});

  bool get isEditing => noteId != null;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NoteService _noteService = NoteService();

  Note? _originalNote;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _originalNote = _noteService.getNote(widget.noteId!);
      if (_originalNote != null) {
        _titleController.text = _originalNote!.title;
        _contentController.text = _originalNote!.content;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (widget.isEditing) {
      if (_originalNote == null) return false;
      return title != _originalNote!.title || content != _originalNote!.content;
    } else {
      return title.isNotEmpty || content.isNotEmpty;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final title = _titleController.text;
      final content = _contentController.text;

      if (widget.isEditing) {
        await _noteService.updateNote(
          id: widget.noteId!,
          title: title,
          content: content,
        );
      } else {
        await _noteService.addNote(title: title, content: content);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Catatan berhasil diperbarui'
                  : 'Catatan baru berhasil ditambahkan',
            ),
            backgroundColor: const Color(0xFF10B981), // Emerald 500
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Catatan?'),
        content: const Text(
          'Catatan ini akan dihapus secara permanen dan tidak dapat dipulihkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _noteService.deleteNote(widget.noteId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan telah dihapus'),
            backgroundColor: Color(0xFF64748B),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Buang Perubahan?'),
            content: const Text(
              'Ada perubahan yang belum disimpan. Yakin ingin keluar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tetap di Sini'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Buang'),
              ),
            ],
          ),
        );
        if (shouldLeave == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Catatan' : 'Catatan Baru'),
          actions: [
            if (widget.isEditing)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                ),
                tooltip: 'Hapus Catatan',
                onPressed: _isSubmitting ? null : _confirmDelete,
              ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _handleSave,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: const Text('Simpan'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  autofocus: !widget.isEditing,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Judul Catatan *',
                    hintText: 'Contoh: Rencana Belajar Flutter',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: Icon(Icons.title, color: Color(0xFF6366F1)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Content Field
                TextFormField(
                  controller: _contentController,
                  textInputAction: TextInputAction.newline,
                  maxLines: 14,
                  minLines: 8,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF334155),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    hintText: 'Tuliskan detail catatanmu di sini...',
                    alignLabelWithHint: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 120),
                      child: Icon(Icons.notes, color: Color(0xFF6366F1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
