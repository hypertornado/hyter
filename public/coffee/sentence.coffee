
class Sentence

	words: null
	clouds: []

	constructor: (text, hyter) ->
		@hyter = hyter
		@words = text.split(" ")
		@last_result = []
		$("#sentence").append(@component())

	create_request: =>
		w = []
		w.push("w_#{i}") for i in [0..(@words.length - 1)]
		root = $(".head-word-selected")
		if root.length > 0
			root_name = root.data("name")
		else
			alert "No root word selected."
			return false
		req = (
			source: w
			root: root_name
		)
		options = []
		for cloud in $("#clouds").children()
			option = {}
			cloud = $(cloud)
			covered = []
			i = 0
			for word in cloud.children().filter(".word")
				if $(word).hasClass("word-selected")
					covered.push("w_#{i}")
				i += 1
			option['covered'] = covered
			option['up_rules'] = cloud.children().filter(".constraints").val().split("\n")
			target = []
			for el in cloud.children().filter(".target").children().filter(".slot, .atom")
				el = $(el)
				text = $(el).val()
				if $(el).hasClass("atom")
					target.push(text) if text.length > 0
				else
					if text.length > 0
						target.push(text.split("\n"))
					else
						target.push([])
			option['target'] = target
			if option['target'].length > 0 and option['covered'].length > 0
				options.push(option)
		req['options'] = options
		req['last_result'] = @last_result
		if options.length == 0
			alert "No bubble is defined correctly."
			return false
		return JSON.stringify(req)

	create_request_old: =>
		req = '
{
		"source": ["hello", "world"],
		"root": "hello",
		"options":
			[
				{
					"covered": ["hello"],
					"up_rules": ["pl"],
					"target": ["ahoj", []]
				},
				{
					"covered": ["world"],
					"up_rules": ["pl"],
					"target": ["svete"]
				},
				{
					"covered": ["world"],
					"up_rules": ["pl"],
					"target": ["sveticku"]
				}
			]
	}
			'
		return req

	create_cloud: =>
		cloud = new Cloud(@words)
		$("#clouds").append(cloud.html)

	component: =>
		h = $("<h1>")
		i = 0
		for word in @words
			w = $("<span>"
				text: "#{word} "
				class: "head-word"
				"data-name": "w_#{i}"
				click: (e) =>
					$(".head-word-selected").removeClass("head-word-selected")
					$(e.target).addClass("head-word-selected")
			)
			h.append(w)
			i += 1
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
					query = @create_request()
					return if query == false
					$("#results").html("loading...")
					$("#diff").html("loading...")
					$.ajax "/results"
						data:
							q: query
						success: (data) =>
							$("#results").html("")
							$("#diff").html("")
							result = JSON.parse(data)
							@last_result = result.words
							for d in result.words
								sen = $("<div>"
										text: d.join(" ")
									)
								$("#results").append(sen)
							for d in result.added
								sen = $("<div>"
										style: "color: #5BB75B;"
										text: "+ " + d.join(" ")
									)
								$("#diff").append(sen)
							for d in result.removed
								sen = $("<div>"
										style: "color: #DA4F49;"
										text: "- " + d.join(" ")
									)
								$("#diff").append(sen)
							$("#results-name").text("Results ( #{result.words.length} )")
							$("#diff-name").text("Diff ( +#{result.added.length}, -#{result.removed.length} )")
			)
		)
		return h

	word: (w) =>
		h = $("<span>"
			text: "#{w} "
		)
		return h
