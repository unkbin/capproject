import '../models/healing_card.dart';

const List<HealingCard> healingCardSeeds = [
  HealingCard(
    cardNumber: 1,
    id: 'energy-deficit',
    title: 'Energy Deficit',
    quote: 'Remember 1 hour of work = 3 hours of Energy burned',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/energy-deficit',
    qrValue: 'https://www.synhh.com.au/cards/energy-deficit',
  ),
  HealingCard(
    cardNumber: 2,
    id: 'ta-da-list',
    title: 'The Ta-Dah List',
    quote: 'Celebrate what you *have* done',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/ta-da-list',
    qrValue: 'https://www.synhh.com.au/cards/ta-da-list',
  ),
  HealingCard(
    cardNumber: 3,
    id: 'pattern-interrupt',
    title: 'Pattern Interrupt/Reframe',
    quote: 'Disrupt old loops',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/pattern-interrupt',
    qrValue: 'https://www.synhh.com.au/cards/pattern-interrupt',
  ),
  HealingCard(
    cardNumber: 4,
    id: 'invisible-progress',
    title: 'Invisible Progress',
    quote: 'Tiny steps lead to big progress',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/invisible-progress',
    qrValue: 'https://www.synhh.com.au/cards/invisible-progress',
  ),
  HealingCard(
    cardNumber: 18,
    id: 'plan-for-the-crash',
    title: 'Plan For The Crash',
    quote: 'Prepare before the crash.',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/plan-for-the-crash',
    qrValue: 'https://www.synhh.com.au/cards/plan-for-the-crash',
  ),
  HealingCard(
    cardNumber: 39,
    id: 'emotional-regulation',
    title: 'Emotional Regulation',
    quote: 'Feel, then reframe.',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/emotional-regulation',
    qrValue: 'https://www.synhh.com.au/cards/emotional-regulation',
  ),
  HealingCard(
    cardNumber: 44,
    id: 'self-soothing-kit',
    title: 'Self-Soothing Kit',
    quote: 'Build a kit for tough moments.',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/self-soothing-kit',
    qrValue: 'https://www.synhh.com.au/cards/self-soothing-kit',
  ),
  HealingCard(
    cardNumber: 58,
    id: 'cha-cha-cha',
    title: 'Cha-Cha-Cha',
    quote:
        "Healing isn't linear. Sometimes it's one step forward, two steps sideways.",
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/cha-cha-cha',
    qrValue: 'https://www.synhh.com.au/cards/cha-cha-cha',
  ),
  HealingCard(
    cardNumber: 61,
    id: 'this-is-grief',
    title: 'This is Grief',
    quote:
        "You didn't 'lose' your old life - you're still living. But you're allowed to grieve what's gone.",
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/this-is-grief',
    qrValue: 'https://www.synhh.com.au/cards/this-is-grief',
  ),
  HealingCard(
    cardNumber: 74,
    id: 'broken-dolly-day',
    title: 'Broken Dolly Day',
    quote: "This is it, You've hit the Crash",
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/broken-dolly-day',
    qrValue: 'https://www.synhh.com.au/cards/broken-dolly-day',
  ),
  HealingCard(
    cardNumber: 81,
    id: 'find-the-feeling-not-the-fix',
    title: 'Find The Feeling, Not The Fix',
    quote: 'What can I do right now that will make me feel better?',
    appText: '',
    webUrl: 'https://www.synhh.com.au/cards/find-the-feeling-not-the-fix',
    qrValue: 'https://www.synhh.com.au/cards/find-the-feeling-not-the-fix',
  ),
];

final Map<String, HealingCard> _seedsById = {
  for (final card in healingCardSeeds) card.id: card,
};

final Map<String, HealingCard> _seedsByQrValue = {
  for (final card in healingCardSeeds) card.qrValue: card,
};

HealingCard? findSeedById(String? id) {
  if (id == null) return null;
  return _seedsById[id.trim().toLowerCase()];
}

HealingCard? findSeedByQrValue(String? qrValue) {
  if (qrValue == null) return null;
  return _seedsByQrValue[qrValue.trim()];
}
