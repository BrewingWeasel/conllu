import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/bool
import gleam/list
import gleam/result
import parse_error.{type ParseError}

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

pub fn parse_feats(input: String) -> Result(Option(List(Feature)), ParseError) {
  use <- bool.guard(when: input == "_", return: Ok(None))
  input
  |> string.split("|")
  |> list.map(parse_feat)
  |> result.all()
  |> result.map(Some)
}

pub fn parse_feat(input: String) -> Result(Feature, ParseError) {
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
        Error(Nil) -> Error(parse_error.InvalidData(parse_error.Feats))
      }
  }
}
