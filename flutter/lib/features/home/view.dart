import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          backgroundColor: PaxColors.lightGrey,
          header: Text(
            'Dashboard',
            style: Theme.of(context).typography.base.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              color: PaxColors.black, // The purple color from your images
            ),
          ),
          subtitle: Row(
            children: [
              Tabs(
                index: index,
                children: [
                  TabItem(
                    child: Text(
                      'Dashboard',
                      style: Theme.of(context).typography.base.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color:
                            PaxColors
                                .black, // The purple color from your images
                      ),
                    ),
                  ),
                  TabItem(child: Text('Survey')),
                  TabItem(child: Text('Achievements')),
                ],
                onChanged: (int value) {
                  setState(() {
                    index = value;
                  });
                },
              ).withPadding(top: 8),
            ],
          ),
        ),
      ],
      child: Column(
        children: [
          IndexedStack(
            index: index,
            children: [
              Container(
                color: PaxColors.lightGrey,
                child: Center(child: Text('Tab 1 Content')),
              ),
              Container(
                color: PaxColors.lightGrey,
                child: Center(child: Text('Tab 2 Content')),
              ),
              Container(
                color: PaxColors.lightGrey,
                child: Center(child: Text('Tab 3 Content')),
              ),
            ],
          ).sized(height: 300),
        ],
      ),
    );
  }
}
