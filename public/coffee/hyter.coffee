
class Hyter

	constructor: (words) ->
		sentence = new Sentence(words, this)
		console.log sentence.words


$ ->
	words = "hello world"
	words = prompt("Enter sentence for annotation:", "Hello world")
	new Hyter(words)
	$("#new-cloud").click()