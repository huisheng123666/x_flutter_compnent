import 'package:fluter_component/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImgPullDownBigPage2 extends StatefulWidget {
  const ImgPullDownBigPage2({super.key});

  @override
  createState() => _ImgPullDownBigPage2State();
}

class _ImgPullDownBigPage2State extends State<ImgPullDownBigPage2>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  double _imgNormalHeight = 240;
  double _imgChangeHeight = 0;
  double _scrollMinOffSet = 0;
  double _navH = 0;
  double appBarOpacity = 0;

  @override
  void initState() {
    Util.setStatusBarTextColor(SystemUiOverlayStyle.light);
    super.initState();
    setState(() {
      _imgNormalHeight = Util.calc(240);
      _navH = Util.topSafeHeight();
      _imgChangeHeight = _imgNormalHeight;
      _scrollMinOffSet = _imgNormalHeight - _navH;
    });
    _addListener();
  }

  void _addListener() {
    _scrollController.addListener(() {
      double y = _scrollController.offset;

      if (y < _scrollMinOffSet) {
        double imgExtraHeight = -y;
        setState(() {
          _imgChangeHeight = _imgNormalHeight + imgExtraHeight;
        });
      } else {
        setState(() {
          _imgChangeHeight = _navH;
        });
      }
      //appbar 透明度
      double opacity = y / _navH;
      if (opacity < 0) {
        opacity = 0.0;
      } else if (opacity > 1) {
        opacity = 1.0;
      }

      setState(() {
        appBarOpacity = opacity;
      });
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，_scrollController.dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        Container(
          color: const Color(0xffF0F2F5),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
                controller: _scrollController,
                itemCount: 100 + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return SizedBox(
                      width: double.infinity,
                      height: _imgNormalHeight,
                    );
                  }
                  return ListTile(title: Text("$index"));
                }),
          ),
        ),
        Positioned(
          top: 0,
          width: Util.screenWidth(context),
          height: _imgChangeHeight,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(
                    'https://api.threegorges-financial.com/file/preview?mediaId=1634099594705113088'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        AppBarWidget(opacity: appBarOpacity),
      ],
    );
  }
}

// AppBarWidget
class AppBarWidget extends StatefulWidget {
  final double opacity;

  const AppBarWidget({super.key, required this.opacity});

  @override
  State<StatefulWidget> createState() => AppBarState();
}

class AppBarState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    double appBarHeight = Util.topSafeHeight() + Util.calc(36);

    return Opacity(
      opacity: widget.opacity,
      child: Container(
        height: appBarHeight,
        padding: EdgeInsets.only(top: Util.topSafeHeight()),
        width: Util.screenWidth(context),
        color: const Color(0xff00998C),
        child: const Text(
          'x-component',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
