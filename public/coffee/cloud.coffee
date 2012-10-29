

class Cloud

	constructor: (words, option) ->
		@option = option
		@words = words
		@html = @component()


	component: =>
		h = $("<div>"
			class: "cloud"
			html: ""
		)
		h.append($("<span>"
			style: "float: right;"
			html: $("<button>"
				text: "x"
				class: "btn btn-danger"
				click: =>
					if confirm("Delete this bubble?")
						@html.remove()
			)
		))
		i = 0
		for word in @words
			w = $("<span>"
					class: "word"
					text: "#{word}"
					"data-word-id": "w_#{i}"
					click: (event) =>
						$(event.target).toggleClass("word-selected")
				)
			h.append(w)
			i += 1
		if @option
			for covered in @option.covered
				h.children().filter("[data-word-id='#{covered}']").click()
		h.append("<br>")
		constraints = $("<textarea>"
			class: "constraints"
			placeholder: "Constraints we satisfy"
			spellcheck: "false"
		)
		if @option
			constraints.val(@option.up_rules.join("\n"))
		target = $("<div>"
			class: "target"
			html: @slot()
		)
		h.append($("<div>"
			style: "clear: both;"
		))
		h.append(target)
		h.append(constraints)
		h.append($("<div>"
			style: "clear: both;"
		))
		if @option
			console.log "X: #{@option.target.length}"
			i = 0
			while i < (@option.target.length - 1) / 2
				target.children().filter(".btn").first().click()
				i += 1

			i = 0
			for tar in @option.target
				if $.isArray(tar)
					value = tar.join("\n")
				else
					value = tar
				$(target.children().filter("textarea")[i]).val(value)
				i += 1

		return h

	slot: (dir = false) =>
		h = $("<span>"
			html:
				$("<textarea>"
					class: "atom"
					placeholder: "Output forms (atoms)"
					spellcheck: "false"
				)
		)
		left = $("<a>"
			html: "+"
			class: "btn btn-mini btn-info tiny-button"
			click: (event) =>
				slot = @slot("left")
				slot.hide()
				$(event.target).before(slot)
				slot.show("fast")
		)
		right = $("<a>"
			html: "+"
			class: "btn btn-mini btn-info tiny-button"
			click: (event) =>
				slot = @slot("right")
				slot.hide()
				$(event.target).after(slot)
				slot.show("fast")
		)
		h.prepend(left)
		h.append(right)

		if dir
			slot_constraints = $("<textarea>"
				class: "slot"
				placeholder: "Slots (lists of constraints)"
				spellcheck: "false"
			)
			if dir == "left"
				h.append(slot_constraints)
			else
				h.prepend(slot_constraints)

		return h.children()
