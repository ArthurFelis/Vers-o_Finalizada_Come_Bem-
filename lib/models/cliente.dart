import 'usuario.dart';

class Cliente extends Usuario {

  Cliente(super.id, super.nome, super.email, super.senha);

  void avaliarPrato(String prato, int nota){
    print('O clinte $nomeUsuario avaliou o prato $prato com nota $nota.');
  }

  @override
  void exibirMenu(){
    print('--- Menu do Cliente');
    print('1. Buscar Restaurante');
    print('2. Meus Favoritos'); 
  }

  @override
  void gerenciarConta(){
    print('Gerenciando forma de pagamento e endereço de entrega'); 
  }
}