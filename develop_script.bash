#script for starting all compilations needed for front end development

JS_PATH="public/coffee"

compile_coffeescript(){ 
	coffee -wbl -j "public/hyter.js" -c $JS_PATH/*.coffee
}

compile_coffeescript