class QuizQuestion {
  int id;
  String question;
  List<String> options;
  int answerIndex;
  int mark;

  QuizQuestion({required this.id, required this.question, required this.options, required this.answerIndex, this.mark = 10});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(id: json['id'] ?? 0, question: json['question'] ?? '', options: List<String>.from(json['options'] ?? []), answerIndex: json['answerIndex'], mark: json['mark']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'options': options, 'answerIndex': answerIndex, 'mark': mark};
  }
}
