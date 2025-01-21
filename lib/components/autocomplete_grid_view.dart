import 'package:e_commerce_app/components/rating_star_widget.dart';
import 'package:e_commerce_app/screens/product_detail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';
import '../services/product_service.dart';

class AutocompleteGridView extends StatefulWidget {
  const AutocompleteGridView({super.key, required this.featuredItems});

  final List<Map<String, String>> featuredItems;

  @override
  State<AutocompleteGridView> createState() {
    return _AutocompleteGridViewState();
  }
}

class _AutocompleteGridViewState extends State<AutocompleteGridView> {
  final ProductService _productService = ProductService();
  List<Map<String, String>> _filteredData = [];
  GlobalKey filterKey = GlobalKey();

  List<String> getCategoryFilter(List<Map<String, String>> featuredItems) {
    List<String> suggestions = ["ALL"];
    for (final item in featuredItems) {
      suggestions.add(item['category']!);
    }
    return suggestions.toSet().toList();
  }

  List<String> getSuggestions(
      String input, List<Map<String, String>> featuredItems) {
    List<String> suggestions = [];
    for (final item in featuredItems) {
      if (item['name']!.toLowerCase().startsWith(input)) {
        suggestions.add(item['name']!);
      }
      if (item['category']!.toLowerCase().startsWith(input)) {
        suggestions.add(item['category']!);
      }
    }
    return suggestions.toSet().toList();
  }

  void showPopupMenu() {
    PopupMenu menu = PopupMenu(
        config: const MenuConfig(
          itemWidth: 200,
          itemHeight: 50,
          type: MenuType.list,
          backgroundColor: Colors.teal,
          lineColor: Colors.white,
        ),
        items: [
          MenuItem(
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              title: context.tr('strResetAll'),
              image: const Icon(
                Icons.filter_alt_off_outlined,
                color: Colors.white,
              )),
          MenuItem(
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              title: context.tr('strLowHighPrice'),
              image: const Icon(
                Icons.attach_money,
                color: Colors.white,
              )),
          MenuItem(
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              title: context.tr('strHighLowPrice'),
              image: const Icon(
                Icons.attach_money,
                color: Colors.white,
              )),
          MenuItem(
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              title: context.tr('strLowHighRating'),
              image: const Icon(
                Icons.star_border,
                color: Colors.white,
              )),
          MenuItem(
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              title: context.tr('strHighLowRating'),
              image: const Icon(
                Icons.star_border,
                color: Colors.white,
              ))
        ],
        onClickMenu: (item) {
          setState(() {
            if (item.menuTitle == context.tr('strLowHighPrice')) {
              _filteredData.sort((a, b) =>
                  int.parse(a['price']!).compareTo(int.parse(b['price']!)));
            } else if (item.menuTitle == context.tr('strHighLowPrice')) {
              _filteredData.sort((a, b) =>
                  int.parse(b['price']!).compareTo(int.parse(a['price']!)));
            } else if (item.menuTitle == context.tr('strLowHighRating')) {
              _filteredData.sort((a, b) =>
                  int.parse(a['rating']!).compareTo(int.parse(b['rating']!)));
            } else if (item.menuTitle == context.tr('strHighLowRating')) {
              _filteredData.sort((a, b) =>
                  int.parse(b['rating']!).compareTo(int.parse(a['rating']!)));
            } else {
              _filteredData.shuffle();
            }
          });
        },
        context: context);

    menu.show(widgetKey: filterKey);
  }

  void showParticularItem(Map item) async {
    String productId = item['productId'];
    Map<String, String> itemDetails =
        await _productService.particularItem(productId);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => ProductDetail(
                itemDetails: itemDetails,
                editProduct: false,
              )),
    );
  }

  @override
  void initState() {
    _filteredData = widget.featuredItems;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return getSuggestions(
                  textEditingValue.text.toLowerCase(), widget.featuredItems);
            },
            onSelected: (String selection) {
              setState(() {
                _filteredData = widget.featuredItems
                    .where((item) =>
                        item['name']!
                            .toLowerCase()
                            .startsWith(selection.toLowerCase()) ||
                        item['category']!
                            .toLowerCase()
                            .startsWith(selection.toLowerCase()))
                    .toList();
              });
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (String value) => onFieldSubmitted(),
                decoration: InputDecoration(
                  hintText: context.tr('strSearchHint'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: getCategoryFilter(widget.featuredItems)
                    .map((category) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => {
                              setState(() {
                                if (category == "ALL") {
                                  _filteredData = widget.featuredItems;
                                } else {
                                  _filteredData = widget.featuredItems
                                      .where((item) => item['category']!
                                          .toLowerCase()
                                          .startsWith(category.toLowerCase()))
                                      .toList();
                                }
                              })
                            },
                            child: Text(category.toUpperCase()),
                          ),
                        ))
                    .toList(),
              ),
            )),
            IconButton(
                key: filterKey,
                onPressed: showPopupMenu,
                icon: const Icon(Icons.filter_alt_outlined))
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            scrollDirection: Axis.vertical,
            itemCount: _filteredData.length,
            itemBuilder: (context, index) {
              var item = _filteredData[index];
              return featuredItemCard(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget featuredItemCard(item, index) {
    return InkWell(
        onTap: () {
          showParticularItem(item);
        },
        child: Card(
          elevation: 4,
          semanticContainer: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Image.asset(
                  item['imageId'],
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "\$${item['price']}.00",
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item['name'],
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style:
                          const TextStyle(fontSize: 15.0, color: Colors.grey),
                    ),
                    RatingStarWidget(rating: int.parse(item['rating']))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
