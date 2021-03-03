BasePage was based on this article: 
https://medium.com/flutter-community/mixins-and-base-classes-a-recipe-for-success-in-flutter-bc3fbb5da670

The primary function of BasePage is to minimize code duplication that needs to be shared between all pages.

One of the common components between all of the pages is the Scaffold widget. This widget manages the appBar 
(navigation bar), floating action button, and the body of a page. When inheriting the BasePage, override
the following two varibales:

Widget body();
Widget fab() => Container();

body will be the body of the page and fab is the floating action button.

class NewPage extends BasePage {
  NewPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends BaseState<NewPage> with BasicPage {}
