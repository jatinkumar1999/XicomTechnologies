import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../constants/api_constants.dart';
import '../enums/app_state.dart';
import '../modals/save_data_modal.dart';
import 'base_provider.dart';

class DetailProvider extends BaseProvider {
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailNameController = TextEditingController();
  final phoneNameController = TextEditingController();
  File? image;
  void scrollToFormField(context, double maxHeight) {
    final screenHeight = MediaQuery.of(context).size.height;

    final keyboardHeight = screenHeight - maxHeight;

    scrollController.animateTo(
      keyboardHeight,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  Future<void> saveImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final currentTime = DateTime.now();
      final timestamp = currentTime.millisecondsSinceEpoch;
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$timestamp.jpg';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      image = file;
      notifyListeners();

      print('Image saved successfully!');
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<void> sendMultipartRequest(BuildContext context) async {
    setState(ViewState.Busy);
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.saveData);

    var request = http.MultipartRequest('POST', url);

    request.fields['first_name'] = firstNameController.text.trim();
    request.fields['last_name'] = lastNameController.text.trim();
    request.fields['email'] = emailNameController.text.trim();
    request.fields['phone'] = phoneNameController.text.trim();

    var imageFile = File(image!.path);
    var multipartFile =
        await http.MultipartFile.fromPath('user_image', imageFile.path);

    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      setState(ViewState.Idle);

      print(responseString);
      SaveDataModal saveDataModal =
          SaveDataModal.fromJson(json.decode(responseString));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(saveDataModal.message ?? ""),
      ));
      Navigator.of(context).pop();
    } else {
      setState(ViewState.Idle);

      // Request failed
      print('Error: ${response.statusCode}');
    }
  }

  Future<http.Response?> saveUserData(
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
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "email": emailNameController.text.trim(),
        "phone": phoneNameController.text.trim(),
        "user_image": image,
      };
      print("map is==>$map");

      response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.saveData),
        body: map,
      );
      setState(ViewState.Idle);

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
}
