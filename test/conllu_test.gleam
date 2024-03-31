import gleeunit
import gleeunit/should
import conllu
import gleam/list

pub fn main() {
  gleeunit.main()
}

const basic_sentence = "# sent_id = gro-019-doc1-s4
# text = Man vienam.
1	Man	aš	PRON	įv.vns.N.	Case=Dat|Definite=Ind|Number=Sing	_	_	_	Multext=Pg-sdn
2	vienam	vienas	ADJ	bdv.vyr.vns.N.nelygin.	Case=Dat|Degree=Pos|Gender=Masc|Number=Sing	_	_	_	SpaceAfter=No|Multext=Agpmsd-
3	.	.	PUNCT	skyr.	_	_	_	_	Multext=Tp"

pub fn parse_correct_sentence_test() {
  conllu.parse(basic_sentence)
  |> should.be_ok()
}

pub fn get_first_sentence_test() {
  conllu.parse(basic_sentence)
  |> should.be_ok()
  |> list.at(0)
  |> should.be_ok()
}

pub fn get_first_word_test() {
  let sentence =
    conllu.parse(basic_sentence)
    |> should.be_ok()
    |> list.at(0)
    |> should.be_ok()

  let first_word =
    sentence.words
    |> list.at(0)
    |> should.be_ok()

  first_word.form
  |> should.equal("Man")

  first_word.lemma
  |> should.equal("aš")

  first_word.upos
  |> should.equal(conllu.PRON)
}
