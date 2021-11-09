import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';
import 'package:flutter_smart_dialog/src/custom/custom_loading.dart';
import 'package:flutter_smart_dialog/src/custom/custom_toast.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';
import 'package:flutter_smart_dialog/src/widget/toast_helper.dart';
import 'package:flutter_smart_dialog/src/widget/toast_widget.dart';

import '../smart_dialog.dart';
import 'config.dart';

class DialogProxy {
   Config config;
   OverlayEntry entryToast;
   OverlayEntry entryLoading;
   Map<String, DialogInfo> dialogMap;
   List<DialogInfo> dialogList;
   CustomToast _toast;
   CustomLoading _loading;

  bool loadingBackDismiss = true;
  DateTime dialogLastTime;

  factory DialogProxy() => instance;
  static DialogProxy _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  static  BuildContext context;

  DialogProxy._internal() {
    config = Config();

    dialogMap = {};
    dialogList = [];
  }

  void initialize() {
    entryLoading = OverlayEntry(
      builder: (BuildContext context) => _loading.getWidget(),
    );
    entryToast = OverlayEntry(
      builder: (BuildContext context) => _toast.getWidget(),
    );

    _loading = CustomLoading(
      config: config,
      overlayEntry: entryLoading,
    );
    _toast = CustomToast(config: config, overlayEntry: entryToast);
  }

  Future<void> show({
    @required Widget widget,
    @required AlignmentGeometry alignment,
    @required bool isPenetrate,
    @required bool isUseAnimation,
    @required Duration animationDuration,
    @required bool isLoading,
    @required Color maskColor,
    @required bool clickBgDismiss,
    @required Widget maskWidget,
    @required bool antiShake,
    @required VoidCallback onDismiss,
    @required String tag,
    @required bool backDismiss,
  }) {
    CustomDialog dialog;
    var entry = OverlayEntry(
      builder: (BuildContext context) => dialog.getWidget(),
    );
    dialog = CustomDialog(config: config, overlayEntry: entry);
    return dialog.show(
      widget: widget,
      alignment: alignment,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
      antiShake: antiShake,
      tag: tag,
      backDismiss: backDismiss,
    );
  }

  Future<void> showLoading({
    @required String msg,
    @required Color background,
    @required bool clickBgDismiss,
    @required bool isLoading,
    @required bool isPenetrate,
    @required bool isUseAnimation,
    @required Duration animationDuration,
    @required Color maskColor,
    @required Widget maskWidget,
    @required Widget widget,
    @required bool backDismiss,
  }) {
    return _loading.showLoading(
      widget: widget ?? LoadingWidget(msg: msg, background: background),
      clickBgDismiss: clickBgDismiss,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      backDismiss: backDismiss,
    );
  }

  Future<void> showToast(
    String msg, {
    @required Duration time,
    @required AlignmentGeometry alignment,
    @required bool antiShake,
    @required Widget widget,
  }) async {
    _toast.showToast(
      time: time,
      antiShake: antiShake,
      widget: ToastHelper(
        child: widget ?? ToastWidget(msg: msg, alignment: alignment),
      ),
    );
  }

  Future<void> dismiss({
    SmartStatus status,
    String tag,
    bool back = false,
  }) async {
    if (status == null) {
      if (!config.isExistLoading)
        await CustomDialog.dismiss(tag: tag, back: back);
      if (config.isExistLoading) await _loading.dismiss(back: back);
    } else if (status == SmartStatus.dialog) {
      await CustomDialog.dismiss(tag: tag, back: back);
    } else if (status == SmartStatus.loading) {
      await _loading.dismiss(back: back);
    } else if (status == SmartStatus.toast) {
      await _toast.dismiss();
    } else if (status == SmartStatus.allDialog) {
      await _closeAllDialog(status: SmartStatus.dialog);
    }
  }

  Future<void> _closeAllDialog({SmartStatus status}) async {
    var length = dialogList.length;
    for (var i = 0; i < length; i++) {
      var item = dialogList[dialogList.length - 1];

      await dismiss(status: status);
      if (item.isUseAnimation) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
  }
}
