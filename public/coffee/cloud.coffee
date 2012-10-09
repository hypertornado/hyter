

class Cloud

	constructor: (words) ->
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
					click: (event) =>
						$(event.target).toggleClass("word-selected")
				)
			h.append(w)
			i += 1
		h.append("<br>")
		constraints = $("<textarea>"
			class: "constraints"
			placeholder: "Constraints we satisfy"
			spellcheck: "false"
		)
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
		#h.children().filter("input[type=checkbox]").tooltip()
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
