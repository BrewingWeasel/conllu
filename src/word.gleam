import word/upos.{type UPOS}
import word/feat.{type Feature}
import gleam/option.{type Option}

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
