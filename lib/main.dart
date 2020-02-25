import 'dart:collection';
import 'dart:math';

import 'package:clay_containers/clay_containers.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_game/icon_assets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<String> _mesg = ValueNotifier<String>("");
  final Color mainColor = Color(0xff0c2b69);

  int totalFlippedCards = 0;
  HashMap<GlobalKey<FlipCardState>, int> _flippedCards =
      HashMap<GlobalKey<FlipCardState>, int>();

  List<int> _values;
  List<String> _icons;
  List<GlobalKey<FlipCardState>> _cardKeys = List<GlobalKey<FlipCardState>>();

  @override
  void initState() {
    _values = List<int>.generate(16, (i) => i + 1)
        .map((num) => num % 2 == 0 ? num - 1 : num)
        .toList();
    _values.shuffle(Random.secure());

    _icons = IconAssets.assets.take(16).toList();
    _icons.shuffle(Random.secure());

    for (int j = 0; j < 16; j++) {
      _cardKeys.add(GlobalKey<FlipCardState>());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: mainColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 8,
              child: _game(4),
//              GridView.count(
//                physics: NeverScrollableScrollPhysics(),
//                mainAxisSpacing: 8.0,
//                crossAxisSpacing: 8.0,
//                padding: const EdgeInsets.all(20),
//                childAspectRatio: 3.0 / 4.0,
//                crossAxisCount: 4,
//                children: _values
//                    .asMap()
//                    .map((index, num) {
//                      return MapEntry(index, _card(_cardKeys[index], num));
//                    })
//                    .values
//                    .toList(),
            ),
            ValueListenableBuilder<String>(
                valueListenable: _mesg,
                builder: (context, mesg, _) {
                  return mesg.isEmpty
                      ? Container()
                      : Flexible(
                          flex: 1,
                          child: Center(
                            child: ClayText(
                              mesg,
                              parentColor: mainColor,
                              color: Colors.white,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                }),
            Flexible(
              flex: 1,
              child: ClayContainer(
                color: mainColor,
                child: RaisedButton(
                  color: mainColor,
                  onPressed: () async {
                    setState(() {
                      _resetEverything();
                    });
                  },
                  child: ClayText(
                    "Restart this shit",
                    parentColor: mainColor,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _maybeReset() {
    if (_flippedCards.values.toList()[0] != _flippedCards.values.toList()[1]) {
      _flippedCards.keys.forEach((key) => key.currentState.toggleCard());
      totalFlippedCards -= 2;
    }
    _flippedCards.clear();
    if (totalFlippedCards == _values.length) {
      _mesg.value = "GG fag you won now get a life";
    }
  }

  Widget _game(int columns) {
    List<Widget> rows = new List<Widget>();
    for (int i = 0; i < _values.length / columns; i++) {
      List<Widget> elements = List<Widget>();
      for (int j = 0; j < columns; j++) {
        int index = i * columns + j;
        elements.add(Flexible(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _card(_cardKeys[index], _values[index]))));
      }

      rows.add(Flexible(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: elements,
        ),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rows,
    );
  }

  _resetEverything() {
    _mesg.value = "";
    totalFlippedCards = 0;

    _cardKeys.forEach((el) {
      if (!el.currentState.isFront) {
        el.currentState.toggleCard();
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () async {
      _flippedCards.clear();
      _values.shuffle(Random.secure());
      _icons = IconAssets.assets.take(16).toList();
      _icons.shuffle(Random.secure());
    });
  }

  Widget _card(GlobalKey<FlipCardState> cardKey, int num) {
    return FlipCard(
      key: cardKey,
      flipOnTouch: false,
      direction: FlipDirection.HORIZONTAL,
      front: InkWell(
        onTap: () async {
          if (_flippedCards.length != 2) {
            cardKey.currentState.toggleCard();
            _flippedCards[cardKey] = num;
            totalFlippedCards++;
            if (_flippedCards.length == 2)
              Future.delayed(
                  const Duration(milliseconds: 500), () async => _maybeReset());
          }
        },
        child: ClayContainer(
          color: mainColor,
          child: Center(
            child: Center(
              child: ClayText(
                "Touch me",
                emboss: true,
                parentColor: mainColor,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      back: ClayContainer(
        color: mainColor,
        child: Container(
          color: mainColor,
          alignment: Alignment.center,
          child: SvgPicture.asset(_icons[num]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mesg.dispose();
    super.dispose();
  }
}
