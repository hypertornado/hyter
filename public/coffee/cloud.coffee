

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

		button_panel = $("<div>"
			class: "button-panel"
			style: "float: right; visibility: hidden;"
		)

		del_button = $("<button>"
				text: "x"
				class: "btn btn-danger btn-mini"
				click: =>
					if confirm("Delete this bubble?")
						@html.remove()
			)

		clone_button = $("<button>"
				text: "clone"
				class: "btn btn-info btn-mini"
				click: (event) =>
					new_el =  $(event.target).parent().parent().clone(true)
					new_el_textareas = new_el.find("textarea")
					i = 0
					for t in $(event.target).parent().parent().find("textarea")
						$(new_el_textareas[i]).val($(t).val())
						i += 1
					$(event.target).parent().parent().after(new_el)
			)

		button_panel.append(clone_button)
		button_panel.append(del_button)

		h.append(button_panel)
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
		target = @create_target()
		h.append($("<div>"
			style: "clear: both;"
		))
		h.append(target)
		h.append(constraints)
		h.append($("<div>"
			style: "clear: both;"
		))
		if @option
			i = 0
			while i < (@option.target.length - 1) / 2
				target.children().filter(".plus-button").first().click()
				i += 1

			i = 0
			for tar in @option.target
				if $.isArray(tar)
					value = tar.join("\n")
				else
					value = tar
				$(target.children().filter("textarea")[i]).val(value)
				i += 1

		h.hover(
				(event) ->
					$(event.delegateTarget).find(".button-panel, .btn").css("visibility", "visible")
			,
				(event) =>
					$(event.delegateTarget).find(".button-panel, .btn").css("visibility", "hidden")
		)

		return h


	create_target: =>
    ret = $("<div>"
      class: "target"
    )
    ret.append(
      $("<span>"
        text: "x"
        class: "btn btn-danger btn-mini first-remover btn-not-visible"
        click: @click_on_delete_slot
      )
    )
    ret.append(@slot())
    ret.append(
      $("<span>"
        text: "x"
        class: "btn btn-danger btn-mini last-remover btn-not-visible"
        click: @click_on_delete_slot
      )
    )
    return ret

  click_on_delete_slot: (event) ->
    if $(event.target).hasClass("first-remover")
      name = "first"
    else
      name = "last"
    textareas = $(event.target).parent().children().filter("textarea")
    if textareas.length == 1
      alert("Can't delete single slot.")
      return
    return unless confirm("Really delete #{name} slot and atom?")
    if textareas.length > 1
      $(event.target).parent().children().filter("textarea")[name]().remove()
      $(event.target).parent().children().filter("textarea")[name]().remove()
      $(event.target).parent().children().filter(".plus-button")[name]().remove()
      $(event.target).parent().children().filter(".plus-button")[name]().remove()


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
			class: "btn btn-mini btn-info plus-button btn-not-visible"
			click: (event) =>
				slot = @slot("left")
				slot.hide()
				$(event.target).before(slot)
				slot.show("fast")
		)
		right = $("<a>"
			html: "+"
			class: "btn btn-mini btn-info plus-button btn-not-visible"
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
				placeholder: "Slots (constraints)"
				spellcheck: "false"
			)
			if dir == "left"
				h.append(slot_constraints)
			else
				h.prepend(slot_constraints)

		return h.children()
