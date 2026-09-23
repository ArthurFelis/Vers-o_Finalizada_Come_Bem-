import 'models/restaurante.dart';

void main() {

   List<Restaurante> listaDeRestaurante = [
     Restaurante(1, 'Sushi House', '-23.5', '-46.6', 'Japonesa'),
     Restaurante(2, 'Cantina Bella', '-23.6', '-46.7', 'Italina'),
     Restaurante(3, 'Boi Bom', '-23.7', '-46.8', 'Brasileira'),
   ];

   print('--- CATÁLOGO DE RESTAURANTES ---');

   for( Restaurante res in listaDeRestaurante) {
     print('Nome: ${res.nomeRestaurante} | Tipo: ${res.tipoCulinaria}');

     res.exibirCategoriaCulinaria();
     print('------------------------------'); 
   }
}