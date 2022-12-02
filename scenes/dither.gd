extends Node2D

# https://en.wikipedia.org/wiki/Ordered_dithering
# https://surma.dev/things/ditherpunk/
# https://gist.github.com/depp/f4dc0d50c22f28f3b6585725219d7eb8
# https://www.shadertoy.com/view/7stSz4
# https://bisqwit.iki.fi/story/howto/dither/jy/

func _ready() -> void:
	var s : String
	var bm_size = 4
	var bm_size_dim = 1 << bm_size
	var bayer_m : Array = bayer_matrix(bm_size)
	
	print(bayer_m)
	print(bayer_m.size())

	var texim = ImageTexture.new()
	var image = Image.new()
	image.create( bm_size_dim, bm_size_dim, false, Image.FORMAT_L8 )
	image.lock()

	for y in bm_size_dim:
		for x in bm_size_dim:
			var idx = y * bm_size_dim + x
			var p = bayer_m[ idx ]
			var nstr : String = str(bayer_m[idx])
			nstr = " ".repeat( 3-nstr.length() ) + nstr
			s += " " + nstr
			image.set_pixel( x, y, Color( p/255.0, p/255.0, p/255.0 ) )
		s += "\n"
	
	$text.text = s
	image.unlock()
	texim.create_from_image(image, 0)
	$Sprite.texture = texim


# typescript playground:
# https://www.typescriptlang.org/play?#code/PTAEHUFMBsGMHsC2lQBd5oBYoCoE8AHSAZVgCcBLA1UABWgEM8BzM+AVwDsATAGiwoBnUENANQAd0gAjQRVSQAUCEmYKsTKGYUAbpGF4OY0BoadYKdJMoL+gzAzIoz3UNEiPOofEVKVqAHSKymAAmkYI7NCuqGqcANag8ABmIjQUXrFOKBJMggBcISGgoAC0oACCbvCwDKgU8JkY7p7ehCTkVDQS2E6gnPCxGcwmZqDSTgzxxWWVoASMFmgYkAAeRJTInN3ymj4d-jSCeNsMq-wuoPaOltigAKoASgAywhK7SbGQZIIz5VWCFzSeCrZagNYbChbHaxUDcCjJZLfSDbExIAgUdxkUBIursJzCFJtXydajBBCcQQ0MwAUVWDEQC0gADVHBQGNJ3KAALygABEAAkYNAMOB4GRonzFBTBPB3AERcwABS0+mM9ysygc9wASmCKhwzQ8ZC8iHFzmB7BoXzcZmY7AYzEg-Fg0HUiQ58D0Ii8fLpDKZgj5SWxfPADlQAHJhAA5SASPlBFQAeS+ZHegmdWkgR1QjgUrmkeFATjNOmGWH0KAQiGhwkuNok4uiIgMHGxCyYrA4PCCyS4sHqjVAACEmN8ALJ1SirJVyABekHy-XYiGk3x1y-uGVQAA4KmQyExQABvRQASBlNHhiB5oAAjKAADxPq4URcAbgvV7Eh7vnHjB4d33Q8mCVG9QAAKjhKEdS-c8EVAOd3xQAA+UAAAYdVPC9L0aKkrnYaQ7zHPBJ2nChZwXFBynvODcJ-QQiIg3kINQ9D73gvDKWvGA8zvajn15AAWUAAH4kMfF8kIAJigpDRPKaidRU0BlwwrjknFJD3BoYteQ00Bi1fJjpBvD8jIAaks7Cz3PeytOxJVdNAUEDIs0ETOYqEPOs2zcPsn8dAYaABKIgBtPBINMm9LNWABdLjAvw9JuDcozINi1YkvPRwyHCig0viu9gugHK8oKtLLJiqFit5UrLJkzK+IYcrD0q1Zqu8xBMtqkqQssgBmZroDzNr8sKzqap68CoUsui6tABr7xGsaAoAX1wzbz22pxUHxLw8q-TbpXwuVIAVeBlVI8jUBnJVhJUoA

func bayer_matrix(size : int = 2) -> Array:
	#https://gist.github.com/depp/f4dc0d50c22f28f3b6585725219d7eb8
	var dim = 1 << size
	var arr : Array = []
	arr.resize( dim * dim )
	arr.fill(0)
	if size > 0:
		var sub : Array = bayer_matrix(size - 1)
		var subdim = dim >> 1
		var delta : int
		if size <= 4:
			delta = 1 << (2* (4-size)) 
		else:
			delta = 0
		for y in range(subdim):
			for x in range(subdim):
				var val = sub[y*subdim+x]
				var idx = y*dim+x
				arr[idx] = val
				arr[idx+subdim] = val+2*delta
				arr[idx+subdim*dim] = val+3*delta
				arr[idx+subdim*(dim+1)] = val+1*delta
	return arr

