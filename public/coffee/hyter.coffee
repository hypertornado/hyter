

class Sentence

	words: null

	constructor: (text) ->
		@words = text.split(" ")
		console.log @component()
		$("#content").append(@component())

	component: =>
		h = $("<h3>")
		for word in @words
			h.append(@word(word))
		return h

	word: (w) =>
		h = $("<span>"
			text: "#{w} "
		)
		return h

class Hyter

	constructor: ->
		sentence = new Sentence("hello world")
		console.log sentence.words


$ ->
	new Hyter()