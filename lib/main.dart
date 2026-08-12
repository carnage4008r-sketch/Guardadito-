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
    'Comida': box.get('Comida', defaultValue: 200.0),
    'Coppel': box.get('Coppel', defaultValue: 0.0),
    'Chamba': box.get('Chamba', defaultValue: 300.0),
    'Colchon': box.get('Colchon', defaultValue: 450.0),
    'Gusto': box.get('Gusto', defaultValue: 50.0),
  };
  
  double get total => sobres.values.fold(0, (a, b) => a + b);

  void _borrarSobre(String nombre) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('¿Borrar $nombre?'),
      content: Text('Se pondrá en \$0'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
        TextButton(onPressed: () { box.put(nombre, 0.0); setState((){}); Navigator.pop(ctx); }, child: Text('Borrar', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _borrarTodo() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('¿Borrar TODO?'),
      content: Text('Todos en \$0'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
        TextButton(onPressed: () {
          for(var k in sobres.keys) box.put(k, 0.0);
          setState((){}); Navigator.pop(ctx);
        }, child: Text('Sí, borrar todo', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _agregarIngreso() {
    TextEditingController ctrl = TextEditingController();
    String selected = 'Casa';
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Color(0xFFFF8C42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder(builder: (ctx2, setM) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 80),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("¿Cuánto ganaste hoy?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          DropdownButton<String>(value: selected, isExpanded: true, onChanged: (v)=> setM(()=> selected=v!), items: sobres.keys.map((k)=> DropdownMenuItem(value:k, child: Text("Guardar en $k"))).toList()),
          TextField(controller: ctrl, keyboardType: TextInputType.number, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold), decoration: InputDecoration(prefixText: "\$ ", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
          SizedBox(height: 15),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2EC4B6), minimumSize: Size(double.infinity, 55)),
            onPressed: () { double m = double.tryParse(ctrl.text) ?? 0; if (m > 0) { box.put(selected, (box.get(selected, defaultValue: 0.0) + m)); setState(() {}); Navigator.pop(context); } },
            child: Text("Guardar →", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ]),
      )),
    );
  }

  void _agregarGasto() {
    TextEditingController ctrl = TextEditingController();
    String selected = 'Comida';
    showModalBottomSheet(
      context: context, backgroundColor: Color(0xFFFFF8E7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20),
        child: StatefulBuilder(builder: (c, setM) => Column(mainAxisSize: MainAxisSize.min, children: [
          Text("¿En qué gastaste?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          DropdownButton<String>(value: selected, isExpanded: true, onChanged: (v)=> setM(()=> selected=v!), items: sobres.keys.map((k)=> DropdownMenuItem(value:k, child: Text(k))).toList()),
          TextField(controller: ctrl, keyboardType: TextInputType.number, style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900), decoration: InputDecoration(prefixText: "\$ "), onChanged: (v) => setM(() {})),
          SizedBox(height: 15),
          if ((double.tryParse(ctrl.text) ?? 0) > 0)
            Container(padding: EdgeInsets.all(15), decoration: BoxDecoration(color: Color(0xFF2EC4B6), borderRadius: BorderRadius.circular(15), border: Border.all(width: 3)),
              child: Column(children: [
                Text("¿Guardamos \$${(10 - (double.tryParse(ctrl.text) ?? 0) % 10).toStringAsFixed(0)} pa' tu colchon?", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ElevatedButton(onPressed: () {
                    double g = double.parse(ctrl.text); double r = (10 - g % 10) % 10;
                    box.put(selected, box.get(selected) - g); box.put('Colchon', box.get('Colchon') + r);
                    setState(() {}); Navigator.pop(context);
                  }, child: Text("Sí + redondeo"))),
                  SizedBox(width: 10),
                  Expanded(child: OutlinedButton(onPressed: () {
                    double g = double.parse(ctrl.text); box.put(selected, box.get(selected) - g);
                    setState(() {}); Navigator.pop(context);
                  }, child: Text("Solo gasto"))),
                ])
              ]),
            ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: Size(double.infinity, 50)),
            onPressed: () {
              double g = double.tryParse(ctrl.text) ?? 0;
              if(g>0){ box.put(selected, box.get(selected) - g); setState((){}); Navigator.pop(context); }
            },
            child: Text("Descontar de $selected")
          )
        ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFB86A), 
        title: Row(children: [Icon(Icons.savings), SizedBox(width: 8), Text("Guardadito", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black))]),
        actions: [
          PopupMenuButton(
            onSelected: (v){ if(v==1) _borrarTodo(); },
            itemBuilder: (c)=> [Popup
