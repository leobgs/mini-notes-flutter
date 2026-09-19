import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/note_list_screen.dart';
import 'services/note_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final noteService = NoteService();
  await noteService.init();

  runApp(const MiniNotesApp());
}

class MiniNotesApp extends StatelessWidget {
  const MiniNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NoteListScreen(),
    );
  }
}
