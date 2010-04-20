var Attacklab=Attacklab||{};
Attacklab.wmd_env={};
Attacklab.account_options={};
Attacklab.wmd_defaults={version:1,output:"HTML",lineLength:40,delayLoad:false};
if(!Attacklab.wmd){
Attacklab.wmd=function(){
Attacklab.loadEnv=function(){
var _1=function(_2){
if(!_2){
return;
}
for(var _3 in _2){
Attacklab.wmd_env[_3]=_2[_3];
}
};
_1(Attacklab.wmd_defaults);
_1(Attacklab.account_options);
_1(top["wmd_options"]);
Attacklab.full=true;
var _4="bold italic | link blockquote code image | ol ul heading hr";
Attacklab.wmd_env.buttons=Attacklab.wmd_env.buttons||_4;
};
Attacklab.loadEnv();
var _5=["showdown.js","wmd-base.js","wmd-plus.js"];
var _6=function(_7){
};
Attacklab.fileLoaded=function(_8){
arguments.callee.count=arguments.callee.count||0;
if(++arguments.callee.count>=_5.length){
var go=function(){
Attacklab.wmdBase();
Attacklab.Util.startEditor();
};
if(Attacklab.wmd_env.delayLoad){
window.setTimeout(go,0);
}else{
go();
}
}
};
Attacklab.editorInit=function(){
Attacklab.wmdPlus();
};
var _a=function(_b,_c){
var _d=Attacklab.basePath+_b;
if(_c){
_d+="?nocache="+(new Date()).getTime();
}
var _e=document.createElement("script");
_e.src=_d;
top.document.documentElement.firstChild.appendChild(_e);
};
var _f=function(_10){
var _11=RegExp("(.*)"+_10+"(\\?(.+))?$","g");
var _12=document.getElementsByTagName("script");
for(var i=0;i<_12.length;i++){
if(_11.test(_12[i].src)){
var _14=RegExp.$1;
if(/wmd-editor.com/.test(_12[i].src)){
return null;
}
return _14;
}
}
};
Attacklab.basePath=_f("wmd.js")||"http://static.wmd-editor.com/v2/";
for(var f,i=0;f=_5[i];i++){
_a(f,false);
}
};
Attacklab.wmd();
}

