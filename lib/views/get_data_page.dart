import 'package:flutter/material.dart';
import 'package:task_project/enums/app_state.dart';
import 'package:task_project/views/base_view.dart';
import '../provider/get_data_provider.dart';
import 'detail_screen.dart';

class GetDataPage extends StatelessWidget {
  const GetDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<GetDataProvider>(
      onModelReady: (provider) {
        provider.getDataApi(context, isLoading: true);
      },
      builder: (context, provider, _) => Scaffold(
          body: provider.state == ViewState.Busy
              ? const Center(child: CircularProgressIndicator())
              : NotificationListener(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      provider.getMaxScoll(true);
                    } else {
                      provider.getMaxScoll(false);
                    }
                    return true;
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.listImages.length ?? 0,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailPage(
                                          image: provider
                                              .listImages[index].xtImage,
                                        ),
                                      ));
                                },
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        provider.listImages[index].xtImage ??
                                            '',
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.fitWidth,
                                        errorBuilder: (context, _, __) =>
                                            Image.asset(
                                          'assets/place_holder_image.jpg',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        provider.newPaginationLoading
                            ? const Center(child: CircularProgressIndicator())
                            : GestureDetector(
                                child: Container(
                                  height: provider.scrollLoading ? 50.0 : 0,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: provider.scrollLoading
                                          ? () {
                                              provider
                                                  .handlePagination(context);
                                            }
                                          : () {},
                                      child:
                                          const Text("Click here to load more"),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                )),
    );
  }
}
