import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/product_images.dart';

Future<List<Widget>> loadAllPreviews(
    List<ProductScreenshot> previews, BuildContext context) async {
  List<Widget> previewImages = [];

  List<CachedNetworkImageProvider> cachedImages = [];
  for (ProductScreenshot preview in previews) {
    var configuration = createLocalImageConfiguration(context);
    cachedImages.add(
        CachedNetworkImageProvider(preview.imagePath)..resolve(configuration));
  }

  for (ImageProvider image in cachedImages) {
    previewImages.add(
      Container(
        padding: EdgeInsets.all(10.0),
        child: Card(
          elevation: 6.0,
          child: Center(
            child: Image(
              image: image,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }

//  for (ProductScreenshot preview in previews) {
//    previewImages.add(
//      Stack(
//        children: <Widget>[
//          Center(child: CircularProgressIndicator()),
//          Container(
//            padding: const EdgeInsets.all(10.0),
//            child: Card(
//              child: Center(
//                child: FadeInImage.assetNetwork(
//                  placeholder: 'assets/loading.gif',
//                  image: preview.imagePath,
//                  placeholderScale: 0.2,
//                ),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }

  return previewImages;
}

class _PageSelector extends StatelessWidget {
  const _PageSelector({this.previews});

  final List<ProductScreenshot> previews;

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    return new Column(
      children: <Widget>[
        new Expanded(
          child: FutureBuilder(
            future: loadAllPreviews(previews, context),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return new TabBarView(
                  children: snapshot.data,
                );
              } else if (!snapshot.hasData) {
                return Container();
              }
            },
          ),
        ),
        new Container(
          margin: const EdgeInsets.only(top: 10.0),
          child: new TabPageSelector(controller: controller),
        ),
      ],
    );
  }
}

class ProductPreview extends StatelessWidget {
  final List<ProductScreenshot> previews;

  ProductPreview(this.previews);

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: previews.length,
      child: new _PageSelector(previews: previews),
    );
  }
}
