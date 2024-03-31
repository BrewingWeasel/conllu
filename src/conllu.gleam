import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/int
import sentence.{type Sentence, Sentence}
import parse_error.{type ParseError, InvalidData, MissingWordInformation}
import word.{type Word, Word}
import word/upos
import word/feat

pub fn parse(input: String) -> Result(List(Sentence), ParseError) {
  input
  |> string.split("\n")
  |> do_parse([], sentence.new())
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
      do_parse(
        rest,
        [
          Sentence(
            ..current_sentence,
            words: list.reverse(current_sentence.words),
          ),
          ..current_sentences
        ],
        sentence.new(),
      )
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
        False ->
          Ok([
            Sentence(
              ..current_sentence,
              words: list.reverse(current_sentence.words),
            ),
            ..current_sentences
          ])
      }
      |> result.map(list.reverse)
  }
}

fn update_sentence_with_comment(sentence: Sentence, comment: String) {
  let comment = string.trim_left(comment)
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
    |> result.replace_error(MissingWordInformation(parse_error.Index))
    |> result.try(fn(x) {
      result.replace_error(int.parse(x), InvalidData(parse_error.Index))
    }),
  )

  use form <- result.try(
    word_parts
    |> list.at(1)
    |> result.replace_error(MissingWordInformation(parse_error.Form)),
  )

  use lemma <- result.try(
    word_parts
    |> list.at(2)
    |> result.replace_error(MissingWordInformation(parse_error.Lemma)),
  )

  use upos <- result.try(
    word_parts
    |> list.at(3)
    |> result.replace_error(MissingWordInformation(parse_error.UPOS))
    |> result.try(upos.parse),
  )

  use xpos <- result.try(
    word_parts
    |> list.at(4)
    |> result.replace_error(MissingWordInformation(parse_error.XPOS)),
  )

  use feats <- result.try(
    word_parts
    |> list.at(5)
    |> result.replace_error(MissingWordInformation(parse_error.Feats))
    |> result.try(feat.parse_feats),
  )

  use head <- result.try(
    word_parts
    |> list.at(6)
    |> result.replace_error(MissingWordInformation(parse_error.Head))
    |> result.try(fn(x) {
      case x == "_" {
        True -> Ok(None)
        False ->
          result.replace_error(int.parse(x), InvalidData(parse_error.Head))
          |> result.map(Some)
      }
    }),
  )

  use deprel <- result.try(
    word_parts
    |> list.at(7)
    |> result.replace_error(MissingWordInformation(parse_error.Deprel)),
  )

  use deps <- result.try(
    word_parts
    |> list.at(8)
    |> result.replace_error(MissingWordInformation(parse_error.Deps)),
  )

  use misc <- result.try(
    word_parts
    |> list.at(9)
    |> result.replace_error(MissingWordInformation(parse_error.Misc)),
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
