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
