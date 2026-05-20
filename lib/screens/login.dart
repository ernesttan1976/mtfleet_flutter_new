import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final String? error;

  LoginScreen({Key? key, this.error}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    if (widget.error != null) {
      print("Error: ${widget.error}");
      WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.error!),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.yellow,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          )));
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void displayDialog(BuildContext context, String title, String text) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Row(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(text),
              ),
            ],
          ),
        ),
      );

  void onFormSubmit() async {
    Navigator.pushNamed(context, "/loginWebView");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: SafeArea(
                  child: Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.22, 20, 0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                            child: Text('Welcome',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Text('Please click the button below to login to the app',
                                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1)),
                          Container(
                              child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: Column(children: <Widget>[
                                    Container(
                                        color: Colors.transparent,
                                        width: MediaQuery.of(context).size.width,
                                        // height: 60,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: new BorderRadius.circular(30.0),
                                              ),
                                            ),
                                            padding: MaterialStateProperty.all(EdgeInsets.all(8.0)),
                                            backgroundColor:
                                                MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                                            textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                                              color: Colors.white,
                                            )),
                                          ),
                                          /*shape: new RoundedRectangleBorder(
                                            borderRadius: new BorderRadius.circular(30.0),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          textColor: Colors.white,
                                          color: Theme.of(context).primaryColor,*/
                                          onPressed: this.onFormSubmit,
                                          child: Text('Login'),
                                        )),
                                    Container(
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: Text(
                                            'Not registered? Please contact your company for your login details.',
                                            style: Theme.of(context).textTheme.bodyText2,
                                            textAlign: TextAlign.center)),
                                    Container(
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                                        child: Text(
                                            'To reset your password, please contact your company for more details. Thank you.',
                                            style: Theme.of(context).textTheme.bodyText2,
                                            textAlign: TextAlign.center)),
                                  ])))
                        ],
                      ))),
            )));
  }
}
