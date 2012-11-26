var Cloud, Hyter, Sentence,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Cloud = (function() {

  function Cloud(words, option) {
    this.slot = __bind(this.slot, this);
    this.create_target = __bind(this.create_target, this);
    this.component = __bind(this.component, this);    this.option = option;
    this.words = words;
    this.html = this.component();
  }

  Cloud.prototype.component = function() {
    var button_panel, clone_button, constraints, covered, del_button, h, i, tar, target, value, w, word, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3,
      _this = this;
    h = $("<div>", {
      "class": "cloud",
      html: ""
    });
    button_panel = $("<div>", {
      "class": "button-panel",
      style: "float: right; visibility: hidden;"
    });
    del_button = $("<button>", {
      text: "x",
      "class": "btn btn-danger btn-mini",
      click: function() {
        if (confirm("Delete this bubble?")) return _this.html.remove();
      }
    });
    clone_button = $("<button>", {
      text: "clone",
      "class": "btn btn-info btn-mini",
      click: function(event) {
        var i, new_el, new_el_textareas, t, _i, _len, _ref;
        new_el = $(event.target).parent().parent().clone(true);
        new_el_textareas = new_el.find("textarea");
        i = 0;
        _ref = $(event.target).parent().parent().find("textarea");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          $(new_el_textareas[i]).val($(t).val());
          i += 1;
        }
        return $(event.target).parent().parent().after(new_el);
      }
    });
    button_panel.append(clone_button);
    button_panel.append(del_button);
    h.append(button_panel);
    i = 0;
    _ref = this.words;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      word = _ref[_i];
      w = $("<span>", {
        "class": "word",
        text: "" + word,
        "data-word-id": "w_" + i,
        click: function(event) {
          return $(event.target).toggleClass("word-selected");
        }
      });
      h.append(w);
      i += 1;
    }
    if (this.option) {
      _ref2 = this.option.covered;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        covered = _ref2[_j];
        h.children().filter("[data-word-id='" + covered + "']").click();
      }
    }
    h.append("<br>");
    constraints = $("<textarea>", {
      "class": "constraints",
      placeholder: "Constraints we satisfy",
      spellcheck: "false"
    });
    if (this.option) constraints.val(this.option.up_rules.join("\n"));
    target = this.create_target();
    h.append($("<div>", {
      style: "clear: both;"
    }));
    h.append(target);
    h.append(constraints);
    h.append($("<div>", {
      style: "clear: both;"
    }));
    if (this.option) {
      i = 0;
      while (i < (this.option.target.length - 1) / 2) {
        target.children().filter(".plus-button").first().click();
        i += 1;
      }
      i = 0;
      _ref3 = this.option.target;
      for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
        tar = _ref3[_k];
        if ($.isArray(tar)) {
          value = tar.join("\n");
        } else {
          value = tar;
        }
        $(target.children().filter("textarea")[i]).val(value);
        i += 1;
      }
    }
    h.hover(function(event) {
      return $(event.delegateTarget).find(".button-panel, .btn").css("visibility", "visible");
    }, function(event) {
      return $(event.delegateTarget).find(".button-panel, .btn").css("visibility", "hidden");
    });
    return h;
  };

  Cloud.prototype.create_target = function() {
    var ret;
    ret = $("<div>", {
      "class": "target"
    });
    ret.append($("<span>", {
      text: "x",
      "class": "btn btn-danger btn-mini first-remover btn-not-visible",
      click: this.click_on_delete_slot
    }));
    ret.append(this.slot());
    ret.append($("<span>", {
      text: "x",
      "class": "btn btn-danger btn-mini last-remover btn-not-visible",
      click: this.click_on_delete_slot
    }));
    return ret;
  };

  Cloud.prototype.click_on_delete_slot = function(event) {
    var name, textareas;
    if ($(event.target).hasClass("first-remover")) {
      name = "first";
    } else {
      name = "last";
    }
    textareas = $(event.target).parent().children().filter("textarea");
    if (textareas.length === 1) {
      alert("Can't delete single slot.");
      return;
    }
    if (!confirm("Really delete " + name + " slot and atom?")) return;
    if (textareas.length > 1) {
      $(event.target).parent().children().filter("textarea")[name]().remove();
      $(event.target).parent().children().filter("textarea")[name]().remove();
      $(event.target).parent().children().filter(".plus-button")[name]().remove();
      return $(event.target).parent().children().filter(".plus-button")[name]().remove();
    }
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
      "class": "btn btn-mini btn-info plus-button btn-not-visible",
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
      "class": "btn btn-mini btn-info plus-button btn-not-visible",
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
        placeholder: "Slots (constraints)",
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

  function Hyter(words, data) {
    var sentence;
    sentence = new Sentence(words, data, this);
    $("#annotation-navigation").hide();
    $("#annotation-app").show();
  }

  return Hyter;

})();

