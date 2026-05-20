import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class QuizScreen extends StatefulWidget {
  final Function? setSelection;
  final Function? onNext;
  final Function? onPrev;
  final dynamic quiz;
  final int? totalQuiz;
  final int? index;
  final dynamic selectedAnswer;

  QuizScreen(
      {Key? key,
      this.setSelection,
      this.index,
      this.onNext,
      this.onPrev,
      this.quiz,
      this.totalQuiz,
      this.selectedAnswer})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GlobalKey<FormBuilderState> _quizFormKey = GlobalKey<FormBuilderState>();
  List quizOptions = [];

  @override
  void initState() {
    quizOptions = widget.quiz['options'];
    print("${widget.selectedAnswer}");
    super.initState();
  }

  void cancelTripFormAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          // title: new Text('You clicked on'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
              child: Text(
            "The Trip Approval has been rejected. \nSubmit another form?",
            textAlign: TextAlign.center,
          )),
          actions: [
            Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                width: MediaQuery.of(context).size.width * 1.0,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onPrev!(0);
                        },
                        child: Text(
                          "Back to Form",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
              // alignment: Alignment.topLeft,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                widget.onPrev!(widget.index);
              }),
          // elevation: 5,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: Flexible(
                                child: Text(
                              "${widget.quiz['title']}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  ?.copyWith(color: Theme.of(context).primaryColor),
                            )),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Row(
                        children: <Widget>[
                          Container(
                            child: Flexible(
                                child: Text('Qn ${widget.index! + 1} of ${widget.totalQuiz}',
                                    style:
                                        Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold))),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Row(
                        children: <Widget>[
                          Container(
                            child: Flexible(
                                child:
                                    Text("${widget.quiz['question']}", style: Theme.of(context).textTheme.bodyText1)),
                          ),
                        ],
                      ),
                      FormBuilder(
                        key: _quizFormKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(10),
                                child: FormBuilderRadioGroup<dynamic>(
                                  activeColor: Theme.of(context).primaryColor,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    fillColor: Theme.of(context).primaryColor,
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  name: "options",
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                                  initialValue: widget.selectedAnswer == 0 ? "" : widget.selectedAnswer,
                                  onChanged: (value) {
                                    var checkValue = value?.split(" ").last;
                                    if (checkValue == "(No-move)") {
                                      cancelTripFormAlert();
                                    } else {
                                      widget.setSelection!(widget.index, value);
                                    }
                                  },
                                  options: quizOptions
                                      .map((lang) => FormBuilderFieldOption(
                                          value: "${lang['content']}  (${lang['correctAnswer']})"))
                                      .toList(growable: false),
                                )),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            )),
                            side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                          ),
                          onPressed: () {
                            if (_quizFormKey.currentState!.saveAndValidate()) {
                              widget.onNext!(widget.index! + 2);
                            }
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
