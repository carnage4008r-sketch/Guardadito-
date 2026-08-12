import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('guardadito');
  runApp(GuardaditoApp());
}

class GuardaditoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardadito',
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFFFF8E7)),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var box = Hive.box('guardadito');
  
  Map<String, double> get sobres => {
    'Casa': box.get('Casa', defaultValue: 1200.0),
    'Chamba': box.get('Chamba', defaultValue: 300.0),
    'Colchon': box.get('Colchon', defaultValue: 450.0),
    'Gusto': box.get('Gusto', defaultValue: 50.0),
  };
  
  double get total => sobres.values.fold(0, (a, b) => a + b);

  void _agregarIngreso() {
    TextEditingController ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFFFF8C42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 80),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("¿Cuánto ganaste hoy?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          SizedBox(height: 15),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            decoration: InputDecoration(prefixText: "\$ ", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2EC4B6), minimumSize: Size(double.infinity, 55)),
            onPressed: () {
              double m = double.tryParse(ctrl.text) ?? 0;
              if (m > 0) {
                box.put('Casa', (box.get('Casa', defaultValue: 0.0) + m));
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text("Guardar en Casa →", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }

  void _agregarGasto() {
    TextEditingController ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFFFF8E7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20),
        child: StatefulBuilder(builder: (c, setM) => Column(mainAxisSize: MainAxisSize.min, children: [
          Text("MONTO DEL GASTO", style: TextStyle(fontWeight: FontWeight.w900)),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),
            decoration: InputDecoration(prefixText: "\$ "),
            onChanged: (v) => setM(() {}),
          ),
          SizedBox(height: 20),
          if ((double.tryParse(ctrl.text) ?? 0) > 0)
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(color: Color(0xFF2EC4B6), borderRadius: BorderRadius.circular(15), border: Border.all(width: 3)),
              child: Column(children: [
                Text("¿Guardamos \$${(10 - (double.tryParse(ctrl.text) ?? 0) % 10).toStringAsFixed(0)} pa' tu colchon?", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ElevatedButton(onPressed: () {
                    double g = double.parse(ctrl.text);
                    double r = (10 - g % 10) % 10;
                    box.put('Casa', box.get('Casa') - g);
                    box.put('Colchon', box.get('Colchon') + r);
                    setState(() {});
                    Navigator.pop(context);
                  }, child: Text("Sí"))),
                  SizedBox(width: 10),
                  Expanded(child: OutlinedButton(onPressed: () {
                    double g = double.parse(ctrl.text);
                    box.put('Casa', box.get('Casa') - g);
                    setState(() {});
                    Navigator.pop(context);
                  }, child: Text("No"))),
                ])
              ]),
            )
        ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFFFFB86A), title: Row(children: [Icon(Icons.savings), SizedBox(width: 8), Text("Guardadito", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black))])),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          Container(width: double.infinity, padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Color(0xFF0E4D64), borderRadius: BorderRadius.circular(15), border: Border.all(width: 3)),
            child: Column(children: [Text("Saldo Total", style: TextStyle(color: Colors.white)), Text("\$${total.toStringAsFixed(0)}", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900))])),
          SizedBox(height: 16),
          Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, children: [
            _card("Casa", sobres['Casa']!, Color(0xFFFFB86A), Icons.home),
            _card("Chamba", sobres['Chamba']!, Color(0xFF2EC4B6), Icons.work),
            _card("Colchon", sobres['Colchon']!, Color(0xFFFFD166), Icons.bed),
            _card("Gusto", sobres['Gusto']!, Color(0xFFFF9A8A), Icons.star),
          ])),
        ]),
      ),
      bottomNavigationBar: BottomAppBar(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ElevatedButton.icon(onPressed: _agregarIngreso, icon: Icon(Icons.add), label: Text("Ganancia")),
        ElevatedButton.icon(onPressed: _agregarGasto, icon: Icon(Icons.remove), label: Text("Gasto"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
      ])),
    );
  }

  Widget _card(String n, double m, Color c, IconData i) => Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(15), border: Border.all(width: 3)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i), Spacer(), Text(n, style: TextStyle(fontWeight: FontWeight.bold)), Text("\$${m.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28))]),
  );
}
