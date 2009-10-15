module WeaklingHelper

  def password_strength(name, target, options={})
    default = options[:default] ||= t('weakling.default')
    error   = options[:error] ||= t('weakling.error')
    weak    = options[:weak] ||= t('weakling.weak') 
    average = options[:average] ||= t('weakling.average')
    strong  = options[:strong] ||= t('weakling.strong')

    script = ''    
    script += assign_strengths(default,error,weak,average,strong)
    script += observe_strength_field(name,target)
    script += default_strength_text(name)
    
    "<div id='#{name}' class='weakling'></div><script type='text/javascript'>//<![CDATA[\n#{script}\n//]]></script>"
  end

  def assign_strengths(default,error,weak,average,strong)
    "strengths = {'default':'#{default}','error':'#{error}','weak':'#{weak}','average':'#{average}',strong:'#{strong}'};"
  end
    
  def observe_strength_field(name,target)
    "$('#{target}').observe('keyup', function(event){Weakling.check_password_strength('#{target}','#{name}',strengths)});" 
  end
  
  def default_strength_text(name)
    "$('#{name}').innerHTML = \"<span class='default'>#{t('weakling.default')}</span>\";"
  end
  
end