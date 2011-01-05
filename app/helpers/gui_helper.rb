module GuiHelper

  def progress_bar(now, max, classes='green', width=200)
    ratio = 1.0*now/max
    "<div class='progressbar #{classes}' style='width: #{width}px'>
      <div class='bar1' style='width:#{width*ratio}px'></div>
      <div class='bar2' style='width:#{width*ratio}px'></div>
      <div class='bar3' style='width:#{width*ratio}px'></div>
    </div>".html_safe
  end

  def warning_progress_bar(now, max, width=200)
    ratio = 1.0*now/max
    classes = case ratio
    when 0..0.6 then :green
    when 0.6..0.8 then :yellow
    else :red
    end
    progress_bar now, max, classes, width
  end

end