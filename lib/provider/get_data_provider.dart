import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:task_project/enums/app_state.dart';
import 'package:task_project/modals/get_data_modal.dart';
import 'package:task_project/provider/base_provider.dart';

import '../constants/api_constants.dart';
import 'package:http/http.dart' as http;

class GetDataProvider extends BaseProvider {
  GetDataModal? getDataModal;
  bool scrollLoading = false;
  int page = 0;
  bool newPaginationLoading = false;

  List<Images> listImages = [];

  Future<http.Response?> getDataApi(
    BuildContext context, {
    String offset = "0",
    bool isLoading = false,
  }) async {
    http.Response? response;

    if (isLoading) {
      setState(ViewState.Busy);
    }

    try {
      Map<String, dynamic> map = {
        "user_id": "108",
        "offset": offset,
        "type": "popular"
      };
      print("map is==>$map");

      response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.getData),
        body: map,
      );
      setState(ViewState.Idle);
      getDataModal = GetDataModal.fromJson(jsonDecode(response.body));
      listImages.addAll(getDataModal?.images ?? []);
      customNotify();
      log('response ==>$response');
    } on SocketException {
      setState(ViewState.Idle);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("internet connection!"),
      ));
    } catch (e) {
      setState(ViewState.Idle);
    }
    return response;
  }

  getMaxScoll(bool scoll) {
    scrollLoading = scoll;
    customNotify();
  }

  handlePagination(BuildContext context) async {
    scrollLoading = true;
    newPaginationLoading = true;
    page++;
    notifyListeners();

    print("pages==>>${page}");

    await getDataApi(context, offset: page.toString()).then((value) {
      scrollLoading = false;
      newPaginationLoading = false;

      notifyListeners();
    });
  }
}
