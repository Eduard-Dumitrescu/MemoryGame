import 'dart:collection';
import 'dart:math';

import 'package:clay_containers/clay_containers.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_game/icon_assets.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          width: width,
          height: height,
          child: GameScreen(width, height, Color(0xff0c2b69)),
        ));
  }
}

class GameScreen extends StatefulWidget {
  final double width;
  final double height;
  final Color mainColor;

  const GameScreen(this.width, this.height, this.mainColor, {Key key})
      : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ValueNotifier<String> _mesg = ValueNotifier<String>("");

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
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.mainColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 8,
            child: _game(4),
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
                            parentColor: widget.mainColor,
                            color: Colors.white,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
              }),
          Flexible(
            flex: 1,
            child: ClayContainer(
              color: widget.mainColor,
              child: RaisedButton(
                color: widget.mainColor,
                onPressed: () async {
                  setState(() {
                    _resetEverything();
                  });
                },
                child: ClayText(
                  "Reset",
                  parentColor: widget.mainColor,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
      _mesg.value = "You won!";
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
          color: widget.mainColor,
          child: Center(
            child: Center(
              child: ClayText(
                "Touch me",
                emboss: true,
                parentColor: widget.mainColor,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      back: ClayContainer(
        color: widget.mainColor,
        child: Container(
          color: widget.mainColor,
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
