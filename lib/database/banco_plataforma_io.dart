import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Roda em Android/iOS (sqflite nativo, não precisa configurar nada) e
/// em Windows/Linux/macOS (usa sqflite_common_ffi, que abre o banco via
/// FFI em vez de canal de plataforma nativo).
void configurarBancoDeDados() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
