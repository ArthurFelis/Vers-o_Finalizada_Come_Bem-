import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../components/padrao_fundo.dart';
import 'cadastro_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? idUsuario;
  final String? nomeUsuario;

  const HomeScreen({super.key, this.idUsuario, this.nomeUsuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _restaurantes = [];
  List<Map<String, dynamic>> _restaurantesFiltrados = [];
  bool _carregando = true;
  String _termoBusca = '';
  String _categoriaSelecionada = 'Todos';
  final Set<int> _favoritos = {}; // só em memória por enquanto
  int _abaAtual = 0;

  @override
  void initState() {
    super.initState();
    _carregarRestaurantes();
  }

  Future<void> _carregarRestaurantes() async {
    setState(() => _carregando = true);
    // Traz cada restaurante já com nota média e foto de capa, pra
    // montar os cards do jeito que aparecem na referência.
    final dados =
        await DatabaseHelper.instancia.consultarRestaurantesComNota();
    if (!mounted) return;
    setState(() {
      _restaurantes = dados;
      _aplicarFiltro();
      _carregando = false;
    });
  }

  List<String> get _categorias {
    final tipos = _restaurantes
        .map((r) => (r['res_ds_tipo_culinaria'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Todos', ...tipos];
  }

  void _aplicarFiltro() {
    Iterable<Map<String, dynamic>> filtrados = _restaurantes;

    if (_categoriaSelecionada != 'Todos') {
      filtrados = filtrados.where((r) =>
          (r['res_ds_tipo_culinaria'] ?? '').toString() ==
          _categoriaSelecionada);
    }

    if (_termoBusca.trim().isNotEmpty) {
      final termo = _termoBusca.toLowerCase();
      filtrados = filtrados.where((r) {
        final nome = (r['res_nm_restaurante'] ?? '').toString().toLowerCase();
        final tipo =
            (r['res_ds_tipo_culinaria'] ?? '').toString().toLowerCase();
        return nome.contains(termo) || tipo.contains(termo);
      });
    }

    _restaurantesFiltrados = filtrados.toList();
  }

  IconData _iconePorCulinaria(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'japonesa':
        return Icons.set_meal_outlined;
      case 'italiana':
        return Icons.local_pizza_outlined;
      case 'brasileira':
        return Icons.outdoor_grill_outlined;
      case 'francesa':
        return Icons.restaurant_menu_outlined;
      case 'mexicana':
        return Icons.local_dining_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  IconData _iconePorCategoria(String categoria) {
    if (categoria == 'Todos') return Icons.apps_rounded;
    return _iconePorCulinaria(categoria);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      body: PadraoFundo(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.vinho,
            onRefresh: _carregarRestaurantes,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildCabecalho()),
                SliverToBoxAdapter(child: _buildBusca()),
                SliverToBoxAdapter(child: _buildCategorias()),
                SliverToBoxAdapter(child: _buildTituloSecao()),
                if (_carregando)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.vinho),
                    ),
                  )
                else if (_restaurantesFiltrados.isEmpty)
                  SliverFillRemaining(child: _buildEstadoVazio())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildCardRestaurante(_restaurantesFiltrados[index]),
                        childCount: _restaurantesFiltrados.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.vinho,
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CadastroScreen(idUsuarioLogado: widget.idUsuario),
            ),
          );
          if (resultado == true) {
            _carregarRestaurantes();
          }
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      bottomNavigationBar: _buildBarraInferior(),
    );
  }

  Widget _buildCabecalho() {
    final nome = widget.nomeUsuario?.trim();
    final saudacao = (nome == null || nome.isEmpty) ? 'Olá! 👋' : 'Olá, $nome 👋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(saudacao, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 3),
                const Text(
                  'O que vamos comer hoje?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dourado.withValues(alpha: 0.18),
              border: Border.all(color: AppColors.dourado, width: 1.4),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.vinho),
          ),
        ],
      ),
    );
  }

  Widget _buildBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.creme2),
              ),
              child: TextField(
                onChanged: (valor) {
                  setState(() {
                    _termoBusca = valor;
                    _aplicarFiltro();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar pratos ou restaurantes...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.vinho),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.vinho,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              tooltip: 'Filtros',
              onPressed: () {
                // Os filtros por categoria já ficam logo abaixo (chips);
                // esse botão fica reservado pra filtros mais avançados
                // no futuro (preço, distância etc).
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias() {
    final categorias = _categorias;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final selecionada = categoria == _categoriaSelecionada;

          return ChoiceChip(
            label: Text(categoria),
            selected: selecionada,
            onSelected: (_) {
              setState(() {
                _categoriaSelecionada = categoria;
                _aplicarFiltro();
              });
            },
            avatar: Icon(
              _iconePorCategoria(categoria),
              size: 16,
              color: selecionada ? Colors.white : AppColors.vinho,
            ),
            selectedColor: AppColors.vinho,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selecionada ? Colors.white : AppColors.textoPrincipal,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: selecionada ? AppColors.vinho : AppColors.creme2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTituloSecao() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Restaurantes visitados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textoPrincipal,
            ),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Em breve!')),
            ),
            child: const Text(
              'Ver todos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.vinho,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRestaurante(Map<String, dynamic> restaurante) {
    final id = restaurante['res_id_restaurante'] as int;
    final nome = (restaurante['res_nm_restaurante'] ?? '').toString();
    final tipo = (restaurante['res_ds_tipo_culinaria'] ?? '').toString();
    final distancia = (restaurante['res_tx_distancia'] ?? '').toString();
    final tempo = (restaurante['res_tx_tempo'] ?? '').toString();
    final notaMedia = (restaurante['nota_media'] as num?)?.toDouble();
    final fotoCapa = restaurante['foto_capa'] as String?;
    final favoritado = _favoritos.contains(id);

    final subtitulo = [
      tipo,
      if (tempo.isNotEmpty) tempo,
      if (distancia.isNotEmpty) distancia,
    ].where((p) => p.isNotEmpty).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.creme2, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 64,
              height: 64,
              child: _buildFotoCard(fotoCapa, tipo),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (notaMedia != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dourado.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.dourado, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        notaMedia.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.vinhoEscuro,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.vinho.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Novo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.vinho,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (favoritado) {
                      _favoritos.remove(id);
                    } else {
                      _favoritos.add(id);
                    }
                  });
                },
                child: Icon(
                  favoritado ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 20,
                  color: favoritado ? AppColors.vinho : AppColors.textoSecundario,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFotoCard(String? foto, String tipo) {
    Widget marcador() => Container(
          color: AppColors.vinho.withValues(alpha: 0.08),
          child: Icon(_iconePorCulinaria(tipo), color: AppColors.vinho),
        );

    if (foto == null || foto.isEmpty) return marcador();

    // Fotos de exemplo vêm de URL (rede); fotos tiradas pelo usuário no
    // cadastro vêm como caminho de arquivo local -- por isso a checagem.
    final ehFotoDeRede = foto.startsWith('http');

    if (ehFotoDeRede) {
      return Image.network(
        foto,
        fit: BoxFit.cover,
        errorBuilder: (context, erro, stack) => marcador(),
        loadingBuilder: (context, child, progresso) {
          if (progresso == null) return child;
          return Container(
            color: AppColors.creme2,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.vinho,
                ),
              ),
            ),
          );
        },
      );
    }

    return Image.file(
      File(foto),
      fit: BoxFit.cover,
      errorBuilder: (context, erro, stack) => marcador(),
    );
  }

  Widget _buildEstadoVazio() {
    final semResultadoDeBusca =
        (_termoBusca.isNotEmpty || _categoriaSelecionada != 'Todos') &&
            _restaurantes.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    semResultadoDeBusca
                        ? Icons.search_off_rounded
                        : Icons.restaurant_outlined,
                    size: 56,
                    color: AppColors.vinho.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    semResultadoDeBusca
                        ? 'Nenhum restaurante encontrado'
                        : 'Nenhum restaurante cadastrado ainda',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    semResultadoDeBusca
                        ? 'Tente buscar por outro nome ou categoria.'
                        : 'Toque no botão "+" para adicionar o primeiro.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarraInferior() {
    return BottomNavigationBar(
      currentIndex: _abaAtual,
      selectedItemColor: AppColors.vinho,
      unselectedItemColor: AppColors.textoSecundario,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) {
          setState(() => _abaAtual = 0);
          return;
        }
        // As outras abas ainda não têm tela própria -- por enquanto só
        // avisamos e voltamos pra Início, em vez de deixar o app "morto"
        // numa aba sem conteúdo.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essa aba ainda está em construção.')),
        );
        setState(() => _abaAtual = index);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _abaAtual = 0);
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
