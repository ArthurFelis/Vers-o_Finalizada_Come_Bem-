/// BUG CORRIGIDO: antes, o app só configurava o banco de dados pra
/// desktop (Windows/Linux/macOS) e nunca pra navegador -- rodando pelo
/// Chrome/Edge, o sqflite não tinha nenhuma implementação disponível e
/// toda consulta ao banco falhava (é por isso que a home travava/dava
/// erro quando testado pelo navegador).
///
/// Agora escolhemos a implementação certa em tempo de compilação: se
/// `dart:io` existe (Android, iOS, Windows, Linux, macOS), usamos
/// `banco_plataforma_io.dart`; se `dart:html` existe (navegador), usamos
/// `banco_plataforma_web.dart`. Fazer isso com "export condicional" (em
/// vez de simplesmente importar os dois pacotes direto no main.dart) é
/// necessário porque `sqflite_common_ffi_web` só compila para web --
/// importando ele sem essa proteção, o app pararia de compilar em
/// Android/Windows/etc.
export 'banco_plataforma_stub.dart'
    if (dart.library.io) 'banco_plataforma_io.dart'
    if (dart.library.html) 'banco_plataforma_web.dart';
