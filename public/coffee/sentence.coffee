
class Sentence

	words: null
	clouds: []

	constructor: (text) ->
		@words = text.split(" ")
		$("#sentence").append(@component())

	create_cloud: =>
		cloud = new Cloud(@words)
		$("#clouds").append(cloud.html)

	component: =>
		h = $("<h1>")
		for word in @words
			h.append(@word(word))
		$("#top-right").append(
			$("<button>"
				text: "+ New bubble"
				class: "btn btn-primary"
				id: "new-cloud"
				click: =>
					@create_cloud()
			)
		)

		$("#top-right").append(
			$("<button>"
				text: "Reload sentences"
				class: "btn btn-success"
				id: "new-cloud"
				click: =>
					alert "not implemented yet"
			)
		)
		return h

	word: (w) =>
		h = $("<span>"
			text: "#{w} "
		)
		return h
