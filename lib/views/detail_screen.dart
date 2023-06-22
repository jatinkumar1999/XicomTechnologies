import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_project/enums/app_state.dart';
import 'package:task_project/provider/detail_screen_provider.dart';
import 'package:task_project/views/base_view.dart';

class DetailPage extends StatefulWidget {
  final String? image;
  const DetailPage({Key? key, this.image}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return BaseView<DetailProvider>(
      onModelReady: (provider) {
        provider.saveImageFromUrl(widget.image!);
      },
      builder: (context, provider, _) => LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Detail Screen "),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                controller: provider.scrollController,
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.image ?? '',
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, _, __) => Image.asset(
                            'assets/place_holder_image.jpg',
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FieldsTile(
                        controller: provider.firstNameController,
                        keyboardType: TextInputType.name,
                        onTap: () {
                          provider.scrollToFormField(
                              context, constraints.maxHeight);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter first name';
                          } else {
                            return null;
                          }
                        },
                        title: "First Name",
                      ),
                      const SizedBox(height: 20),
                      FieldsTile(
                        controller: provider.lastNameController,
                        keyboardType: TextInputType.name,
                        onTap: () {
                          provider.scrollToFormField(
                              context, constraints.maxHeight);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter last name';
                          } else {
                            return null;
                          }
                        },
                        title: "Last Name",
                      ),
                      const SizedBox(height: 20),
                      FieldsTile(
                        controller: provider.emailNameController,
                        keyboardType: TextInputType.emailAddress,
                        onTap: () {
                          provider.scrollToFormField(
                              context, constraints.maxHeight);
                        },
                        title: "Email",
                        validator: (value) {
                          final bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!);

                          if (value.isEmpty) {
                            return 'Please enter email';
                          } else if (!emailValid) {
                            return "please enter a valid email";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      FieldsTile(
                        controller: provider.phoneNameController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false, signed: false),
                        title: "Phone",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter phone number';
                          } else {
                            return null;
                          }
                        },
                        onTap: () {
                          provider.scrollToFormField(
                              context, constraints.maxHeight);
                        },
                      ),
                      const SizedBox(height: 20),
                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            provider.state == ViewState.Busy
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();

                                      if (provider.formKey.currentState!
                                          .validate()) {
                                        await provider
                                            .sendMultipartRequest(context);
                                      }
                                    },
                                    child: const Text("submit"),
                                  ),
                            const SizedBox(width: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FieldsTile extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const FieldsTile({
    Key? key,
    this.onTap,
    this.title,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title ?? "",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                focusedErrorBorder: OutlineInputBorder(),
                errorBorder: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
