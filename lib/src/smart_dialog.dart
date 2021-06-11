import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/strategy/dialog_strategy.dart';
import 'package:flutter_smart_dialog/src/strategy/toast_strategy.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';

import 'config/config.dart';
import 'strategy/action.dart';
import 'strategy/loading_strategy.dart';
import 'widget/toast_widget.dart';

class SmartDialog {
  ///SmartDialog相关配置,使用Config管理
  late Config config;

  late OverlayEntry entryMain;
  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;

  ///-------------------------私有类型，不对面提供修改----------------------
  ///提供全局单例
  ///工厂模式
  factory SmartDialog() => _getInstance();

  static SmartDialog? _instance;
  static late DialogAction _actionMain;
  static late DialogAction _actionToast;
  static late DialogAction _actionLoading;

  static SmartDialog get instance => _getInstance();

  static SmartDialog _getInstance() {
    if (_instance == null) {
      _instance = SmartDialog._internal();
    }
    return _instance!;
  }

  SmartDialog._internal() {
    ///初始化一些参数
    config = Config();

    entryMain = OverlayEntry(
      builder: (BuildContext context) {
        return _actionMain.getWidget();
      },
    );
    entryLoading = OverlayEntry(
      builder: (BuildContext context) {
        return _actionLoading.getWidget();
      },
    );
    entryToast = OverlayEntry(
      builder: (BuildContext context) {
        return _actionToast.getWidget();
      },
    );


    _actionMain = DialogStrategy(config: config, overlayEntry: entryMain);
    _actionLoading = LoadingStrategy(
      config: config,
      overlayEntry: entryLoading,
    );
    _actionToast = ToastStrategy(config: config, overlayEntry: entryToast);
  }

  ///使用自定义布局
  ///
  /// 使用'Temp'为后缀的属性，在此处设置，并不会影响全局的属性，未设置‘Temp’为后缀的属性，
  /// 则默认使用Config设置的全局属性
  static Future<void> show({
    required Widget widget,
    AlignmentGeometry? alignmentTemp,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    bool? isLoadingTemp,
    Color? maskColorTemp,
    bool? clickBgDismissTemp,
    //overlay弹窗消失回调
    VoidCallback? onDismiss,
  }) {
    return _actionMain.show(
      widget: widget,
      alignment: alignmentTemp ?? instance.config.alignment,
      isPenetrate: isPenetrateTemp ?? instance.config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? instance.config.isUseAnimation,
      animationDuration:
          animationDurationTemp ?? instance.config.animationDuration,
      isLoading: isLoadingTemp ?? instance.config.isLoading,
      maskColor: maskColorTemp ?? instance.config.maskColor,
      clickBgDismiss: clickBgDismissTemp ?? instance.config.clickBgDismiss,
      onDismiss: onDismiss,
    );
  }

  ///提供loading弹窗
  static Future<void> showLoading({
    String msg = 'loading...',
    Color background = Colors.black,
    bool clickBgDismissTemp = false,
    bool isLoadingTemp = true,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    Color? maskColorTemp,
    Widget? widget,
  }) {
    return _actionLoading.showLoading(
      widget: widget ?? LoadingWidget(msg: msg, background: background),
      clickBgDismiss: clickBgDismissTemp,
      isLoading: isLoadingTemp,
      maskColorTemp: maskColorTemp,
      isPenetrateTemp: isPenetrateTemp,
      isUseAnimationTemp: isUseAnimationTemp,
      animationDurationTemp: animationDurationTemp,
    );
  }

  ///提供toast示例
  static Future<void> showToast(
    String msg, {
    Duration time = const Duration(milliseconds: 1500),
    alignment: Alignment.bottomCenter,
    //默认消失类型,类似android的toast,toast一个一个展示
    //非默认消失类型,多次点击,后面toast会顶掉前者的toast显示
    bool isDefaultDismissType = true,
    Widget? widget,
  }) async {
    _actionToast.showToast(
      time: time,
      isDefaultDismissType: isDefaultDismissType,
      widget: widget ?? ToastWidget(msg: msg, alignment: alignment),
    );
  }

  ///关闭Dialog
  ///
  /// closeType：关闭类型
  ///
  /// 0：关闭主体OverlayEntry和loading
  /// 1：仅关闭主体OverlayEntry
  /// 2：仅关闭Toast
  /// 3：仅关闭loading
  /// 4：都关闭
  static Future<void> dismiss({int closeType = 0}) async {
    if (closeType == 0) {
      _actionMain.dismiss();
      _actionLoading.dismiss();
    } else if (closeType == 1) {
      _actionMain.dismiss();
    } else if (closeType == 2) {
      _actionToast.dismiss();
    } else if (closeType == 3) {
      _actionLoading.dismiss();
    } else {
      _actionMain.dismiss();
      _actionToast.dismiss();
      _actionLoading.dismiss();
    }
  }
}
