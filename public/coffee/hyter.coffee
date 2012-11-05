
class Hyter

	constructor: (words, data) ->
		sentence = new Sentence(words, data, this)
		$("#annotation-navigation").hide()
		$("#annotation-app").show()


$ ->
	$("#annotation-app").hide()
	$("#new-annotation").click(
		=>
			words = prompt("Enter sentence for annotation:", "")
			new Hyter(words, false)
	)
	$(".saved-annotation").click(
		(event) =>
			id = $(event.target).data("id")
			$.ajax "/result/" + id + ""
				success: (result) =>
					result = JSON.parse(result)
					result = JSON.parse(result[3])
					console.log result
					new Hyter(false, result)
	)
	#TODO remove this
	$(".saved-annotation").last().click()