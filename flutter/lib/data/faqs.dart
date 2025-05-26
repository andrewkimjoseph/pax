import 'package:pax/models/faq.dart';

class FAQs {
  static const List<FAQ> faqs = [
    FAQ(
      question: 'How many times does the platform run micro tasks?',
      answer: 'Once every week. So, a total of 4 surveys a month.',
    ),
    FAQ(
      question: 'What time of the day is the micro task made available?',
      answer: '9:00 AM WAT / 11:00 AM EAT',
    ),
    FAQ(
      question: 'On which day is the micro task available?',
      answer: 'Wednesday',
    ),
    FAQ(
      question: 'What type of micro tasks are available?',
      answer:
          'At the moment, we have only one type of micro task: form filling.',
    ),
    FAQ(
      question: 'How many questions are there for a task?',
      answer: '5 - 10 questions that require little to no typing input.',
    ),
    FAQ(
      question:
          'I have been missing out on task screening, what could be wrong?',
      answer:
          'Survey screening is on a first come, first served basis. Because of the high volumes, once a survey is listed, people rush and thus, the screening closes faster. You just need to be quick enough.',
    ),
    FAQ(
      question: 'What happens when I book a slot in a task?',
      answer: 'You will be let in, and you will be able to complete the task.',
    ),
  ];
}
