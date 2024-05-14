import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(CalculadoraGorjeta());
}

class CalculadoraGorjeta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Gorjeta',
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
  double _valorConta = 0.0;
  int? _porcentagemGorjeta;
  double _valorGorjeta = 0.0;
  final TextEditingController _controllerConta = TextEditingController();
  final TextEditingController _controllerGarcom = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _calcularGorjeta() {
    if (_porcentagemGorjeta != null) {
      setState(() {
        _valorGorjeta = (_valorConta * _porcentagemGorjeta!) / 100;
      });
    }
  }

  void _atualizarValorConta(String valor) {
    setState(() {
      _valorConta = double.tryParse(valor) ?? 0.0;
      _calcularGorjeta();
    });
  }

  void _adicionarGorjeta(String nomeGarcom) async {
    var gorjetaExistente = await _databaseHelper.obterGorjetaPorNome(nomeGarcom);
    if (gorjetaExistente != null) {
      await _databaseHelper.atualizarGorjeta(nomeGarcom, _valorGorjeta);
    } else {
      await _databaseHelper.inserirGorjeta(nomeGarcom, _valorGorjeta);
    }
    setState(() {
      _controllerConta.clear();
      _controllerGarcom.clear();
      _valorConta = 0.0;
      _valorGorjeta = 0.0;
      _porcentagemGorjeta = null;
    });
  }

  bool _isBotaoRegistrarHabilitado() {
    return _controllerConta.text.isNotEmpty && _controllerGarcom.text.isNotEmpty && _porcentagemGorjeta != null;
  }

  void _limparBancoDeDados() async {
    await _databaseHelper.limparBancoDeDados();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Gorjeta'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GorjetasPagina()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _limparBancoDeDados,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _controllerConta,
                decoration: InputDecoration(
                  labelText: 'Valor da conta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: _atualizarValorConta,
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Porcentagem:'),
                  DropdownButton<int>(
                    hint: Text('Selecione a porcentagem'),
                    value: _porcentagemGorjeta,
                    onChanged: (valor) {
                      setState(() {
                        _porcentagemGorjeta = valor;
                        _calcularGorjeta();
                      });
                    },
                    items: <int>[5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80]
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
              TextField(
                controller: _controllerGarcom,
                decoration: InputDecoration(
                  labelText: 'Nome do garçom',
                  border: OutlineInputBorder(),
                ),
                onChanged: (valor) {
                  setState(() {});
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isBotaoRegistrarHabilitado()
                    ? () {
                  _adicionarGorjeta(_controllerGarcom.text);
                }
                    : null,
                child: Text('Registrar gorjeta'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Valor da gorjeta: R\$ ${_valorGorjeta.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Total a pagar: R\$ ${(_valorConta + _valorGorjeta).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GorjetasPagina extends StatelessWidget {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gorjetas por Garçom'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _databaseHelper.listarGorjetas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma gorjeta registrada.'));
          } else {
            var gorjetas = snapshot.data!;
            return ListView.builder(
              itemCount: gorjetas.length,
              itemBuilder: (context, index) {
                var gorjeta = gorjetas[index];
                return ListTile(
                  title: Text(gorjeta['nomeGarcom']),
                  subtitle: Text('Gorjeta: R\$ ${gorjeta['valorGorjeta'].toStringAsFixed(2)}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
