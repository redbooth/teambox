Weakling = {
  check_password_strength: function(target,name,strengths){  
    var score = this.password_score($(target).value);
    if(score == 5)
      $(name).innerHTML = "<span class='strong'>"+strengths['strong']+"</span>";
    else if (score > 2)
      $(name).innerHTML = "<span class='average'>"+strengths['average']+"</span>";
    else if (score > 0)
      $(name).innerHTML = "<span class='weak'>"+strengths['weak']+"</span>";
    else if (score == 0)
      $(name).innerHTML = "<span class='default'>"+strengths['default']+"</span>";
    else if (score == -1)
      $(name).innerHTML = "<span class='error'>"+strengths['error']+"</span>";
  },
  password_score: function(password){
    var score = 0;
    if (password.match(/.[!,@,#,$,%,^,&,*,?,_,~]/))  //special character
      score += 1;
    if (password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)) //upper and lower case
      score += 1;
    if (password.match(/([a-zA-Z])/) && password.match(/([0-9])/)) //letters and numbers
      score += 1;
    if (password.length == 0)
      score = 0;
    else if (password.length <= 4)
      score = -1;
    else if (password.length > 4 && password.length < 8)
      score += 1;
    else if (password.length >= 8)
      score += 2;

    return score;
  }
}