import 'package:pax/models/faq.dart';

class FAQs {
  static const List<FAQ> faqs = [
    FAQ(
      question: "How many times does the platform run micro tasks?",
      answer:
          "Once 1️⃣ every week. So, a total of 4 tasks a month. However, this is dependent on the availability of researchers.",
    ),
    FAQ(
      question: "What time of the day is the micro task made available?",
      answer: "8:00 AM UTC / 9:00 AM WAT / 10:00 AM CAT / 11:00 AM EAT 📅",
    ),
    FAQ(
      question: "On which day is the micro task available?",
      answer: "Tuesday - Tuesday is PaxDay 🥳",
    ),
    FAQ(
      question: "What does GoodDollar Face Verification Required mean?",
      answer:
          "This means that you need to verify your face before you can complete registration and do micro tasks. We are using the GoodDollar Identity mechanism to avoid fraud and ensure that only real people are completing the tasks, not just bots or random Ethereum addresses.",
    ),
    FAQ(
      question:
          "Whenever I receive a notification of a new micro task and check the app, I find no task available. What could be wrong?",
      answer:
          "Tasks are available on a first come, first served basis. Because of the high volumes, once a task is listed, people rush and thus, the task closes faster. You just need to be quick enough.",
    ),
    FAQ(
      question: "How do I convert my G\$ tokens to cUSD from within Minipay",
      answer:
          "https://thecanvassing.medium.com/guide-swapping-g-for-cusd-in-minipay-step-by-step-video-walkthrough-c1514151c2ba",
    ),
    FAQ(
      question: "What type of micro tasks are available?",
      answer:
          "At the moment, we have only one type of micro tasks: surveys. We will be adding more types of micro tasks in the future.",
    ),
    FAQ(
      question: "How many questions are there for a task?",
      answer:
          "Between 10 and 15 questions that require varied levels of opinion and knowledge.",
    ),
    FAQ(
      question: "What happens when I book a slot in a task?",
      answer: "You will be let in, and you will be able to complete the task.",
    ),
    FAQ(
      question:
          "I keep getting a message that I have been banned from the platform. What does this mean?",
      answer:
          "This means that your account has been disabled. You will not be able to complete any tasks and you will not be able to withdraw your funds. Contact support if you think this is a mistake.",
    ),
    FAQ(
      question:
          "When I try to claim achievements, I get an error: 'Exception: B: Claiming is not possible at this time'. What does this mean?",
      answer:
          "This means that the faucet has not been refilled yet. You need to wait for the faucet to be refilled before you can claim an achievement, and this happens daily between 8AM UTC / 9AM WAT / 10AM CAT / 11AM EAT and 3PM UTC / 4PM WAT / 5PM CAT / 6PM EAT.",
    ),
  ];
}
