import 'usuario.dart';

class DonoRestaurante extends Usuario {
  String cnpj;

  DonoRestaurante(super.id, super.nome, super.email, super.senha, this.cnpj);

   @override
   void exibirMenu(){
    print('--- Menu do Restaurante ---');
    print('1. Cadastrar novo prato');
    print('2. Ver avaliações recebidas');
   }

   @override
   void gerenciarConta() {
     print('Gerenciador dados bancários da empresa CNPJ: $cnpj');
   }
  
}