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
      title: Text('Borrar $nombre?'),
      content: Text('Se pondra en \$0'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
        TextButton(onPressed: () { box.put(nombre, 0.0); setState((){}); Navigator.pop(ctx); }, child: Text('Borrar', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _borrarTodo() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Borrar TODO?'),
      content: Text('Todos quedaran en \$0'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
        TextButton(onPressed: () {
          for(var k in sobres.keys) { box.put(k, 0.0); }
          setState((){}); 
          Navigator.pop(ctx);
        }, child: Text('Si, borrar', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _agregarIngreso() {
    TextEditingController ctrl = TextEditingController();
    String selected = 'Casa';
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Color(0xFFFF8C42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setM) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 80),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Cuanto ganaste hoy?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selected, 
                isExpanded: true, 
                onChanged: (v){ if(v!=null) setM(()=> selected=v); }, 
                items: sobres.keys.map((k)=> DropdownMenuItem(value:k, child: Text("Guardar en $k"))).toList()
              ),
              TextField(controller: ctrl, keyboardType: TextInputType.number, autofocus: true, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold), decoration: InputDecoration(prefixText: "\$ ")),
              if((double.tryParse(ctrl.text) ?? 0) > 0)
                Padding(padding: EdgeInsets.only(top:10), child: Text("Nuevo total: \$${(total + (double.tryParse(ctrl.text) ?? 0)).toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2EC4B6), minimumSize: Size(double.infinity, 55)),
                onPressed: () { 
                  double m = double.tryParse(ctrl.text) ?? 0; 
                  if (m > 0) { 
                    box.put(selected, (box.get(selected, defaultValue: 0.0) + m)); 
                    setState(() {}); 
                    Navigator.pop(context); 
                  } 
                },
                child: Text("Guardar en $selected"),
              )
            ]),
          );
        });
      }
    );
  }

  void _agregarGastoPreseleccionado(String pre) {
    TextEditingController ctrl = TextEditingController();
    String selected = pre;
    showModalBottomSheet(
      context: context, 
      backgroundColor: Color(0xFFFFF8E7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: StatefulBuilder(builder: (c, setM) {
            double gast = double.tryParse(ctrl.text) ?? 0;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Gastar de $selected", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              Text("Tienes: \$${box.get(selected).toStringAsFixed(0)}", style: TextStyle(color: Colors.grey)),
              TextField(controller: ctrl, keyboardType: TextInputType.number, autofocus: true, style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900), decoration: InputDecoration(prefixText: "\$ "), onChanged: (v)=> setM((){})),
              if(gast > 0)
                Text("Quedará en $selected: \$${(box.get(selected) - gast).toStringAsFixed(0)}\nTotal quedará: \$${(total - gast).toStringAsFixed(0)}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: Size(double.infinity, 50)),
                onPressed: () {
                  double g = double.tryParse(ctrl.text) ?? 0;
                  if(g>0){ 
                    box.put(selected, box.get(selected) - g); 
                    setState((){}); 
                    Navigator.pop(context); 
                  }
                },
                child: Text("Descontar \$${ctrl.text} de $selected")
              )
            ]);
          }),
        );
      }
    );
  }

  void _agregarGasto() {
    _agregarGastoPreseleccionado('Comida');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFB86A), 
        title: Text("Guardadito", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        actions: [
          IconButton(icon: Icon(Icons.delete_forever), onPressed: _borrarTodo)
        ],
      ),
      body: Column(children: [
        InkWell(
          onTap: _agregarIngreso,
          child: Container(
            width: double.infinity, 
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20), 
            decoration: BoxDecoration(color: Color(0xFF0E4D64), borderRadius: BorderRadius.circular(15)),
            child: Column(children: [
              Text("Saldo Total - Toca para agregar ganancia", style: TextStyle(color: Colors.white70, fontSize: 12)), 
              Text("\$${total.toStringAsFixed(0)}", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900))
            ])
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 2, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12, 
              children: [
                _card("Casa", sobres['Casa']!, Color(0xFFFFB86A), Icons.home),
                _card("Comida", sobres['Comida']!, Color(0xFF81B29A), Icons.restaurant),
                _card("Coppel", sobres['Coppel']!, Color(0xFFFFD166), Icons.credit_card),
                _card("Chamba", sobres['Chamba']!, Color(0xFF2EC4B6), Icons.work),
                _card("Colchon", sobres['Colchon']!, Color(0xFFF2CC8F), Icons.bed),
                _card("Gusto", sobres['Gusto']!, Color(0xFFFF9A8A), Icons.star),
              ]
            ),
          )
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: _agregarIngreso, icon: Icon(Icons.add), label: Text("Ganancia"))),
            SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(onPressed: _agregarGasto, icon: Icon(Icons.remove), label: Text("Gasto"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange))),
          ]),
        )
      ]),
    );
  }

  Widget _card(String n, double m, Color c, IconData i) {
    return InkWell(
      onTap: () => _agregarGastoPreseleccionado(n),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(15), border: Border.all(width: 3)),
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i), Spacer(), Text(n, style: TextStyle(fontWeight: FontWeight.bold)), Text("\$${m.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26))]),
          Positioned(top: 0, right: 0, child: InkWell(onTap: ()=> _borrarSobre(n), child: Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(width: 2)), child: Icon(Icons.close, size: 14)))),
        ]),
      ),
    );
  }
}
