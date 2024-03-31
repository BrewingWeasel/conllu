import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/int
import gleam/bool

pub type Sentence {
  // TODO: add working support for text_lang
  Sentence(
    sent_id: Option(String),
    text: Option(String),
    /// ex: text_en = ""
    text_lang: Option(#(String, String)),
    translit: Option(String),
    comments: List(String),
    words: List(Word),
  )
}

/// A single word with grammatical information
pub type Word {
  Word(
    index: Int,
    form: String,
    lemma: String,
    upos: UPOS,
    xpos: Option(String),
    feats: Option(List(Feature)),
    head: Option(Int),
    deprel: Option(String),
    deps: Option(String),
    misc: Option(String),
  )
}

/// Universal POS tag
/// based on https://universaldependencies.org/u/pos/index.html
pub type UPOS {
  /// adjective
  ADJ
  /// adposition
  ADP
  /// adverb
  ADV
  /// auxiliary
  AUX
  /// coordinating conjunction
  CCONJ
  /// determiner
  DET
  /// interjection
  INTJ
  /// noun
  NOUN
  /// numeral
  NUM
  /// particle
  PART
  /// pronoun
  PRON
  /// proper noun
  PROPN
  /// punctuation
  PUNCT
  /// subordinating conjunction
  SCONJ
  /// symbol
  SYM
  /// verb
  VERB
  ///other
  X
}

// TODO: enums for every feature
pub type Feature {
  PronType(String)
  Gender(String)
  VerbForm(String)
  NumType(String)
  Animacy(String)
  Mood(String)
  Poss(String)
  NounClass(String)
  Tense(String)
  Reflex(String)
  Number(String)
  Aspect(String)
  Foreign(String)
  Case(String)
  Voice(String)
  Abbr(String)
  Definite(String)
  Evident(String)
  Typo(String)
  Deixis(String)
  Polarity(String)
  DeixisRef(String)
  Person(String)
  Degree(String)
  Polite(String)
  Clusivity(String)
  Custom(String, String)
}

pub type ParseError {
  InvalidData(WordParts)
  MissingWordInformation(WordParts)
}

pub type WordParts {
  Index
  Form
  Lemma
  UPOS
  XPOS
  Feats
  Head
  Deprel
  Deps
  Misc
}

fn new_sentence() -> Sentence {
  Sentence(None, None, None, None, [], [])
}

pub fn parse(input: String) -> Result(List(Sentence), ParseError) {
  input
  |> string.split("\n")
  |> do_parse([], new_sentence())
}

fn do_parse(
  input: List(String),
  current_sentences: List(Sentence),
  current_sentence: Sentence,
) -> Result(List(Sentence), ParseError) {
  case input {
    ["#" <> comment, ..rest] ->
      do_parse(
        rest,
        current_sentences,
        update_sentence_with_comment(current_sentence, comment),
      )
    ["", ..rest] ->
      do_parse(rest, [current_sentence, ..current_sentences], new_sentence())
    [word, ..rest] -> {
      use new_word <- result.try(parse_word(word))
      do_parse(
        rest,
        current_sentences,
        Sentence(
          ..current_sentence,
          words: [new_word, ..current_sentence.words],
        ),
      )
    }
    [] ->
      case list.is_empty(current_sentence.words) {
        True -> Ok(current_sentences)
        False -> Ok([current_sentence, ..current_sentences])
      }
      |> result.map(list.reverse)
  }
}

fn update_sentence_with_comment(sentence: Sentence, comment: String) {
  let total_comments = [comment, ..sentence.comments]
  case comment {
    "sent_id = " <> sent_id ->
      Sentence(..sentence, sent_id: Some(sent_id), comments: total_comments)
    "text = " <> text ->
      Sentence(..sentence, text: Some(text), comments: total_comments)
    "translit = " <> translit ->
      Sentence(..sentence, translit: Some(translit), comments: total_comments)
    _ -> Sentence(..sentence, comments: total_comments)
  }
}

fn parse_word(word: String) -> Result(Word, ParseError) {
  let word_parts = string.split(word, "\t")

  use index <- result.try(
    word_parts
    |> list.at(0)
    |> result.replace_error(MissingWordInformation(Index))
    |> result.try(fn(x) {
      result.replace_error(int.parse(x), InvalidData(Index))
    }),
  )

  use form <- result.try(
    word_parts
    |> list.at(1)
    |> result.replace_error(MissingWordInformation(Form)),
  )

  use lemma <- result.try(
    word_parts
    |> list.at(2)
    |> result.replace_error(MissingWordInformation(Lemma)),
  )

  use upos <- result.try(
    word_parts
    |> list.at(3)
    |> result.replace_error(MissingWordInformation(UPOS))
    |> result.try(parse_upos),
  )

  use xpos <- result.try(
    word_parts
    |> list.at(4)
    |> result.replace_error(MissingWordInformation(XPOS)),
  )

  use feats <- result.try(
    word_parts
    |> list.at(5)
    |> result.replace_error(MissingWordInformation(Feats))
    |> result.try(parse_feats),
  )

  use head <- result.try(
    word_parts
    |> list.at(6)
    |> result.replace_error(MissingWordInformation(Head))
    |> result.try(fn(x) {
      case x == "_" {
        True -> Ok(None)
        False ->
          result.replace_error(int.parse(x), InvalidData(Head))
          |> result.map(Some)
      }
    }),
  )

  use deprel <- result.try(
    word_parts
    |> list.at(7)
    |> result.replace_error(MissingWordInformation(Deprel)),
  )

  use deps <- result.try(
    word_parts
    |> list.at(8)
    |> result.replace_error(MissingWordInformation(Deps)),
  )

  use misc <- result.try(
    word_parts
    |> list.at(9)
    |> result.replace_error(MissingWordInformation(Misc)),
  )

  Ok(
    Word(
      index,
      form,
      lemma,
      upos,
      case xpos == "_" {
        True -> None
        False -> Some(xpos)
      },
      feats,
      head,
      case deprel == "_" {
        True -> None
        False -> Some(deprel)
      },
      case deps == "_" {
        True -> None
        False -> Some(deps)
      },
      case misc == "_" {
        True -> None
        False -> Some(misc)
      },
    ),
  )
}

fn parse_upos(input: String) -> Result(UPOS, ParseError) {
  case input {
    "ADJ" -> Ok(ADJ)
    "ADP" -> Ok(ADP)
    "ADV" -> Ok(ADV)
    "AUX" -> Ok(AUX)
    "CCONJ" -> Ok(CCONJ)
    "DET" -> Ok(DET)
    "INTJ" -> Ok(INTJ)
    "NOUN" -> Ok(NOUN)
    "NUM" -> Ok(NUM)
    "PART" -> Ok(PART)
    "PRON" -> Ok(PRON)
    "PROPN" -> Ok(PROPN)
    "PUNCT" -> Ok(PUNCT)
    "SCONJ" -> Ok(SCONJ)
    "SYM" -> Ok(SYM)
    "VERB" -> Ok(VERB)
    "X" -> Ok(X)
    _ -> Error(InvalidData(UPOS))
  }
}

fn parse_feats(input: String) -> Result(Option(List(Feature)), ParseError) {
  use <- bool.guard(when: input == "_", return: Ok(None))
  input
  |> string.split("|")
  |> list.map(parse_feat)
  |> result.all()
  |> result.map(Some)
}

fn parse_feat(input: String) -> Result(Feature, ParseError) {
  case input {
    "PronType=" <> val -> Ok(PronType(val))
    "Gender=" <> val -> Ok(Gender(val))
    "VerbForm=" <> val -> Ok(VerbForm(val))
    "NumType=" <> val -> Ok(NumType(val))
    "Animacy=" <> val -> Ok(Animacy(val))
    "Mood=" <> val -> Ok(Mood(val))
    "Poss=" <> val -> Ok(Poss(val))
    "NounClass=" <> val -> Ok(NounClass(val))
    "Tense=" <> val -> Ok(Tense(val))
    "Reflex=" <> val -> Ok(Reflex(val))
    "Number=" <> val -> Ok(Number(val))
    "Aspect=" <> val -> Ok(Aspect(val))
    "Foreign=" <> val -> Ok(Foreign(val))
    "Case=" <> val -> Ok(Case(val))
    "Voice=" <> val -> Ok(Voice(val))
    "Abbr=" <> val -> Ok(Abbr(val))
    "Definite=" <> val -> Ok(Definite(val))
    "Evident=" <> val -> Ok(Evident(val))
    "Typo=" <> val -> Ok(Typo(val))
    "Deixis=" <> val -> Ok(Deixis(val))
    "Polarity=" <> val -> Ok(Polarity(val))
    "DeixisRef=" <> val -> Ok(DeixisRef(val))
    "Person=" <> val -> Ok(Person(val))
    "Degree=" <> val -> Ok(Degree(val))
    "Polite=" <> val -> Ok(Polite(val))
    "Clusivity=" <> val -> Ok(Clusivity(val))
    other ->
      case string.split_once(other, "=") {
        Ok(#(first, second)) -> Ok(Custom(first, second))
        Error(Nil) -> Error(InvalidData(Feats))
      }
  }
}
