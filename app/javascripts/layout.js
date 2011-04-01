document.on('click', 'span.fold_sidebar a, span.unfold_sidebar a', function(e, el) {
  e.stop();
  $$('body')[0].toggleClassName('folded_sidebar');
});

document.on('click', 'span.fold_aux a, span.unfold_aux a', function(e, el) {
  e.stop();
  $$('body')[0].toggleClassName('folded_aux');
});
