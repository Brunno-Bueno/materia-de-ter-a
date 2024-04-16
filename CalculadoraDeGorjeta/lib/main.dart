import 'package:flutter/material.dart';

void main() {
  runApp(Calculadoragorjeta());
}

class Calculadoragorjeta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de gorjeta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculadoraPagina(),
    );
  }
}

class CalculadoraPagina extends StatefulWidget {
  @override
  _CalculadoraPaginaState createState() => _CalculadoraPaginaState();
}

class _CalculadoraPaginaState extends State<CalculadoraPagina> {
  double _valorconta = 0.0;
  int _porcentagemgorjeta = 10;
  double _valorgorjeta = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de gorjeta'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Valor da conta'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (valor) {
                setState(() {
                  _valorconta = double.tryParse(valor) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20.0),
            Row(
              children: <Widget>[
                Text('Porcentagem da gorjeta:'),
                SizedBox(width: 10.0),
                DropdownButton<int>(
                  value: _porcentagemgorjeta,
                  onChanged: (valor) {
                    setState(() {
                      _porcentagemgorjeta = valor!;
                    });
                  },
                  items: <int>[5,10,15,20,25,30, 35,40,45,50,55,60,65,70,80]
                      .map<DropdownMenuItem<int>>((int valor) {
                    return DropdownMenuItem<int>(
                      value: valor,
                      child: Text('$valor%'),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                double gorjeta = (_valorconta * _porcentagemgorjeta) / 100;
                setState(() {
                  _valorgorjeta = gorjeta;
                });
              },
              child: Text('Calcular gorjeta'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Valor da gorjeta: R\$ ${_valorgorjeta.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'Total a pagar: R\$ ${(_valorconta + _valorgorjeta).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}