import 'dart:ui';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:toast/toast.dart';

double mediaWidth = 0;

class ResponseErr {
  final String msg;

  ResponseErr(this.msg);
}

class Util {
  static Dio dio = Dio();

  static LocalStorage localStorage = LocalStorage('xm_app.json');

  static bool localstorageReady = false;

  static calc(int px) {
    if (mediaWidth == 0) {
      mediaWidth = MediaQueryData.fromView(window).size.width;
    }
    return px / 375 * mediaWidth;
  }

  static screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static setStatusBarTextColor(SystemUiOverlayStyle theme, [int delay = 400]) {
    Timer(Duration(milliseconds: delay), () {
      SystemChrome.setSystemUIOverlayStyle(theme);
    });
  }

  static bottomSafeHeight() {
    return MediaQueryData.fromView(window).padding.bottom;
  }

  static topSafeHeight() {
    return MediaQueryData.fromView(window).padding.top;
  }

  static initDio(BuildContext context) {
    Util.localStorage.ready.then((value) {
      Util.localstorageReady = value;
    });

    Map headers = <String, dynamic>{
      'Content-Type': 'application/json',
    };

    Util.dio.options = BaseOptions(
      baseUrl: 'https://admin.xmw.monster/api',
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(microseconds: 3000),
      contentType: 'application/json', // Added contentType here
      headers: headers as Map<String, dynamic>?,
    );
    Util.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (Util.localstorageReady) {
          dynamic user = Util.localStorage.getItem('user');
          if (user != null) {
            options.headers['Authorization'] = 'Bearer ${user['token']}';
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data['code'] == 200) {
          return handler.next(Response(
              requestOptions: response.requestOptions, data: response.data));
        } else {
          bool canToast = true;
          if (response.requestOptions.queryParameters['noMsg'] != null) {
            canToast = !response.requestOptions.queryParameters['noMsg'];
          }
          if (canToast) {
            Toast.show(response.data['msg'], gravity: Toast.center);
          }
          if (response.data['code'] == 50001 && Util.localstorageReady) {
            Util.localStorage.clear();
          }
          return handler.resolve(Response(
              requestOptions: response.requestOptions,
              data: <String, bool>{'err': true}));
        }
      },
      onError: (e, handler) {
        Toast.show('网络错误，请稍后再试', gravity: Toast.center);
        return handler.resolve(Response(
            requestOptions: e.requestOptions,
            data: <String, bool>{'err': true}));
      },
    ));
  }
}