$(function() {
  var _this = this;
  $("#annotation-app").hide();
  $("#new-annotation").click(function() {
    var words;
    words = prompt("Enter sentence for annotation:", "");
    return new Hyter(words, false);
  });
  return $(".saved-annotation").click(function(event) {
    var id;
    id = $(event.target).data("id");
    return $.ajax("/result/" + id + "", {
      success: function(result) {
        result = JSON.parse(result);
        result = JSON.parse(result[3]);
        console.log(result);
        return new Hyter(false, result);
      }
    });
  });
});

Sentence = (function() {

  Sentence.prototype.words = null;

  Sentence.prototype.clouds = [];

  function Sentence(text, data, hyter) {
    this.word = __bind(this.word, this);
    this.component = __bind(this.component, this);
    this.create_cloud = __bind(this.create_cloud, this);
    this.create_request = __bind(this.create_request, this);
    var option, _i, _len, _ref;
    this.hyter = hyter;
    this.last_result = [];
    if (text) {
      this.words = $.trim(text).split(/[ ]+/);
    } else {
      this.words = data.words;
    }
    $("#sentence").append(this.component());
    if (data) {
      $("span[data-name='" + data.root + "']").click();
      if (data.reference) $("#reference").html(data.reference);
      if (data.options) {
        _ref = data.options;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          option = _ref[_i];
          this.create_cloud(option);
        }
      }
    }
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
          target.push(text);
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
    req.words = this.words;
    req.reference = $("#reference").html();
    return JSON.stringify(req);
  };

  Sentence.prototype.create_cloud = function(data) {
    var cloud;
    cloud = new Cloud(this.words, data);
    return $("#clouds").append(cloud.html);
  };

  Sentence.prototype.component = function() {
    var h, i, select, w, word, _i, _j, _len, _len2, _ref, _ref2,
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
    select = $("<select>", {
      style: "height: 15px; text-align: bottom;",
      change: function(event) {
        var height;
        height = parseInt($(event.target).attr('value'));
        $("#bottom-empty-block").css("height", height);
        $(".tab-pane").css("height", height - 55);
        return $("#bottom-menu").css("height", height);
      }
    });
    _ref2 = [300, 150, 0];
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      i = _ref2[_j];
      select.append($("<option>", {
        text: "bottom panel width: " + i + " px",
        value: i
      }));
    }
    $("#zoom-settings").append(select);
    $("#top-right").append($("<button>", {
      text: "+ New bubble",
      "class": "btn btn-primary",
      id: "new-cloud",
      click: function() {
        _this.create_cloud();
        return $(window).scrollTop(200000);
      }
    }));
    $("#top-right").append($("<button>", {
      text: "Save and reload",
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
            var d, result, sen, _k, _l, _len3, _len4, _len5, _m, _ref3, _ref4, _ref5;
            console.log(data);
            $("#results").html("");
            $("#diff").html("");
            result = JSON.parse(data);
            _this.last_result = result.words;
            _ref3 = result.words;
            for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
              d = _ref3[_k];
              sen = $("<div>", {
                text: d.join(" ")
              });
              $("#results").append(sen);
            }
            _ref4 = result.added;
            for (_l = 0, _len4 = _ref4.length; _l < _len4; _l++) {
              d = _ref4[_l];
              sen = $("<div>", {
                style: "color: #5BB75B;",
                text: "+ " + d.join(" ")
              });
              $("#diff").append(sen);
            }
            _ref5 = result.removed;
            for (_m = 0, _len5 = _ref5.length; _m < _len5; _m++) {
              d = _ref5[_m];
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
    $("#top-right").append($("<button>", {
      text: "Sort",
      "class": "btn btn-info",
      click: function() {
        var clouds, sorted;
        clouds = $(".cloud");
        sorted = clouds.sort(function(a, b) {
          if (!($(a).find(".word-selected").length > 0)) return 1;
          if (!($(b).find(".word-selected").length > 0)) return -1;
          if (parseInt($(a).find(".word-selected").data("word-id").slice(2)) > parseInt($(b).find(".word-selected").data("word-id").slice(2))) {
            return 1;
          } else {
            return -1;
          }
        });
        return $("#clouds").append(sorted);
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
