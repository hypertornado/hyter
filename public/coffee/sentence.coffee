
class Sentence

	words: null
	clouds: []

	constructor: (text, data, hyter) ->
		@hyter = hyter
		@last_result = []
		if text
			@words = $.trim(text).split(/[ ]+/)
		else
			@words = data.words
		$("#sentence").append(@component())
		if data
			$("span[data-name='#{data.root}']").click()
			for option in data.options
				@create_cloud(option)

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
					target.push(text) #if text.length > 0
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
		req.words = @words
		return JSON.stringify(req)

	create_cloud: (data) =>
		cloud = new Cloud(@words, data)
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

		select = $("<select>"
			style: "height: 15px; text-align: bottom;"
			change: (event) =>
				height = parseInt($(event.target).attr('value'))
				$("#bottom-empty-block").css("height", height)
				$(".tab-pane").css("height", (height - 55))
				$("#bottom-menu").css("height", height)
		)
		for i in [300, 150, 0]
			select.append(
		  	$("<option>"
		  		text: "bottom panel width: #{i} px"
		  		value: i
		  	)
			)
		$("#zoom-settings").append(select)

		$("#top-right").append(
			$("<button>"
				text: "+ New bubble"
				class: "btn btn-primary"
				id: "new-cloud"
				click: =>
					@create_cloud()
					$(window).scrollTop(200000)
			)
		)

		$("#top-right").append(
			$("<button>"
				text: "Save and reload"
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
							console.log data
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

		$("#top-right").append(
			$("<button>"
				text: "Sort"
				class: "btn btn-info"
				click: ->
					clouds = $(".cloud")
					sorted = clouds.sort(
						(a, b) ->
							return 1 unless $(a).find(".word-selected").length > 0
							return -1 unless $(b).find(".word-selected").length > 0
							if parseInt($(a).find(".word-selected").data("word-id").slice(2)) > parseInt($(b).find(".word-selected").data("word-id").slice(2))
								return 1
							else
								return -1
					)
					$("#clouds").append(sorted)
			)
		)

		return h

	word: (w) =>
		h = $("<span>"
			text: "#{w} "
		)
		return h
