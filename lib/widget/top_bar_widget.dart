import 'package:fireauth/screens/bottom_nav_bar_screen.dart';
import 'package:fireauth/screens/landing_page.dart';
import 'package:fireauth/service/profile_provider.dart';
import 'package:fireauth/utils/spacer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Row(
            children: <Widget>[
              const Text(
                'Explore thousands of\nbooks on the go',
                style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'Mollen',
                  letterSpacing: 2,
                ),
              ),
              HorizontalSpace(w: MediaQuery.of(context).size.width * .22),
              const Center(
                child: Text(
                  'Books',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Mollen',
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/fav');
                  },
                  icon: const Icon(Icons.favorite_border)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              !profileProvider.isAuthentificated
                                  ? const LandingPage(
                                      skip: false,
                                    )
                                  : UserWidget(
                                      profileProvider: profileProvider,
                                    )),
                    );
                  },
                  icon: const Icon(Icons.person)),
            ],
          ),
        ),
      ],
    );
  }
}
