import 'package:flutter/material.dart';

class CustomFab extends StatefulWidget {
  final List<SubButton> subButtons;

  CustomFab({@required this.subButtons});

  @override
  State<StatefulWidget> createState() {
    return CustomFabState();
  }
}

class CustomFabState extends State<CustomFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Animation<double> _scaleButton;
  Animation<double> _slideOutLabel;
  double _fabHeight = 56.0;
  Curve _curve = Curves.easeOut;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.00,
          1.00,
          curve: _curve,
        ),
      ),
    );
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -15, // When the animation value is negative, it acts as padding
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          1,
          curve: _curve,
        ),
      ),
    );
    _scaleButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          1,
          curve: _curve,
        ),
      ),
    );
    _slideOutLabel = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          1,
          curve: _curve,
        ),
      ),
    );
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        ..._buildButtonColumn(),
        _buildToggle(),
      ],
    );
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  _buildToggle() {
    return FloatingActionButton(
      backgroundColor: _animateColor.value,
      onPressed: animate,
      tooltip: 'Toggle',
      child: AnimatedIcon(
        icon: AnimatedIcons.close_menu,
        progress: _animateIcon,
      ),
    );
  }

  _buildButtonColumn() {
    return widget.subButtons
        .asMap()
        .map(
          (index, subButton) => _buildButton(
            index: index,
            icon: subButton.icon,
            label: subButton.label,
            tooltip: subButton.tooltip,
            onPressed: subButton.onPressed,
          ),
        )
        .values
        .toList();
  }

  _buildButton({
    @required int index,
    @required IconData icon,
    @required String label,
    @required String tooltip,
    @required Function onPressed,
  }) {
    return MapEntry(
      index,
      Transform(
        transform: Matrix4.translationValues(0,
            _translateButton.value * (widget.subButtons.length - (index)), 0),
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: <Widget>[
            Opacity(
              opacity: _animationController.value,
              child: Container(
                width: _slideOutLabel.value,
                height: 50,
                padding: const EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                /*
                *  Box shadow equals material elevation 4
                *  https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/shadows.dart
                */
                boxShadow: kElevationToShadow[4],
                child: Text(
                  label,
                ),
              ),
            ),
            Transform.scale(
              scale: 1, //_animationController.value,
              child: FloatingActionButton(
                tooltip: tooltip,
                onPressed: onPressed,
                elevation: _animationController.value,
                child: Icon(icon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubButton {
  IconData icon;
  String label;
  String tooltip;
  Function onPressed;

  SubButton({
    @required this.icon,
    @required this.label,
    @required this.tooltip,
    @required this.onPressed,
  });
}
