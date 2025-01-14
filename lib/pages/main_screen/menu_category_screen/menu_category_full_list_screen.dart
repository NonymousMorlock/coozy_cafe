import 'package:coozy_cafe/AppLocalization.dart';
import 'package:coozy_cafe/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_cafe/model/category.dart';
import 'package:coozy_cafe/model/sub_category.dart';
import 'package:coozy_cafe/pages/main_screen/menu_category_screen/menu_sub_category_expansion_child_listview_widget.dart';
import 'package:coozy_cafe/utlis/utlis.dart';
import 'package:coozy_cafe/widgets/empty_category_full_list_body.dart';
import 'package:coozy_cafe/widgets/post_time_text_widget/post_time_text_widget.dart';
import 'package:coozy_cafe/widgets/responsive_layout/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuCategoryFullListScreen extends StatefulWidget {
  const MenuCategoryFullListScreen({super.key});

  @override
  _MenuCategoryFullListScreenState createState() =>
      _MenuCategoryFullListScreenState();
}

class _MenuCategoryFullListScreenState
    extends State<MenuCategoryFullListScreen> {
  ScrollController? _controller = ScrollController();
  String? searchQuery = '';
  TextEditingController? searchController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: "");
    searchQuery = "";
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<MenuCategoryFullListCubit>(context).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text(
              "Menu Category",
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () async {
                  await handleNewCategory();
                },
                icon: const Icon(
                  Icons.add,
                ),
                tooltip: AppLocalizations.of(context)?.translate(
                        StringValue.add_menu_category_icon_tooltip_text) ??
                    "Add a new menu category",
              ),
            ],
          ),
          body: BlocConsumer<MenuCategoryFullListCubit,
              MenuCategoryFullListState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              if (state is InitialState) {
                return Container();
              } else if (state is LoadingState) {
                return Container();
              } else if (state is LoadedState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: SearchAnchor(
                              builder: (BuildContext context,
                                  SearchController controller) {
                                return SearchBar(
                                  controller: controller,
                                  padding: const MaterialStatePropertyAll<
                                          EdgeInsets>(
                                      EdgeInsets.symmetric(horizontal: 10.0)),
                                  onTap: () {
                                    controller.openView();
                                  },
                                  onChanged: (_) {
                                    if (!controller.isOpen) {
                                      scrollToItemAndExpand(controller.text);
                                    } else {
                                      controller.openView();
                                    }
                                  },
                                  onSubmitted: (value) {
                                    scrollToItemAndExpand(value);
                                  },
                                  leading: const Icon(Icons.search),
                                );
                              },
                              isFullScreen: false,
                              viewConstraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * .35,
                              ),
                              suggestionsBuilder: (BuildContext context,
                                  SearchController controller) {
                                List<String> suggestions = [];
                                if (state.data != null &&
                                    state.data!.isNotEmpty &&
                                    state.data!.containsKey("categories") &&
                                    state.data!['categories'] != null) {
                                  state.data!['categories'].forEach((category) {
                                    suggestions
                                        .add(category['name'].toString());

                                    if (category['subCategories'] != null) {
                                      // Ensure that 'subCategories' is a List<Map<String, dynamic>>
                                      suggestions.addAll((category[
                                              'subCategories'] as List<dynamic>)
                                          .map((subCategory) =>
                                              subCategory['name'].toString()));
                                    }
                                  });
                                } else {
                                  suggestions = [];
                                }
                                List<Widget> suggestionWidgets = suggestions
                                    .where((suggestion) => suggestion
                                        .toLowerCase()
                                        .contains(controller.value.text
                                            .toLowerCase()))
                                    .map((suggestion) => ListTile(
                                          title: Text(suggestion),
                                          onTap: () {
                                            setState(() {
                                              controller.closeView(suggestion);
                                            });
                                          },
                                        ))
                                    .toList();
                                return suggestionWidgets.isEmpty
                                    ? [
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                                child: Text("No suggestions")),
                                          ],
                                        )
                                      ]
                                    : suggestionWidgets;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: menuItemWidget(state),
                    ),
                  ],
                );
              } else if (state is ErrorState) {
                return Container();
              } else if (state is NoInternetState) {
                return Container();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  // menuItemWidget(result!["categories"]) ,
  Widget menuItemWidget(LoadedState state) {
    var map = state.data?["categories"];
    if (map != null && map.isNotEmpty) {
      return CustomScrollView(
        shrinkWrap: true,
        controller: _controller,
        physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              var category = map![index];
              return menuCategoryExpansionTileItem(
                  state: state,
                  model: category,
                  index: index,
                  totalItemLength: map?.length ?? 0);
            },
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: false,
                childCount: map?.length ?? 0),
          ),
        ],
      );
    } else {
      return EmptyCategoryFullListBody(onAddNewCategory: handleNewCategory);
    }
  }

  Widget menuCategoryExpansionTileItem(
      {required LoadedState state,
      dynamic model,
      required int index,
      required int totalItemLength}) {
    Category category = Category(
        id: model["id"],
        createdDate: model["createdDate"],
        name: model["name"]);

    List<dynamic>? dynamicSubCategories =
        model["subCategories"] as List<dynamic>?;

    List<SubCategory>? subCategoryList =
        SubCategory.convertDynamicListToSubCategoryList(dynamicSubCategories);
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: Padding(
        padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 10,
            bottom: (index < totalItemLength - 1) ? 0 : 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ExpansionTile(
            // shape: Border(),
            key: state.expansionTileKeys![index] ?? GlobalKey(),
            maintainState: true,
            collapsedBackgroundColor: theme.colorScheme.primaryContainer,
            backgroundColor: theme.colorScheme.primaryContainer,
            childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
            subtitle: PostTimeTextWidget(
              key: UniqueKey(),
              creationDate: category.createdDate ?? "",
              localizedCode: AppLocalizations.getCurrentLanguageCode(context),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: Text(category.name ?? "")),
              ],
            ),
            controller: state.expandedTitleControllerList![index],
            children: <Widget>[
              Visibility(
                visible: (subCategoryList != null && subCategoryList.isNotEmpty)
                    ? true
                    : false,
                child: ResponsiveLayout(
                  mobile: MenuSubCategoryExpansionChildListViewWidget(
                      key: UniqueKey(),
                      subCategoryList: subCategoryList,
                      itemsToShow: 5),
                  tablet: MenuSubCategoryExpansionChildListViewWidget(
                      key: UniqueKey(),
                      subCategoryList: subCategoryList,
                      itemsToShow: 10),
                  desktop: MenuSubCategoryExpansionChildListViewWidget(
                    key: UniqueKey(),
                    subCategoryList: subCategoryList,
                    itemsToShow: 10,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void scrollToItemAndExpand(String keyword) {
    if (BlocProvider.of<MenuCategoryFullListCubit>(context).state
        is LoadedState) {
      LoadedState loadedState =
          BlocProvider.of<MenuCategoryFullListCubit>(context).state
              as LoadedState;

      int index = -1;
      /*
      /*this also working Fine*/
      for (int i = 0; i < loadedState.data!['categories'].length; i++) {
        var category = loadedState.data!['categories'][i];
        if (category['name'].toString().toLowerCase() ==
            keyword.toLowerCase()) {
          index = i;
          break;
        }

        if (category['subCategories'] != null) {
          var subCategories = category['subCategories'];
          for (int j = 0; j < subCategories.length; j++) {
            if (subCategories[j]['name'].toString().toLowerCase() ==
                keyword.toLowerCase()) {
              index = i;
              break;
            }
          }
        }
      }*/

      index = loadedState.data!['categories'].indexWhere((category) {
        bool isCategoryMatch =
            category['name'].toString().toLowerCase() == keyword.toLowerCase();

        if (isCategoryMatch) {
          return true;
        }

        if (category['subCategories'] != null) {
          return (category['subCategories'] as List).any((subCategory) =>
              subCategory['name'].toString().toLowerCase() ==
              keyword.toLowerCase());
        }

        return false;
      });

      if (index != -1) {
        // Obtain the RenderBox
        RenderBox renderBox = loadedState
            .expansionTileKeys![index]!.currentContext
            ?.findRenderObject() as RenderBox;

        // Get the size of the RenderBox
        double itemHeight = renderBox.size.height;

        // Calculate the position
        double position = index * itemHeight;

        setState(() {
          // Toggle the isExpanded state
          if ((loadedState.expandedTitleControllerList != null ||
                  loadedState.expandedTitleControllerList!.isNotEmpty) &&
              loadedState.expandedTitleControllerList![index].isExpanded ==
                  false) {
            loadedState.expandedTitleControllerList![index].expand();
          }
        });

        // Scroll and toggle the isExpanded state
        _controller!.animateTo(
          position,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> handleNewCategory() async {
    navigationRoutes.navigateToAddNewMenuCategoryScreen().then(
        (value) async => context.read<MenuCategoryFullListCubit>().loadData());
  }
}
