import 'dart:io';

import 'package:flutter_demo/http/request/base_request.dart';
import 'package:flutter_demo/util/hi_constants.dart';

import 'dio_adapter.dart';
import 'hi_error.dart';
import 'hi_net_adapter.dart';

class HiNet {
  HiNet._();

  static HiNet _instance;

  static HiNet getInstance() {
    if (_instance == null) {
      _instance = HiNet._();
    }
    return _instance;
  }

  Future fire(BaseRequest request) async {
    HiNetResponse response;
    var error;
    try {
      response = await send(request);
    } on HiNetError catch (e) {
      error = e;
      response = e.data;
      printLog(e.message);
    } catch (e) {
      // 其他异常
      error = e;
      printLog(e);
    }

    if (response == null) {
      printLog(error);
    }

    var result = response?.data;

    var status = response?.statusCode;
    switch (status) {
      case 200:
        return result;
      case 401:
        throw NeedLogin();
      case 403:
        throw NeedAuth(result.toString(), data: result);
      default:
        throw HiNetError(status ?? -1, result.toString(), data: result);
    }
  }

  Future<dynamic> send<T>(BaseRequest request) async {
    request
        .addHeader("m", '1')
        .addHeader("lang", "zh-cn")
        .addHeader("device", "wap");

    printLog("header:${request.header}");

    HiNetAdapter adapter = DioApapter();
    return adapter.send(request);
  }

  void printLog(log) {
    print("hi_net:${log.toString()}");
  }
}
