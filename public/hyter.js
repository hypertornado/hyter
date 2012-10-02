var Cloud, Hyter, Sentence,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Cloud = (function() {

  function Cloud(words) {
    this.slot = __bind(this.slot, this);
    this.component = __bind(this.component, this);    this.words = words;
    this.html = this.component();
  }

  Cloud.prototype.component = function() {
    var constraints, h, target, w, word, _i, _len, _ref,
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
    h.append(constraints);
    h.append(target);
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
        return slot.show("slow");
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
        return slot.show("slow");
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
    sentence = new Sentence(words);
    console.log(sentence.words);
  }

  return Hyter;

})();

$(function() {
  var words;
  words = "hello world how are you";
  new Hyter(words);
  $("#new-cloud").click();
  $("#new-cloud").click();
  $("#new-cloud").click();
  $("#new-cloud").click();
  $("#new-cloud").click();
  return $("#new-cloud").click();
});

Sentence = (function() {

  Sentence.prototype.words = null;

  Sentence.prototype.clouds = [];

  function Sentence(text) {
    this.word = __bind(this.word, this);
    this.component = __bind(this.component, this);
    this.create_cloud = __bind(this.create_cloud, this);    this.words = text.split(" ");
    $("#sentence").append(this.component());
  }

  Sentence.prototype.create_cloud = function() {
    var cloud;
    cloud = new Cloud(this.words);
    return $("#clouds").append(cloud.html);
  };

  Sentence.prototype.component = function() {
    var h, word, _i, _len, _ref,
      _this = this;
    h = $("<h1>");
    _ref = this.words;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      word = _ref[_i];
      h.append(this.word(word));
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
        return alert("not implemented yet");
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
