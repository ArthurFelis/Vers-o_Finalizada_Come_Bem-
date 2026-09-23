import 'dart:io';

import 'models/usuario.dart';
import 'models/cliente.dart';
import 'models/administrador.dart';

void main() {
  List<Usuario> usuariosCadastrados = [];
  bool sistemaRodando = true;

  print('=== BEM-VINDO AO SIMULADOR DE OBJETOS COMA BEM ===');

  while (sistemaRodando) {
    print('\nSelecione uma ação:'); 
    print('1 - Cadastrar novo Cliente');
    print('2 - Cadastrar novo Administrador');
    print('3 - Listar perfis e exibir Menus (Testar Polimorfismo)'); 
    print('4 - Sair do Sistema'); 
    stdout.write('Sua opção: ');

    String? opcao = stdin.readLineSync();

    switch (opcao) {
      case '1':
        print('\n--- CADASTRO DE CLIENTE ---');
        stdout.write('Digite o nome do cliente: ');
        String? nome = stdin.readLineSync();

        Cliente cliente = Cliente(
          1,
          nome ?? "Sem Nome",
          "cliente@email.com",
          "123456",
        );

        usuariosCadastrados.add(cliente);

        print("Cliente cadastrado com sucesso!");
        break;

      case '2':
        print('\n--- CADASTRO DE ADMINISTRADOR ---');
        stdout.write('Digite o nome do administrador: ');
        String? nomeAdmin = stdin.readLineSync();

        Administrador administrador = Administrador(
          2,
          nomeAdmin ?? "Sem Nome",
          "admin@email.com",
          "123456",
        );

        usuariosCadastrados.add(administrador);

        print("Administrador cadastrado com sucesso!");
        break;

      case '3':
        print('\n--- LISTAGEM DE USUÁRIOS ---');

        if (usuariosCadastrados.isEmpty) {
          print("Nenhum usuário cadastrado.");
        } else {
          for (Usuario usuario in usuariosCadastrados) {
            print("\nNome: ${usuario.nomeUsuario}");

            usuario.exibirMenu();
          }
        }
        break;

      case '4':
        sistemaRodando = false;
        print('\nEncerrando o simulador... Até logo!');
        break;

      default:
        print('\nOpção inválida! Digite um número de 1 a 4.');
    }
  }
}