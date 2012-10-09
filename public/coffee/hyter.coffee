
class Hyter

	constructor: (words) ->
		sentence = new Sentence(words, this)
		console.log sentence.words


$ ->
	words = "hello world"
	new Hyter(words)
	$("#new-cloud").click()