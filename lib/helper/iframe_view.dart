import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
// 기존 dart:html 대신 최신 package:web 라이브러리를 사용합니다.
import 'package:web/web.dart' as web;

class IframeView extends StatefulWidget {
  final String source;

  const IframeView({Key? key, required this.source}) : super(key: key);

  @override
  State<IframeView> createState() => _IframeViewState();
}

class _IframeViewState extends State<IframeView> {
  // HTML의 IFrame 요소를 생성합니다.
  final web.HTMLIFrameElement _iframeElement = web.HTMLIFrameElement();

  @override
  void initState() {
    super.initState();

    // IFrame 설정
    _iframeElement.src = widget.source;
    _iframeElement.style.border = 'none';
    _iframeElement.style.width = '100%';
    _iframeElement.style.height = '100%';

    // [중요] 최신 Flutter 웹의 방식: dart:ui_web을 사용해 등록합니다.
    ui.platformViewRegistry.registerViewFactory(
      widget.source,
      (int viewId) => _iframeElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 등록된 IFrame을 Flutter 위젯으로 띄웁니다.
    return HtmlElementView(
      viewType: widget.source,
    );
  }
}
