var Cloud, Hyter, Sentence,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Cloud = (function() {

  function Cloud(words) {
    this.slot = __bind(this.slot, this);
    this.component = __bind(this.component, this);    this.words = words;
    this.html = this.component();
  }

  Cloud.prototype.component = function() {
    var constraints, h, i, target, w, word, _i, _len, _ref,
      _this = this;
    h = $("<div>", {
      "class": "cloud",
      html: ""
    });
    h.append($("<span>", {
      style: "float: right;",
      html: $("<button>", {
        text: "x",
        "class": "btn btn-danger",
        click: function() {
          if (confirm("Delete this bubble?")) return _this.html.remove();
        }
      })
    }));
    i = 0;
    _ref = this.words;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      word = _ref[_i];
      w = $("<span>", {
        "class": "word",
        text: "" + word,
        click: function(event) {
          return $(event.target).toggleClass("word-selected");
        }
      });
      h.append(w);
      i += 1;
    }
    h.append("<br>");
    constraints = $("<textarea>", {
      "class": "constraints",
      placeholder: "Constraints we satisfy",
      spellcheck: "false"
    });
    target = $("<div>", {
      "class": "target",
      html: this.slot()
    });
    h.append($("<div>", {
      style: "clear: both;"
    }));
    h.append(target);
    h.append(constraints);
    h.append($("<div>", {
      style: "clear: both;"
    }));
    return h;
  };

  Cloud.prototype.slot = function(dir) {
    var h, left, right, slot_constraints,
      _this = this;
    if (dir == null) dir = false;
    h = $("<span>", {
      html: $("<textarea>", {
        "class": "atom",
        placeholder: "Output forms (atoms)",
        spellcheck: "false"
      })
    });
    left = $("<a>", {
      html: "+",
      "class": "btn btn-mini btn-info tiny-button",
      click: function(event) {
        var slot;
        slot = _this.slot("left");
        slot.hide();
        $(event.target).before(slot);
        return slot.show("fast");
      }
    });
    right = $("<a>", {
      html: "+",
      "class": "btn btn-mini btn-info tiny-button",
      click: function(event) {
        var slot;
        slot = _this.slot("right");
        slot.hide();
        $(event.target).after(slot);
        return slot.show("fast");
      }
    });
    h.prepend(left);
    h.append(right);
    if (dir) {
      slot_constraints = $("<textarea>", {
        "class": "slot",
        placeholder: "Slots (lists of constraints)",
        spellcheck: "false"
      });
      if (dir === "left") {
        h.append(slot_constraints);
      } else {
        h.prepend(slot_constraints);
      }
    }
    return h.children();
  };

  return Cloud;

})();

Hyter = (function() {

  function Hyter(words) {
    var sentence;
    sentence = new Sentence(words, this);
    console.log(sentence.words);
  }

  return Hyter;

})();

$(function() {
  var words;
  words = "hello world";
  words = prompt("Enter sentence for annotation:", "Hello world");
  new Hyter(words);
  return $("#new-cloud").click();
});

