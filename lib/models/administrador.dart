import 'usuario.dart';

class Administrador extends Usuario {
   
   Administrador(super.id, super.nome, super.email, super.senha);

  @override
  void exibirMenu(){
    print('--- Painel do Administrador');
    print('1. Aprovar novos restaurantes');
    print('2. Banir usuários');
  }

  @override
  void gerenciarConta() {
    print('Acesso total as configurações do sistema Coma Bem.'); 
  } 
}