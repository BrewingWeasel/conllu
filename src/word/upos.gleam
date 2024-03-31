import parse_error.{type ParseError}

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

pub fn parse(input: String) -> Result(UPOS, ParseError) {
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
    _ -> Error(parse_error.InvalidData(parse_error.UPOS))
  }
}
