/**
 * This js will be injected client side.
 *
 * Use here the assert library you prefer.
 */
function $j(){var a=[],b=0,c="",d=[],e="\033[3",f="\n";return function g(h){h?(a=
a.concat(h),b++):(h=new Date,a.map(function(a){a.call(g,function(a){if(!a)d.push
(e+"1mFailure"+/*console.trace()*/e+"9m");c+=e+(a?"2m✓":"1m✗")})}),console.log([c,e+"9m"
+(new Date-h)+"ms",b+" tests, "+c.length/6+" assertions, "+d.length+" failures",d.
join(f)].join(f)))}}
