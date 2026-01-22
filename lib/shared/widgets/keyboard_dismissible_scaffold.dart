import 'package:flutter/material.dart';

/// 키보드를 외부 터치로 닫을 수 있는 Scaffold 래퍼
///
/// 모든 화면에서 사용 가능하며, 키보드가 올라온 상태에서
/// 빈 공간을 터치하면 자동으로 키보드가 내려갑니다.
class KeyboardDismissibleScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Widget? drawer;
  final Widget? endDrawer;

  const KeyboardDismissibleScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.drawer,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 키보드 외부 터치 시 키보드 닫기
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      // GestureDetector가 빈 공간도 감지하도록 설정
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        drawer: drawer,
        endDrawer: endDrawer,
      ),
    );
  }
}
