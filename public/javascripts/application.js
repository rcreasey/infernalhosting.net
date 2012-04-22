function expand(id) {
  
  var object = document.getElementById(id);
  
  if (object.style.display == "none" ) {
    new Effect.SlideDown(id); 
  } else {
    new Effect.SlideUp(id); 
  }
}
  
//var Notice = {
  //autohide_error: null,
  //autohide_notice: null,
//
  //// When given an error message, wrap it in a list
  //// and show it on the screen. This message will auto-hide
  //// after a specified amount of miliseconds
  //error: function(message) {
    //$('flasherrors').innerHTML = "<li>" + message + "</li>";
    //new Effect.Appear('flasherrors', {duration: 0.3});
  //
    //if (this.autohide_error != null) {clearTimeout(this.autohide_error);}
    //this.autohide_error = setTimeout(Messenger.fadeError.bind(this), 5000);
  //},
  //
  //// Notice-level messages. See Messenger.error for full details.
  //notice: function(message) {
  //$('flashnotice').innerHTML = "<li>" + message + "</li>";
  //new Effect.Appear('flashnotice', {duration: 0.3});
  //
  //if (this.autohide_notice != null) {clearTimeout(this.autohide_notice);}
  //this.autohide_notice = setTimeout(Messenger.fadeNotice.bind(this), 5000);
  //},
  //
  //// Responsible for fading notices level messages in the dom
  //fadeNotice: function() {
  //new Effect.Fade('flashnotice', {duration: 0.3});
  //this.autohide_notice = null;
  //},
  //
  //// Responsible for fading error messages in the DOM
  //fadeError: function() {
  //new Effect.Fade('flasherrors', {duration: 0.3});
  //this.autohide_error = null;
  //}
 // Messenger.notice("Removed page test.");
// new Effect.Fade("page-25418",{});
//};

function Notice() {
  new Effect.Appear('alert', {duration: 0.3});

}
