import gleam/option.{type Option, None}
import word.{type Word}

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

pub fn new() -> Sentence {
  Sentence(None, None, None, None, [], [])
}
