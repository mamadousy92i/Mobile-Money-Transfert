// lib/screens/test_api_screen.dart

import 'package:flutter/material.dart';
import '../services/repository/transaction_repository.dart';
import '../models/canal_paiement.dart';
import '../models/responses/send_money_response.dart';

class TestApiScreen extends StatefulWidget {
  @override
  _TestApiScreenState createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final TransactionRepository _repository = TransactionRepository();

  String _status = 'Prêt à tester';
  bool _isLoading = false;
  List<CanalPaiement> _canaux = [];
  SendMoneyResponse? _lastTransaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Backend'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('✅') ? Colors.green :
                        _status.contains('❌') ? Colors.red : Colors.orange,
                      ),
                    ),
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Boutons de test
            Text('Tests API:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: _isLoading ? null : _testGetCanaux,
              child: Text('1. Tester GET /canaux/'),
            ),

            ElevatedButton(
              onPressed: _isLoading ? null : _testSendMoney,
              child: Text('2. Tester POST /send-money/'),
            ),

            ElevatedButton(
              onPressed: _isLoading ? null : _testGetTransactions,
              child: Text('3. Tester GET /transactions/'),
            ),

            ElevatedButton(
              onPressed: _isLoading ? null : _testGetStatistics,
              child: Text('4. Tester GET /statistics/'),
            ),

            SizedBox(height: 20),

            // Résultats
            if (_canaux.isNotEmpty) ...[
              Text('Canaux trouvés:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                height: 100,
                child: ListView.builder(
                  itemCount: _canaux.length,
                  itemBuilder: (context, index) {
                    final canal = _canaux[index];
                    return ListTile(
                      title: Text(canal.displayName),
                      subtitle: Text('Frais: ${canal.feesPercentage}% + ${canal.feesFixed} XOF'),
                      dense: true,
                    );
                  },
                ),
              ),
            ],

            if (_lastTransaction != null) ...[
              SizedBox(height: 10),
              Text('Dernière transaction:', style: TextStyle(fontWeight: FontWeight.bold)),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${_lastTransaction!.codeTransaction ?? "N/A"}'),
                      Text('Montant: ${_lastTransaction!.montantTotal ?? 0} XOF'),
                      Text('Frais: ${_lastTransaction!.frais ?? "N/A"}'),
                      Text('Succès: ${_lastTransaction!.success ? "✅" : "❌"}'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Test 1: Récupérer les canaux de paiement
  Future<void> _testGetCanaux() async {
    setState(() {
      _isLoading = true;
      _status = '🔄 Test GET /canaux/ en cours...';
    });

    try {
      final result = await _repository.getCanaux();

      if (result.isSuccess) {
        setState(() {
          _canaux = result.data!;
          _status = '✅ GET /canaux/ réussi! ${_canaux.length} canaux trouvés';
        });
      } else {
        setState(() {
          _status = '❌ GET /canaux/ échoué: ${result.errorMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erreur GET /canaux/: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Test 2: Envoyer de l'argent
  Future<void> _testSendMoney() async {
    if (_canaux.isEmpty) {
      setState(() {
        _status = '❌ Récupérez d\'abord les canaux (test 1)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '🔄 Test POST /send-money/ en cours...';
    });

    try {
      final firstCanal = _canaux.first;
      final result = await _repository.sendMoney(
        beneficiairePhone: '+221771234567',
        montant: 10000, // 10 000 XOF
        canalPaiementId: firstCanal.id,
      );

      if (result.isSuccess) {
        setState(() {
          _lastTransaction = result.data!;
          _status = '✅ POST /send-money/ réussi! Transaction: ${result.data!.codeTransaction}';
        });
      } else {
        setState(() {
          _status = '❌ POST /send-money/ échoué: ${result.errorMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erreur POST /send-money/: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Test 3: Récupérer les transactions
  Future<void> _testGetTransactions() async {
    setState(() {
      _isLoading = true;
      _status = '🔄 Test GET /transactions/ en cours...';
    });

    try {
      final result = await _repository.getTransactions();

      if (result.isSuccess) {
        setState(() {
          _status = '✅ GET /transactions/ réussi! ${result.data!.length} transactions trouvées';
        });
      } else {
        setState(() {
          _status = '❌ GET /transactions/ échoué: ${result.errorMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erreur GET /transactions/: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Test 4: Récupérer les statistiques
  Future<void> _testGetStatistics() async {
    setState(() {
      _isLoading = true;
      _status = '🔄 Test GET /statistics/ en cours...';
    });

    try {
      final result = await _repository.getStatistics();

      if (result.isSuccess) {
        final stats = result.data!;
        setState(() {
          _status = '✅ GET /statistics/ réussi! Total: ${stats.totalTransactions} transactions, ${stats.totalAmount} XOF';
        });
      } else {
        setState(() {
          _status = '❌ GET /statistics/ échoué: ${result.errorMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erreur GET /statistics/: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


