import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instancia = DatabaseHelper._interno();
  static Database? _bancoDeDados;

  factory DatabaseHelper() => instancia;

  DatabaseHelper._interno();

  Future<Database> get bancoDeDados async {
    if (_bancoDeDados != null) return _bancoDeDados!;
    _bancoDeDados = await _iniciarBanco();
    return _bancoDeDados!;
  }

  Future<Database> _iniciarBanco() async {
    String caminhoBanco = await getDatabasesPath();
    String caminhoCompleto = join(caminhoBanco, 'coma_bem.db');

    return await openDatabase(
      caminhoCompleto,
      // BUG CORRIGIDO: o schema mudou (novas tabelas e colunas), mas a
      // versão continuava "1". Quem já tinha instalado/testado o app
      // antes ficava com um banco antigo (sem 'usu_nm_usuario', sem
      // 'restaurante'/'prato'/'avaliacao') e nunca conseguia criar
      // conta nem logar. Subir a versão força o onUpgrade a rodar.
      // v4: adicionadas colunas de distância/tempo estimado no
      // restaurante (usadas nos cards da home) e dados de exemplo
      // pré-cadastrados, então a versão subiu mais uma vez.
      version: 4,
      onCreate: _criarTabelas,
      onUpgrade: _atualizarBanco,
    );
  }

  Future<void> _atualizarBanco(Database db, int versaoAntiga, int versaoNova) async {
    // Projeto ainda em desenvolvimento: a forma mais segura de garantir
    // que todo mundo fique com o schema novo é apagar as tabelas antigas
    // e recriar do zero (não há dados de produção a preservar).
    await db.execute('DROP TABLE IF EXISTS avaliacao');
    await db.execute('DROP TABLE IF EXISTS prato');
    await db.execute('DROP TABLE IF EXISTS restaurante');
    await db.execute('DROP TABLE IF EXISTS usuario');
    await _criarTabelas(db, versaoNova);
  }

  Future<void> _criarTabelas(Database db, int version) async {
    // BUG CORRIGIDO: antes só a tabela 'usuario' era criada. Como
    // 'restaurante', 'prato' e 'avaliacao' nunca existiam, qualquer
    // tentativa de cadastro travava com "no such table".
    await db.execute('''
      CREATE TABLE usuario (
        usu_id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        usu_nm_usuario TEXT NOT NULL,
        usu_tx_email TEXT NOT NULL UNIQUE,
        usu_tx_senha TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE restaurante (
        res_id_restaurante INTEGER PRIMARY KEY AUTOINCREMENT,
        res_nm_restaurante TEXT NOT NULL,
        res_nu_latitude TEXT,
        res_nu_longitude TEXT,
        res_ds_tipo_culinaria TEXT NOT NULL,
        res_tx_distancia TEXT,
        res_tx_tempo TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE prato (
        pra_id_prato INTEGER PRIMARY KEY AUTOINCREMENT,
        pra_nm_prato TEXT NOT NULL,
        pra_im_foto TEXT,
        pra_id_restaurante INTEGER NOT NULL,
        FOREIGN KEY (pra_id_restaurante) REFERENCES restaurante (res_id_restaurante)
      )
    ''');

    await db.execute('''
      CREATE TABLE avaliacao (
        avl_id_avaliacao INTEGER PRIMARY KEY AUTOINCREMENT,
        avl_nu_ranking INTEGER NOT NULL,
        avl_tx_recomendacao TEXT NOT NULL,
        avl_id_prato INTEGER NOT NULL,
        avl_id_usuario INTEGER NOT NULL,
        FOREIGN KEY (avl_id_prato) REFERENCES prato (pra_id_prato),
        FOREIGN KEY (avl_id_usuario) REFERENCES usuario (usu_id_usuario)
      )
    ''');

    await _popularDadosDeExemplo(db);
  }

  /// Recurso adicionado: alguns restaurantes/pratos de exemplo já
  /// cadastrados, pra a home não abrir vazia na primeira vez que o app
  /// roda. As fotos usam URLs de rede (Pexels), então a tela precisa
  /// diferenciar foto de rede (http) de foto local (câmera do usuário).
  Future<void> _popularDadosDeExemplo(Database db) async {
    final exemplos = [
      {
        'nome': 'Cantina Bella Nonna',
        'tipo': 'Italiana',
        'distancia': '1,2 km',
        'tempo': '30 min',
        'prato': 'Nhoque ao molho de tomate',
        'foto':
            'https://images.pexels.com/photos/11230993/pexels-photo-11230993.jpeg',
        'notas': [5, 5, 5, 4],
      },
      {
        'nome': 'Sushi Kento',
        'tipo': 'Japonesa',
        'distancia': '2,5 km',
        'tempo': '40 min',
        'prato': 'Combinado especial',
        'foto':
            'https://images.pexels.com/photos/38795702/pexels-photo-38795702.jpeg',
        'notas': [5, 4, 5],
      },
      {
        'nome': 'Sabor da Terra',
        'tipo': 'Brasileira',
        'distancia': '0,8 km',
        'tempo': '25 min',
        'prato': 'Feijoada completa',
        'foto':
            'https://images.pexels.com/photos/22882530/pexels-photo-22882530.jpeg',
        'notas': [5, 4, 5, 4],
      },
      {
        'nome': 'El Mariachi',
        'tipo': 'Mexicana',
        'distancia': '1,6 km',
        'tempo': '35 min',
        'prato': 'Tacos al pastor',
        'foto':
            'https://images.pexels.com/photos/28503623/pexels-photo-28503623.jpeg',
        'notas': [4, 5, 4],
      },
      {
        'nome': 'Le Petit Bistrô',
        'tipo': 'Francesa',
        'distancia': '2,0 km',
        'tempo': '45 min',
        'prato': 'Quiche do dia',
        'foto':
            'https://images.pexels.com/photos/27643029/pexels-photo-27643029.jpeg',
        'notas': [5, 5, 4, 4],
      },
    ];

    for (final exemplo in exemplos) {
      final idRestaurante = await db.insert('restaurante', {
        'res_nm_restaurante': exemplo['nome'],
        'res_ds_tipo_culinaria': exemplo['tipo'],
        'res_nu_latitude': '',
        'res_nu_longitude': '',
        'res_tx_distancia': exemplo['distancia'],
        'res_tx_tempo': exemplo['tempo'],
      });

      final idPrato = await db.insert('prato', {
        'pra_nm_prato': exemplo['prato'],
        'pra_im_foto': exemplo['foto'],
        'pra_id_restaurante': idRestaurante,
      });

      for (final nota in (exemplo['notas'] as List<int>)) {
        await db.insert('avaliacao', {
          'avl_nu_ranking': nota,
          'avl_tx_recomendacao': '',
          'avl_id_prato': idPrato,
          'avl_id_usuario': 0,
        });
      }
    }
  }

  /// BUG CORRIGIDO (segurança): a senha era gravada em texto puro no
  /// banco. Agora aplicamos um hash SHA-256 antes de salvar/comparar,
  /// então a senha original nunca fica armazenada.
  String _hashSenha(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  /// Cadastra um novo usuário (necessário para o login funcionar --
  /// antes não existia NENHUMA forma de criar uma conta no app).
  /// Retorna null em caso de sucesso, ou uma mensagem de erro amigável.
  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      Database db = await bancoDeDados;
      await db.insert('usuario', {
        'usu_nm_usuario': nome,
        'usu_tx_email': email,
        'usu_tx_senha': _hashSenha(senha),
      });
      return null;
    } on DatabaseException catch (erro) {
      debugPrint('Erro ao cadastrar usuário: $erro');
      if (erro.isUniqueConstraintError()) {
        return 'Já existe uma conta cadastrada com esse e-mail.';
      }
      return 'Não foi possível criar a conta. Tente novamente.';
    } catch (erro) {
      debugPrint('Erro ao cadastrar usuário: $erro');
      return 'Não foi possível criar a conta. Tente novamente.';
    }
  }

  Future<Map<String, dynamic>?> autenticarUsuario(
      String email, String senha) async {

    Database db = await bancoDeDados;

    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      where: 'usu_tx_email = ? AND usu_tx_senha = ?',
      whereArgs: [email, _hashSenha(senha)],
    );

    if (resultado.isNotEmpty) return resultado.first;

    return null;
  }

  /// Usado na home: traz cada restaurante já com a nota média (calculada
  /// a partir das avaliações dos pratos) e uma foto de capa (a foto do
  /// primeiro prato cadastrado), pra montar os cards de uma vez só sem
  /// fazer uma consulta por restaurante.
  Future<List<Map<String, dynamic>>> consultarRestaurantesComNota() async {
    Database db = await bancoDeDados;
    return await db.rawQuery('''
      SELECT r.*,
        (SELECT AVG(a.avl_nu_ranking) FROM avaliacao a
           JOIN prato p ON a.avl_id_prato = p.pra_id_prato
           WHERE p.pra_id_restaurante = r.res_id_restaurante) AS nota_media,
        (SELECT p.pra_im_foto FROM prato p
           WHERE p.pra_id_restaurante = r.res_id_restaurante
           ORDER BY p.pra_id_prato ASC LIMIT 1) AS foto_capa
      FROM restaurante r
      ORDER BY r.res_id_restaurante DESC
    ''');
  }

  Future<int> inserirDados(String tabela, Map<String, dynamic> dados) async {
    Database db = await bancoDeDados;
    return await db.insert(tabela, dados);
  }

  Future<List<Map<String, dynamic>>> consultarDados(String tabela) async {
    Database db = await bancoDeDados;
    return await db.query(tabela);
  }

  Future<int> alterarDados(
    String tabela,
    Map<String, dynamic> novosDados,
    String colunaId,
    int id,
  ) async {
    Database db = await bancoDeDados;

    return await db.update(
      tabela,
      novosDados,
      where: '$colunaId = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> deletarDados(
    String tabela,
    String colunaId,
    int id,
  ) async {
    Database db = await bancoDeDados;

    return await db.delete(
      tabela,
      where: '$colunaId = ?',
      whereArgs: [id],
    );
  }

  Future<void> inserirRestaurante(Map<String, dynamic> dadosRestaurante) async {
    try {
       Database db = await bancoDeDados;
       int idGerado = await db.insert('restaurante', dadosRestaurante);
       print('Sucesso: Restaurante cadastrado com o ID $idGerado.');
    } catch(erro) {
      print('Erro ao tentar cadastrar o restaurante: $erro'); 
    }
  }

  Future<List<Map<String, dynamic>>> listarRestaurantesPortipo(String tipo) async {
    try{
      Database db = await bancoDeDados;

      List<Map<String, dynamic>> lista = await db.query(
        'restaurante',
        where: 'res_ds_tipo_culinaria = ?',
        whereArgs: [tipo],
      );
      print('Sucesso: Foram encontrados ${lista.length} restaurantes.');
      return lista;
    } catch (erro) {
      print('Erro ao buscar restaurantes do tipo $tipo: $erro');
      return [];
    }
  }

  Future<void> atualizarAvaliacao(int idAvaliacao, int novaNota, String novoTexto) async {
    try{
       Database db = await bancoDeDados;

       int linhasAfetadas = await db.update(
         'avaliacao',
         {'avl_nu_ranking': novaNota, 'avl_tx_recomendacao': novoTexto},
         where: 'avl_id_avaliacao = ?',
         whereArgs: [idAvaliacao],
       );

       if (linhasAfetadas > 0) {
        print('Sucesso: Avaliação atualizada.');
       } else {
        print('Aviso: Nenhuma avaliação encontrada com o ID $idAvaliacao.');
       } 
    } catch (erro) {
        print('Erro ao atualizar: $erro'); 
    }
  }

  Future<void> removerPrato(int idPrato) async {
    try {
      Database db = await bancoDeDados;

      int linhasAfetadas = await db.delete(
        'prato',
        where: 'pra_id_prato = ?',
        whereArgs: [idPrato],
      );

      if (linhasAfetadas > 0) {
        print('Sucesso: Prato deletado do cardápio.');
      } else {
        print('Aviso: Nenhum prato encontrado com o ID $idPrato');
      }
    } catch (erro) {
      print('Erro ao tentar remover o prato: $erro'); 
    }
  }

  Future<List<Map<String , dynamic>>> buscarRestaurantePorNome(String termoBusca) async {
    try {
      Database db = await bancoDeDados;

      List<Map<String, dynamic>> lista = await db.query(
        'restaurante',
        where: 'res_nm_restaurante LIKE ?',
        whereArgs: ['%$termoBusca%'],
      );
      print('Sucesso: Foram encontrados ${lista.length} restaurantes contendo "$termoBusca".');
      return lista;
    } catch (erro) {
      print('Erro ao buscar retaurante por nome: $erro');
      return []; 
    }
  }

  Future<List<Map<String, dynamic>>> listarPratosPorRestaurante(int idRestaurante) async {
    try {
      Database db = await bancoDeDados;
      List<Map<String, dynamic>> cardapio = await db.query(
         'prato',
         where: 'pra_id_restaurante = ?',
         whereArgs: [idRestaurante],
      );
      print('Sucesso: ${cardapio.length} pratos carregados para o restaurante ID $idRestaurante.');
      return cardapio;
    } catch (erro) {
      print('Erro ao carregar o cardápio: $erro');
      return []; 
    }
  }
}