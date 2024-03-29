// Generated by CoffeeScript 1.3.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Endbands.Views.Modal = (function(_super) {

    __extends(Modal, _super);

    function Modal() {
      this.render = __bind(this.render, this);

      this.removeModal = __bind(this.removeModal, this);
      return Modal.__super__.constructor.apply(this, arguments);
    }

    Modal.prototype.className = "modal";

    Modal.prototype.events = {
      "click div#modal-screen": "removeModal",
      "touchend div#modal-screen": "removeModal",
      "focus input": "clearDefaultTxt",
      "blur input": "setDefaultTxt"
    };

    Modal.prototype.clearDefaultTxt = function(ev) {
      var target;
      target = $(ev.currentTarget);
      if (target.val() === target.attr('defaultValue') && (target.attr("data-keep") !== "true")) {
        return target.val("");
      }
    };

    Modal.prototype.setDefaultTxt = function(ev) {
      var target;
      target = $(ev.currentTarget);
      if (target.val().length === 0) {
        return target.val(target.attr('defaultValue'));
      }
    };

    Modal.prototype.removeModal = function(ev) {
      var that;
      that = this;
      return $(this.el).children().not(".modal-screen").each(function(i) {
        return $(this).delay(200 * i).animate({
          "top": "100%"
        }, 250, "easeInBack", function() {
          return $(that.el).animate({
            "opacity": 0
          }, 350, function() {
            return that.remove();
          });
        });
      });
    };

    Modal.prototype.render = function() {
      console.log("modal render");
      $(this.el).html(this.template).children().not(".modal-screen").each(function(i) {
        return $(this).delay(200 * i).animate({
          "top": 0
        }, 350, "easeOutBack");
      });
      return this;
    };

    return Modal;

  })(Backbone.View);

  Endbands.Views.AddModal = (function(_super) {

    __extends(AddModal, _super);

    function AddModal() {
      return AddModal.__super__.constructor.apply(this, arguments);
    }

    AddModal.prototype.events = _.extend({
      "click .cancel": "removeModal",
      "click .add": "createNewBook"
    }, AddModal.prototype.events);

    AddModal.prototype.createNewBook = function(ev) {
      var data, newBook;
      data = $(ev.currentTarget).closest('form').serializeArray();
      console.log(data);
      newBook = new Endbands.Models.Book({
        "title": data[0].value,
        "author": {
          "first": data[1].value.split(" ")[0],
          "last": data[1].value.substring(data[1].value.indexOf(" ") + 1)
        },
        "library": Endbands.app.main.panel - 2,
        "pageCount": data[2].value
      });
      newBook.get("events").reset();
      Endbands.app.books.add(newBook);
      return this.removeModal();
    };

    AddModal.prototype.initialize = function() {
      var _this = this;
      return $.get("templates/add_modal.html", function(tpl) {
        _this.template = tpl;
        return _this.render();
      });
    };

    return AddModal;

  })(Endbands.Views.Modal);

  Endbands.Views.EditModal = (function(_super) {

    __extends(EditModal, _super);

    function EditModal() {
      this.render = __bind(this.render, this);
      return EditModal.__super__.constructor.apply(this, arguments);
    }

    EditModal.prototype.deleteStatus = 0;

    EditModal.prototype.events = _.extend({
      "click .cancel": "removeModal",
      "click .save": "updateListName",
      "click .delete": "deleteList"
    }, EditModal.prototype.events);

    EditModal.prototype.updateListName = function(ev) {
      var data, idx;
      data = $(ev.currentTarget).closest('form').serializeArray();
      idx = _.indexOf(Endbands.app.libraries, _.where(Endbands.app.libraries, {
        "name": this.model.name
      })[0]);
      Endbands.app.libraries[idx].name = data[0].value;
      $(Endbands.app.libraries[idx].view.el).find('h4').html(data[0].value);
      return this.removeModal();
    };

    EditModal.prototype.initialize = function() {
      var _this = this;
      return $.get("templates/edit_modal.html", function(tpl) {
        _this.template = Handlebars.compile(tpl);
        return _this.render();
      });
    };

    EditModal.prototype.deleteList = function() {
      var libIdx, library,
        _this = this;
      if (this.deleteStatus === 0) {
        $('.delete').html("Are you sure? Books will move to " + Endbands.app.libraries[0].name + ".");
        $('.delete').addClass("deleteConf");
        return this.deleteStatus++;
      } else {
        Endbands.app.main.backPanel();
        Endbands.app.main.totalPanels--;
        library = _.where(Endbands.app.libraries, {
          "name": this.model.name
        })[0];
        libIdx = _.indexOf(Endbands.app.libraries, library);
        _.each(Endbands.app.books.models, function(mdl) {
          if (mdl.get("library") === libIdx) {
            return mdl.set("library", 0);
          }
        });
        $(library.view.el).remove();
        Endbands.app.libraries = _.without(Endbands.app.libraries, library);
        return this.removeModal();
      }
    };

    EditModal.prototype.render = function() {
      var libIdx, listData;
      listData = this.model;
      libIdx = _.indexOf(Endbands.app.libraries, _.where(Endbands.app.libraries, {
        "name": this.model.name
      })[0]);
      if (libIdx === 0) {
        listData['del-status'] = "disabled";
      } else {
        listData['del-status'] = "";
      }
      $(this.el).html(this.template(listData)).children().not(".modal-screen").each(function(i) {
        return $(this).delay(200 * i).animate({
          "top": 0
        }, 350, "easeOutBack");
      });
      return this;
    };

    return EditModal;

  })(Endbands.Views.Modal);

  Endbands.Views.DetailsModal = (function(_super) {

    __extends(DetailsModal, _super);

    function DetailsModal() {
      this.render = __bind(this.render, this);
      return DetailsModal.__super__.constructor.apply(this, arguments);
    }

    DetailsModal.prototype.deleteStatus = 0;

    DetailsModal.prototype.events = _.extend({
      "click .cancel": "removeModal",
      "click .save": "updateBook",
      "click .tabs li": "switchTabs",
      "click #new-list": "addNewList",
      "click .delete": "deleteBook"
    }, DetailsModal.prototype.events);

    DetailsModal.prototype.initialize = function() {
      var _this = this;
      return $.get("templates/details_modal.html", function(tpl) {
        _this.template = Handlebars.compile(tpl);
        return _this.render();
      });
    };

    DetailsModal.prototype.addNewList = function(ev) {
      var count, html, name;
      name = "new book list";
      Endbands.app.libraries.push({
        "name": name,
        "view": new Endbands.Views.LibraryPanelView({
          collection: Endbands.app.main.collection,
          "name": name
        })
      });
      $("#wrapper").append(_.last(Endbands.app.libraries).view.el);
      Endbands.app.main.totalPanels++;
      $('#wrapper').css({
        'width': Endbands.app.main.totalPanels * 100 + "%"
      });
      count = Endbands.app.libraries.length - 1;
      html = '<li><input type="radio" name="list" value="' + count + '" id="list' + count + '"><label for="list' + count + '">' + name + '</label></li>';
      return $(html).hide().appendTo(".modal .list-select").delay(100).slideDown(500);
    };

    DetailsModal.prototype.deleteBook = function(ev) {
      if (this.deleteStatus === 0) {
        $('.delete').html("Are you sure... <span>Delete</span> this book?");
        $('.delete').addClass("deleteConf");
        return this.deleteStatus++;
      } else {
        this.model.destroy();
        Endbands.app.bookPanel.model = Endbands.app.books.models[0];
        Endbands.app.bookPanel.render();
        return this.removeModal();
      }
    };

    DetailsModal.prototype.updateBook = function(ev) {
      var data;
      data = $(ev.currentTarget).closest('form').serializeArray();
      console.log(data[2].value);
      this.model.set("title", data[0].value);
      this.model.set("author", {
        "first": data[1].value.split(" ")[0],
        "last": data[1].value.substring(data[1].value.indexOf(" ") + 1)
      });
      this.model.set("library", parseInt(data[3].value));
      this.model.set("pageCount", data[2].value);
      console.log(this.model);
      return this.removeModal();
    };

    DetailsModal.prototype.switchTabs = function(ev) {
      var $target, mode;
      $target = $(ev.currentTarget);
      mode = $target.data("tab");
      if (!$target.hasClass("selected")) {
        $(".tabs li").toggleClass("selected");
        return $(".tab").fadeOut("fast").delay(150).filter("." + mode).fadeIn("fast");
      }
    };

    DetailsModal.prototype.render = function() {
      var bookData;
      bookData = $.extend(this.model.toJSON(), {
        "lib-list": _.pluck(Endbands.app.libraries, "name")
      });
      console.log(bookData);
      $(this.el).html(this.template(bookData)).children().not(".modal-screen").each(function(i) {
        return $(this).delay(200 * i).animate({
          "top": 0
        }, 350, "easeOutBack");
      });
      return this;
    };

    return DetailsModal;

  })(Endbands.Views.Modal);

  Endbands.Views.BookThumbnailView = (function(_super) {

    __extends(BookThumbnailView, _super);

    function BookThumbnailView() {
      this.render = __bind(this.render, this);

      this.removeBook = __bind(this.removeBook, this);

      this.moveBook = __bind(this.moveBook, this);

      this.sendToBookPanel = __bind(this.sendToBookPanel, this);
      return BookThumbnailView.__super__.constructor.apply(this, arguments);
    }

    BookThumbnailView.prototype.tagName = "li";

    BookThumbnailView.prototype.initialize = function() {
      var _this = this;
      $(this.el).attr("class", "book-thumb");
      $(this.el).hammer({
        prevent_default: true
      }).on("tap", function(ev) {
        return _this.sendToBookPanel();
      }).on("hold", function(ev) {
        console.log("hold");
        return $("#viewport").append(new Endbands.Views.DetailsModal({
          model: _this.model
        }).el);
      });
      $.get("templates/single_book.html", function(tpl) {
        _this.template = Handlebars.compile(tpl);
        return _this.render();
      });
      $(this.el).on('flipPanel', this.sendToBookPanel);
      this.model.bind("change:title", this.render);
      this.model.bind("change:library", this.moveBook);
      return this.model.bind("destroy", this.removeBook);
    };

    BookThumbnailView.prototype.sendToBookPanel = function() {
      var val;
      Endbands.app.bookPanel.model = this.model;
      Endbands.app.bookPanel.render();
      val = parseInt(this.model.get('pageCount'));
      if (isNaN(val)) {
        $('#slider span').html("I've read:");
      } else {
        $('#slider span').html("I'm now on page:");
      }
      return Endbands.app.main.goToFirst();
    };

    BookThumbnailView.prototype.moveBook = function() {
      _.pluck(Endbands.app.libraries, "view")[this.model.get("library")].render();
      return this.removeBook();
    };

    BookThumbnailView.prototype.removeBook = function() {
      return this.remove();
    };

    BookThumbnailView.prototype.render = function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    };

    return BookThumbnailView;

  })(Backbone.View);

  Endbands.Views.LibraryPanelView = (function(_super) {

    __extends(LibraryPanelView, _super);

    function LibraryPanelView() {
      this.render = __bind(this.render, this);

      this.updateDisplay = __bind(this.updateDisplay, this);
      return LibraryPanelView.__super__.constructor.apply(this, arguments);
    }

    LibraryPanelView.prototype.$bookList = null;

    LibraryPanelView.prototype.yPos = 0;

    LibraryPanelView.prototype.initialize = function() {
      var _this = this;
      this.name = this.options.name;
      $(this.el).addClass("library panel");
      this.collection.bind('add', this.updateDisplay);
      return $.get("templates/library_panel.html", function(tpl) {
        _this.template = Handlebars.compile(tpl);
        return _this.render();
      });
    };

    LibraryPanelView.prototype.updateDisplay = function() {
      this.render().delay(100).children().last().trigger("flipPanel");
      return this.$bookList.animate({
        "top": -(this.$bookList.height() - $("#viewport").height())
      }, 350, "easeOutSine");
    };

    LibraryPanelView.prototype.render = function() {
      var libIdx,
        _this = this;
      $(this.el).html(this.template({
        "name": this.name
      }));
      this.$bookList = $(this.el).children('.book-list');
      this.$bookList.empty();
      libIdx = _.indexOf(_.pluck(Endbands.app.libraries, "view"), this);
      _.each(this.collection.models, function(mdl) {
        if (mdl.get("library") === libIdx) {
          return _this.$bookList.append(new Endbands.Views.BookThumbnailView({
            model: mdl
          }).el);
        }
      });
      this.attachListeners();
      return $("#library .book-list");
    };

    LibraryPanelView.prototype.attachListeners = function() {
      var $addBtn, $editBtn, $target, that,
        _this = this;
      that = this;
      $target = that.$bookList;
      $target.hammer({
        stop_propagation: true,
        drag_horizontal: false
      }).on("dragstart", function(ev) {
        return that.yPos = parseInt($target.css("top"));
      }).on("drag", function(ev) {
        if (ev.direction === "up") {
          return $target.css({
            "top": _this.yPos - ev.distance
          });
        } else if (ev.direction = "down") {
          return $target.css({
            "top": _this.yPos + ev.distance
          });
        }
      }).on("dragend", function(ev) {
        if (parseInt($target.css("top")) > 0) {
          return $target.animate({
            "top": 0
          }, 250, "easeOutSine");
        } else if (Math.abs(parseInt($target.css("top"))) > ($target.height() - $("#viewport").height())) {
          return $target.animate({
            "top": -($target.height() - $("#viewport").height())
          }, 250, "easeOutSine");
        }
      });
      $addBtn = $(that.el).find('.add');
      $addBtn.hammer({
        prevent_default: true
      }).on("tap", function(ev) {
        return $("#viewport").append(new Endbands.Views.AddModal().el);
      });
      $editBtn = $(that.el).find('.edit');
      return $editBtn.hammer({
        prevent_default: true
      }).on("tap", function(ev) {
        return $("#viewport").append(new Endbands.Views.EditModal({
          model: {
            'name': that.name
          }
        }).el);
      });
    };

    return LibraryPanelView;

  })(Backbone.View);

  Endbands.Views.BookEventView = (function(_super) {

    __extends(BookEventView, _super);

    function BookEventView() {
      this.render = __bind(this.render, this);
      return BookEventView.__super__.constructor.apply(this, arguments);
    }

    BookEventView.prototype.tagName = "li";

    BookEventView.prototype.initialize = function() {
      var _this = this;
      $(this.el).attr("class", "event");
      $(this.el).hammer({
        drag_vertical: false,
        drag_horizontal: false,
        swipe: false
      }).on("tap", function(ev) {
        return console.log(_this.model.get('pages'));
      });
      return $.get("templates/event.html", function(tpl) {
        _this.template = Handlebars.compile(tpl);
        return _this.render();
      });
    };

    BookEventView.prototype.render = function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    };

    return BookEventView;

  })(Backbone.View);

  Endbands.Views.BookPanelView = (function(_super) {

    __extends(BookPanelView, _super);

    function BookPanelView() {
      this.render = __bind(this.render, this);
      return BookPanelView.__super__.constructor.apply(this, arguments);
    }

    BookPanelView.prototype.el = "#book";

    BookPanelView.prototype.template = "book_panel";

    BookPanelView.prototype.yPos = 0;

    BookPanelView.prototype.newEvent = false;

    BookPanelView.prototype.initialize = function() {
      this.attachListeners();
      return this.render();
    };

    BookPanelView.prototype.updateModel = function() {
      this.model.set("eventCount", this.model.get("events").length, {
        silent: true
      });
      this.model.set("eventTotal", _.reduce(this.model.get("events").models, function(memo, evt) {
        return memo + evt.get('pages');
      }, 0), {
        silent: true
      });
      return this.model.set("eventAvg", Math.floor(this.model.get("eventTotal") / this.model.get("eventCount")), {
        silent: true
      });
    };

    BookPanelView.prototype.attachListeners = function() {
      var _this = this;
      this["this"];
      return $(this.el).hammer({
        prevent_default: true,
        drag_horizontal: false
      }).on("dragstart", function(ev) {
        console.log("test");
        _this.yPos = parseInt($(_this.el).css("top"));
        if (ev.position.y <= 60) {
          return _this.newEvent = true;
        }
      }).on("drag", function(ev) {
        if (!_this.newEvent) {
          if (ev.direction === "up") {
            return $(_this.el).css({
              "top": _this.yPos - ev.distance
            });
          } else if (ev.direction = "down") {
            return $(_this.el).css({
              "top": _this.yPos + ev.distance
            });
          }
        } else {
          return _this.dragEventSlider(ev);
        }
      }).on("dragend", function(ev) {
        var newEvent;
        if (!_this.newEvent) {
          if (parseInt($(_this.el).css("top")) > 0) {
            return $(_this.el).animate({
              "top": 0
            }, 250, "easeOutSine");
          } else if (Math.abs(parseInt($(_this.el).css("top"))) > ($(_this.el).height() - $("#viewport").height())) {
            return $(_this.el).animate({
              "top": -($(_this.el).height() - $("#viewport").height())
            }, 250, "easeOutSine");
          }
        } else {
          newEvent = new Endbands.Models.Event({
            "date": new Date(),
            "pages": _this.distToPages(ev.distance)
          });
          _this.model.get("events").push(newEvent);
          $(new Endbands.Views.BookEventView({
            model: newEvent
          }).el).hide().prependTo("ul.events").delay(100).slideDown(500).queue(function() {
            return _this.render();
          });
          $("#slider").animate({
            "top": "-" + document.documentElement.clientHeight + "px"
          }, 1550, "easeOutElastic");
          return _this.newEvent = false;
        }
      });
    };

    BookPanelView.prototype.dragEventSlider = function(ev) {
      var val;
      val = parseInt(this.model.get('pageCount'));
      if (isNaN(val)) {
        val = 0;
      } else {
        val = this.model.get('eventTotal');
      }
      $('#slider a').html(val + this.distToPages(ev.distanceY));
      return $('#slider').css('top', -568 + ev.distanceY);
    };

    BookPanelView.prototype.distToPages = function(dist) {
      var val;
      val = Math.floor(dist / 3 - 20);
      if (val >= 0) {
        return val;
      } else {
        return 0;
      }
    };

    BookPanelView.prototype.render = function() {
      var _this = this;
      this.updateModel();
      $.get("templates/" + this.template + ".html", function(tpl) {
        var $evList, data, template;
        template = Handlebars.compile(tpl);
        data = _this.model.toJSON();
        $(_this.el).html(template(data));
        $evList = $(_this.el).children("ul.events");
        return _this.model.get('events').each(function(event) {
          return $evList.prepend(new Endbands.Views.BookEventView({
            model: event
          }).el);
        });
      });
      return this;
    };

    return BookPanelView;

  })(Backbone.View);

  Endbands.Views.MainView = (function(_super) {

    __extends(MainView, _super);

    function MainView() {
      this.forwardPanel = __bind(this.forwardPanel, this);

      this.backPanel = __bind(this.backPanel, this);

      this.goToFirst = __bind(this.goToFirst, this);
      return MainView.__super__.constructor.apply(this, arguments);
    }

    MainView.prototype.el = "#wrapper";

    MainView.prototype.panel = 1;

    MainView.prototype.totalPanels = 3;

    MainView.prototype.inTransition = false;

    MainView.prototype.viewportSize = document.documentElement.clientWidth;

    MainView.prototype.initialize = function() {
      var _this = this;
      $(this.el).hammer({
        prevent_default: true
      }).on("swipe", function(ev) {
        if (!_this.inTransition) {
          _this.inTransition = true;
          if (ev.direction === "right") {
            return _this.forwardPanel();
          } else if (ev.direction === "left") {
            return _this.backPanel();
          }
        }
      });
      Endbands.app.bookPanel = new Endbands.Views.BookPanelView({
        model: this.collection.at(0)
      });
      Endbands.app.libraries.push({
        "name": "my library",
        "view": new Endbands.Views.LibraryPanelView({
          collection: this.collection,
          name: "my library"
        })
      });
      $("#wrapper").append(_.last(Endbands.app.libraries).view.el);
      Endbands.app.libraries.push({
        "name": "archive",
        "view": new Endbands.Views.LibraryPanelView({
          collection: this.collection,
          name: "archive"
        })
      });
      $("#wrapper").append(_.last(Endbands.app.libraries).view.el);
      return this;
    };

    MainView.prototype.goToFirst = function() {
      $(this.el).animate({
        right: '0'
      }, 300, "easeInOutSine");
      this.panel = 1;
      return this.inTransition = false;
    };

    MainView.prototype.backPanel = function() {
      if (this.panel > 1) {
        $(this.el).animate({
          right: '+=' + this.viewportSize + "px"
        }, 300);
        this.panel--;
        return this.inTransition = false;
      }
    };

    MainView.prototype.forwardPanel = function() {
      if (this.panel < this.totalPanels) {
        $(this.el).animate({
          right: '-=' + this.viewportSize + "px"
        }, 300);
        this.panel++;
        return this.inTransition = false;
      }
    };

    return MainView;

  })(Backbone.View);

  Endbands.init = function() {
    Endbands.app.libraries = [];
    return $(function() {
      return $.ajax({
        url: "data.json",
        dataType: "json",
        cache: false,
        error: function(xhr, status, thrown) {
          return console.log(xhr, status, thrown);
        },
        success: function(data) {
          Endbands.app.books = new Endbands.Collections.Books(data);
          return Endbands.app.main = new Endbands.Views.MainView({
            collection: Endbands.app.books
          });
        }
      });
    });
  };

  Handlebars.registerHelper('fullname', function(author) {
    return new Handlebars.SafeString(author.first + " " + author.last);
  });

  Handlebars.registerHelper('each_with_index', function(array, obj) {
    var buffer, i, item, _i, _len;
    buffer = '';
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      i = array[_i];
      item = {};
      item.index = _i;
      item.value = i;
      buffer += obj.fn(item);
    }
    return buffer;
  });

  Handlebars.registerHelper('equals', function(lvalue, rvalue, options) {
    if (lvalue !== rvalue) {
      return options.inverse(this);
    } else {
      return options.fn(this);
    }
  });

}).call(this);
