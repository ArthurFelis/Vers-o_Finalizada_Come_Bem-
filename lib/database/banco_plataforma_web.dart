import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Suporte experimental a SQLite no navegador (usa sqlite3.wasm).
/// Antes de rodar pelo navegador pela primeira vez, execute no
/// terminal, dentro da pasta do projeto:
///   dart run sqflite_common_ffi_web:setup
/// Isso baixa o sqlite3.wasm e o sqflite_sw.js para a pasta web/.
void configurarBancoDeDados() {
  databaseFactory = databaseFactoryFfiWeb;
}
