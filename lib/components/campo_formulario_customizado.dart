import 'package:flutter/material.dart';

class CampoFormularioCustomizado extends StatelessWidget {
  final String titulo;
  final TextEditingController controlador;
  final TextInputType tipoTeclado;
  final bool ocultarTexto;
  final bool obrigatorio;
  final IconData? icone;

  const CampoFormularioCustomizado({
    super.key,
    required this.titulo,
    required this.controlador,
    this.tipoTeclado = TextInputType.text,
    this.ocultarTexto = false,
    this.obrigatorio = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controlador,
        keyboardType: tipoTeclado,
        obscureText: ocultarTexto,
        decoration: InputDecoration(
          labelText: titulo,
          prefixIcon: icone != null ? Icon(icone) : null,
        ),
        validator: obrigatorio
            ? (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
