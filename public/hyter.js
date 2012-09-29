var Hyter, Sentence,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Sentence = (function() {

  Sentence.prototype.words = null;

  function Sentence(text) {
    this.word = __bind(this.word, this);
    this.component = __bind(this.component, this);    this.words = text.split(" ");
    console.log(this.component());
    $("#content").append(this.component());
  }

  Sentence.prototype.component = function() {
    var h, word, _i, _len, _ref;
    h = $("<h3>");
    _ref = this.words;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      word = _ref[_i];
      h.append(this.word(word));
    }
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

Hyter = (function() {

  function Hyter() {
    var sentence;
    sentence = new Sentence("hello world");
    console.log(sentence.words);
  }

  return Hyter;

})();

$(function() {
  return new Hyter();
});
