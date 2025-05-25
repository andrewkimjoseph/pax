class FAQ {
  final String question;
  final String answer;

  const FAQ({required this.question, required this.answer});
}

class FAQs {
  static const List<FAQ> faqs = [
    FAQ(
      question: 'How many times does the platform run surveys?',
      answer:
          'Once every day, for three days each week. So, a total of 3 surveys a week.',
    ),
    FAQ(
      question: 'What time of the day is the survey made available?',
      answer: 'From 9 WAT / 11 EAT',
    ),
    FAQ(
      question: 'On which days are surveys available?',
      answer: 'Wednesday, Thursday, and Friday',
    ),
    FAQ(
      question: 'How many questions are there for a single survey?',
      answer: '5 - 10 questions that require little to no typing input.',
    ),
    FAQ(
      question:
          'I have been missing out on survey booking, what could be wrong?',
      answer:
          'Survey booking is on a first come, first served basis. Because of the high volumes, once a survey is listed, people rush and thus, the booking closes faster. You just need to be quick enough.',
    ),
    FAQ(
      question: 'What happens when I book a slot in a survey?',
      answer:
          'Survey booking is on a first come, first served basis. Because of the high volumes, once a survey is listed, people rush and thus, the booking closes faster. You just need to be quick enough.',
    ),
    FAQ(
      question: 'How much money can I make from answering surveys per month?',
      answer:
          'If you book and complete all possible surveys in a month, you could make up to 0.12 cUSD, which is enough for airtime.',
    ),
  ];
}
