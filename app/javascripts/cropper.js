function image_crop(c){  
  Event.observe( 
    window, 
    'load', 
    function() { 
      new Cropper.ImgWithPreview( 
        'avatar_crop',
        { 
          minWidth: 55, 
          minHeight: 55,
          ratioDim: { x: 200, y: 200 },
          displayOnInit: true, 
          onEndCrop: onEndCrop,
          previewWrap: 'avatar_preview',
          onloadCoords: { 
            x1: c.x1,
            y1: c.y1,
            x2: c.x2,
            y2: c.y2
          }
        } 
      ) 
    } 
  );
}

function onEndCrop(coords, dimensions){
  $('x1').value = coords.x1;
  $('y1').value = coords.y1;
  $('x2').value = coords.x2;
  $('y2').value = coords.y2;
  $('crop_width').value = dimensions.width;
  $('crop_height').value = dimensions.height;
}