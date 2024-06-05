import 'package:flutter/material.dart';

class PalettesPage extends StatefulWidget {
  const PalettesPage({super.key});

  @override
  State<PalettesPage> createState() => _PalettesPageState();
}

class _PalettesPageState extends State<PalettesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suas Paletas'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
    );
  }
}
