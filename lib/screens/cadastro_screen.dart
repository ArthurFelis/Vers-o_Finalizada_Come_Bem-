import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';
import '../components/campo_formulario_customizado.dart';
import '../components/padrao_fundo.dart';
import '../components/seletor_de_nota.dart';
import '../theme/app_theme.dart';

class CadastroScreen extends StatefulWidget {
  final int? idUsuarioLogado;

  const CadastroScreen({super.key, this.idUsuarioLogado});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _culinariaController = TextEditingController();
  final TextEditingController _pratoController = TextEditingController();
  final TextEditingController _recomendacaoController = TextEditingController();

  File? _fotoPrato;
  bool _salvando = false;
  int _notaAvaliacao = 0; // 0 a 5

  final String _latitude = '';
  final String _longitude = '';

  final ImagePicker _picker = ImagePicker();

  // No computador não existe câmera: usamos o explorador de arquivos.
  bool get _ehDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void dispose() {
    _nomeController.dispose();
    _culinariaController.dispose();
    _pratoController.dispose();
    _recomendacaoController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto, {required Color cor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  /// Copia a imagem escolhida para a pasta de documentos do app, para que
  /// a foto continue existindo mesmo que o arquivo original seja movido,
  /// apagado ou esteja em um cache temporário.
  Future<String> _copiarParaPastaDoApp(String caminhoOriginal) async {
    final pastaDocumentos = await getApplicationDocumentsDirectory();
    final pastaFotos = Directory(p.join(pastaDocumentos.path, 'fotos_pratos'));
    if (!await pastaFotos.exists()) {
      await pastaFotos.create(recursive: true);
    }

    final nomeArquivo =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(caminhoOriginal)}';
    final destino = p.join(pastaFotos.path, nomeArquivo);

    await File(caminhoOriginal).copy(destino);
    return destino;
  }

  Future<void> _escolherFoto(ImageSource origem) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: origem,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (foto == null) return;

      final caminhoFinal = await _copiarParaPastaDoApp(foto.path);
      if (!mounted) return;

      setState(() => _fotoPrato = File(caminhoFinal));
    } catch (erro) {
      debugPrint('Erro ao escolher foto: $erro');
      _mostrarMensagem(
        'Não foi possível carregar a foto.',
        cor: AppColors.erro,
      );
    }
  }

  Future<void> _selecionarOrigemFoto() async {
    // No desktop abre direto o explorador de arquivos.
    if (_ehDesktop) {
      await _escolherFoto(ImageSource.gallery);
      return;
    }

    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (origem != null) await _escolherFoto(origem);
  }

  Future<void> _salvarCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    final nomePrato = _pratoController.text.trim();

    // Valida ANTES de gravar qualquer coisa: se a nota fosse recusada só
    // depois de salvar o restaurante, um segundo toque em "Salvar" criaria
    // um restaurante duplicado.
    if (_notaAvaliacao > 0 && nomePrato.isEmpty) {
      _mostrarMensagem(
        'Informe o nome do prato para registrar a nota.',
        cor: AppColors.erro,
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final dadosRestaurante = {
        'res_nm_restaurante': _nomeController.text.trim(),
        'res_ds_tipo_culinaria': _culinariaController.text.trim(),
        'res_nu_latitude': _latitude,
        'res_nu_longitude': _longitude,
      };

      final idRestaurante = await DatabaseHelper.instancia
          .inserirDados('restaurante', dadosRestaurante);

      int? idPrato;
      if (nomePrato.isNotEmpty) {
        idPrato = await DatabaseHelper.instancia.inserirDados('prato', {
          'pra_nm_prato': nomePrato,
          'pra_im_foto': _fotoPrato?.path,
          'pra_id_restaurante': idRestaurante,
        });
      }

      // A nota é sobre o prato, então só é gravada se houver um prato.
      if (_notaAvaliacao > 0 && idPrato != null) {
        await DatabaseHelper.instancia.inserirDados('avaliacao', {
          'avl_nu_ranking': _notaAvaliacao,
          'avl_tx_recomendacao': _recomendacaoController.text.trim(),
          'avl_id_prato': idPrato,
          'avl_id_usuario': widget.idUsuarioLogado ?? 0,
        });
      }

      if (!mounted) return;

      _mostrarMensagem(
        'Restaurante cadastrado com sucesso!',
        cor: AppColors.sucesso,
      );

      Navigator.pop(context, true);
    } catch (erro) {
      debugPrint('Erro ao salvar cadastro: $erro');
      _mostrarMensagem(
        'Ocorreu um erro inesperado ao salvar.',
        cor: AppColors.erro,
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      appBar: AppBar(title: const Text('Novo Restaurante')),
      body: PadraoFundo(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dados do restaurante',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.vinho,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 14),

                  CampoFormularioCustomizado(
                    titulo: 'Nome do Restaurante',
                    controlador: _nomeController,
                    obrigatorio: true,
                  ),

                  CampoFormularioCustomizado(
                    titulo: 'Tipo de Culinária',
                    controlador: _culinariaController,
                    obrigatorio: true,
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    'Prato em destaque (opcional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.vinho,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 14),

                  CampoFormularioCustomizado(
                    titulo: 'Nome do Prato',
                    controlador: _pratoController,
                  ),

                  GestureDetector(
                    onTap: _selecionarOrigemFoto,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.creme2, width: 1.4),
                        image: _fotoPrato != null
                            ? DecorationImage(
                                image: FileImage(_fotoPrato!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _fotoPrato == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    color: AppColors.vinho, size: 30),
                                SizedBox(height: 8),
                                Text(
                                  'Toque para adicionar uma foto',
                                  style: TextStyle(
                                    color: AppColors.textoSecundario,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor:
                                      Colors.black.withValues(alpha: 0.55),
                                  radius: 16,
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    'Sua avaliação sobre o prato (opcional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.vinho,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SeletorDeNota(
                    nota: _notaAvaliacao,
                    aoMudar: (novaNota) =>
                        setState(() => _notaAvaliacao = novaNota),
                  ),
                  const SizedBox(height: 14),
                  CampoFormularioCustomizado(
                    titulo: 'Comentário (opcional)',
                    controlador: _recomendacaoController,
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _salvando ? null : _salvarCadastro,
                    child: _salvando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}