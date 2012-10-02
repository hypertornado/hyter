#script for starting all compilations needed for front end development


compile_coffeescript(){ 
	coffee -wbl -j "public/hyter.js" -c public/coffee/*.coffee
}

compile_coffeescript
