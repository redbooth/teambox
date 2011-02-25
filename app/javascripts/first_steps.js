FirstSteps = {
  steps: { completed: 0, total: 5 },
  // Displays the global progress for the first steps
  show: function(where) {
    if (!my_user.show_badges) { return; }
    if (!my_user.first_steps) { return; }
    $$(".first_steps").invoke('remove');
    var html = Mustache.to_html(Templates.first_steps.overview);

    // Where will the overview be rendered?
    this.where = where || this.where || 'column';
    $(this.where).insert({ top: html });

    // Activate the steps that have been completed
    this.steps.completed = 0;
    $w("first_conversation first_task first_page first_project first_invite").each(function(name) {
      if(Badge.has(name)) { FirstSteps.activateStep(name); }
    });

    this.drawProgressBar();
    this.chooseLastUnaccomplishedStep();
  },
  // Highlight a step, keep track of the progress
  activateStep: function(name) {
    var container = $$(".first_steps")[0];
    if (!container) { return; }
    // Use the completed step image
    var img = container.down("img[data-name='"+name+"']");
    img.src = img.src.gsub(/-disabled/, '');
    // Swap the content for the completed step
    var step = img.readAttribute('data-step');
    container.down('.step'+step).innerHTML =
      container.down('.step'+step+'-complete').innerHTML;

    this.steps.completed++;
  },
  // Show the text for a given step
  chooseStep: function(step_number) {
    var container = $$(".first_steps")[0];
    container.select('.step').invoke('hide');
    container.down('.step'+step_number).show();
    container.select('.steps img').invoke('removeClassName', 'active');
    container.down('img[data-step='+step_number+']').addClassName('active');
  },
  // We completed all steps
  stepsCompleted: function() {
    var container = $$(".first_steps")[0];
    container.select('.step').invoke('hide');
    container.down('.completed').show();
    container.select('.steps img').invoke('removeClassName', 'active');
  },
  // Find the next step to be accomplished and expand it
  chooseLastUnaccomplishedStep: function() {
    var img =
      $$('.first_steps .steps img').detect(function(img) {
        return img.readAttribute('src').match(/disabled/);
      });
    if (img) {
      this.chooseStep(img.readAttribute('data-step'));
    } else {
      this.stepsCompleted();
    }
  },
  // Draws progress bar for the overview
  drawProgressBar: function() {
    var container = $$(".first_steps")[0];
    if (!container) { return; }
    container.select(".completion").invoke("remove");
    var percentage = Math.floor(this.steps.completed*100/this.steps.total);
    var html = Mustache.to_html(Templates.first_steps.progress_bar, {
      width: 100,
      filled: percentage,
      text: percentage+'%' });
    if (this.where == 'column') {
      container.down('h2').insert({ after: html });
    } else {
      container.insert({ top: html });
    }
  },
  // Hide First Steps guide persistently
  hide: function() {
    if (!my_user.first_steps) { return; }
    $$(".first_steps").invoke('blindUp');
    my_user.first_steps = false;
    var save = new Ajax.Request("/account/first_steps/hide");
  }
};

// Display first steps overview
document.on("dom:loaded", function() {
  FirstSteps.show();
});

// Display info on how to complete a step
document.on("click", ".first_steps .steps img", function(e,el) {
  var step_number = el.readAttribute("data-step");
  FirstSteps.chooseStep(step_number);
});

// Hide first steps and persist the setting for this user
document.on("click", "a.close_first_steps", function(e,el) {
  e.stop();
  FirstSteps.hide();
});

// Redraw the First Steps panel if present
document.on("badge:new_badge", function() {
  if ($$('.first_steps')[0]) { FirstSteps.show(); }
});
