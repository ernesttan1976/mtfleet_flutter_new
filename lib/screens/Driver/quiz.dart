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

  const QuizScreen(
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
  State<QuizScreen> createState() => _QuizScreenState();
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
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Text(
            "The Trip Approval has been rejected. \nSubmit another form?",
            textAlign: TextAlign.center,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onPrev!(0);
                      },
                      child: const Text(
                        "Back to Form",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        side: WidgetStateProperty.all(
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onPrev!(widget.index);
          },
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          "${widget.quiz['title']}",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          'Qn ${widget.index! + 1} of ${widget.totalQuiz}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          "${widget.quiz['question']}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  FormBuilder(
                    key: _quizFormKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: FormBuilderRadioGroup<dynamic>(
                            activeColor: Theme.of(context).primaryColor,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              fillColor: Colors.transparent,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            name: "options",
                            validator: FormBuilderValidators.compose(
                              [
                                FormBuilderValidators.required(),
                              ],
                            ),
                            initialValue:
                                widget.selectedAnswer == 0 ? "" : widget.selectedAnswer,
                            onChanged: (value) {
                              var checkValue = value?.split(" ").last;
                              if (checkValue == "(No-move)") {
                                cancelTripFormAlert();
                              } else {
                                widget.setSelection!(widget.index, value);
                              }
                            },
                            options: quizOptions
                                .map(
                                  (lang) => FormBuilderFieldOption(
                                    value:
                                        "${lang['content']}  (${lang['correctAnswer']})",
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        side: WidgetStateProperty.all(
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      onPressed: () {
                        if (_quizFormKey.currentState!.saveAndValidate()) {
                          widget.onNext!(widget.index! + 2);
                        }
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