Sentence = (function() {

  Sentence.prototype.words = null;

  Sentence.prototype.clouds = [];

  function Sentence(text, hyter) {
    this.word = __bind(this.word, this);
    this.component = __bind(this.component, this);
    this.create_cloud = __bind(this.create_cloud, this);
    this.create_request_old = __bind(this.create_request_old, this);
    this.create_request = __bind(this.create_request, this);    this.hyter = hyter;
    this.words = text.split(" ");
    this.last_result = [];
    $("#sentence").append(this.component());
  }

  Sentence.prototype.create_request = function() {
    var cloud, covered, el, i, option, options, req, root, root_name, target, text, w, word, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _ref4;
    w = [];
    for (i = 0, _ref = this.words.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      w.push("w_" + i);
    }
    root = $(".head-word-selected");
    if (root.length > 0) {
      root_name = root.data("name");
    } else {
      alert("No root word selected.");
      return false;
    }
    req = {
      source: w,
      root: root_name
    };
    options = [];
    _ref2 = $("#clouds").children();
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      cloud = _ref2[_i];
      option = {};
      cloud = $(cloud);
      covered = [];
      i = 0;
      _ref3 = cloud.children().filter(".word");
      for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
        word = _ref3[_j];
        if ($(word).hasClass("word-selected")) covered.push("w_" + i);
        i += 1;
      }
      option['covered'] = covered;
      option['up_rules'] = cloud.children().filter(".constraints").val().split("\n");
      target = [];
      _ref4 = cloud.children().filter(".target").children().filter(".slot, .atom");
      for (_k = 0, _len3 = _ref4.length; _k < _len3; _k++) {
        el = _ref4[_k];
        el = $(el);
        text = $(el).val();
        if ($(el).hasClass("atom")) {
          if (text.length > 0) target.push(text);
        } else {
          if (text.length > 0) {
            target.push(text.split("\n"));
          } else {
            target.push([]);
          }
        }
      }
      option['target'] = target;
      if (option['target'].length > 0 && option['covered'].length > 0) {
        options.push(option);
      }
    }
    req['options'] = options;
    req['last_result'] = this.last_result;
    if (options.length === 0) {
      alert("No bubble is defined correctly.");
      return false;
    }
    return JSON.stringify(req);
  };

  Sentence.prototype.create_request_old = function() {
    var req;
    req = '\
{\
		"source": ["hello", "world"],\
		"root": "hello",\
		"options":\
			[\
				{\
					"covered": ["hello"],\
					"up_rules": ["pl"],\
					"target": ["ahoj", []]\
				},\
				{\
					"covered": ["world"],\
					"up_rules": ["pl"],\
					"target": ["svete"]\
				},\
				{\
					"covered": ["world"],\
					"up_rules": ["pl"],\
					"target": ["sveticku"]\
				}\
			]\
	}\
			';
    return req;
  };

  Sentence.prototype.create_cloud = function() {
    var cloud;
    cloud = new Cloud(this.words);
    return $("#clouds").append(cloud.html);
  };

  Sentence.prototype.component = function() {
    var h, i, w, word, _i, _len, _ref,
      _this = this;
    h = $("<h1>");
    i = 0;
    _ref = this.words;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      word = _ref[_i];
      w = $("<span>", {
        text: "" + word + " ",
        "class": "head-word",
        "data-name": "w_" + i,
        click: function(e) {
          $(".head-word-selected").removeClass("head-word-selected");
          return $(e.target).addClass("head-word-selected");
        }
      });
      h.append(w);
      i += 1;
    }
    $("#top-right").append($("<button>", {
      text: "+ New bubble",
      "class": "btn btn-primary",
      id: "new-cloud",
      click: function() {
        return _this.create_cloud();
      }
    }));
    $("#top-right").append($("<button>", {
      text: "Reload sentences",
      "class": "btn btn-success",
      id: "new-cloud",
      click: function() {
        var query;
        query = _this.create_request();
        if (query === false) return;
        $("#results").html("loading...");
        $("#diff").html("loading...");
        return $.ajax("/results", {
          data: {
            q: query
          },
          success: function(data) {
            var d, result, sen, _j, _k, _l, _len2, _len3, _len4, _ref2, _ref3, _ref4;
            $("#results").html("");
            $("#diff").html("");
            result = JSON.parse(data);
            _this.last_result = result.words;
            _ref2 = result.words;
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              d = _ref2[_j];
              sen = $("<div>", {
                text: d.join(" ")
              });
              $("#results").append(sen);
            }
            _ref3 = result.added;
            for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
              d = _ref3[_k];
              sen = $("<div>", {
                style: "color: #5BB75B;",
                text: "+ " + d.join(" ")
              });
              $("#diff").append(sen);
            }
            _ref4 = result.removed;
            for (_l = 0, _len4 = _ref4.length; _l < _len4; _l++) {
              d = _ref4[_l];
              sen = $("<div>", {
                style: "color: #DA4F49;",
                text: "- " + d.join(" ")
              });
              $("#diff").append(sen);
            }
            $("#results-name").text("Results ( " + result.words.length + " )");
            return $("#diff-name").text("Diff ( +" + result.added.length + ", -" + result.removed.length + " )");
          }
        });
      }
    }));
    return h;
  };

  Sentence.prototype.word = function(w) {
    var h;
    h = $("<span>", {
      text: "" + w + " "
    });
    return h;
  };

  return Sentence;

})();
