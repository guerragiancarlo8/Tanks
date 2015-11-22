class Explosion
	#mientras mas algo este valor, más lento el proceso de la animación. Es decir, que mientras más
	#alto esté este número, más tiempo tardará el array con la animación en recorrer. 
	FRAME_DELAY = 10 

	#esta es el spritesheet. tiene 64 "frames" y se leen de izquierda a derecha
	SPRITE = media_path('explosion.png')

	def self.load_animation()
		#cada frame mide 128 x 128. saca las imagenes del spritesheet, guardado en SPRITE
		Gosu::Image.load_tiles(SPRITE,128,128,{:tileable => false})
	end

	def initialize(animation, x, y)
		#le pasas una animación, junto con unas coordenadas. inicializa en @animation[0]
		@animation = animation
		@x, @y = x, y
		@current_frame = 0
	end

	def update
		#incrementas el frame(de los 64) si el frame acaba de expirarse
		@current_frame += 1 if frame_expired?
	end

	def draw
		return if done?
		#mage contiene el frame con el cual vamos a empezar. ver abajo. 
		#dividimos el width y el height de la imagen para que quede centrado el fueguito en el 
		#lugar donde demos click. en este caso sería @x - 128/2 = 64. x - 64, y - 64
		image = current_frame
		image.draw(@x - image.width / 2.0, @y - image.height / 2.0, 0)
	end

	def done?
		#cuando haya terminado de recorrer el array de @animation, es que
		#la animación ha terminado. 
		@current_frame == @animation.size
	end

	private

	def current_frame 
		#del array de los 64 fueguitos, te saca la imagen que corresponda al current fraome
		#un ejemplo @animation[1 % 64] == @animation[1], @animation[2%64] == @animation[2]
		@animation[@current_frame % @animation.size]
	end

	def frame_expired?
		#si ve que el último frame se renderizó después que el frame_delay, renderiza la nueva imagen. 
		#por eso es que si incrementamos el frame delay, el fueguito se verá más lento al renderizar. 
		now = Gosu.milliseconds
		@last_frame ||= now
		if (now-@last_frame) > FRAME_DELAY
			@last_frame = now
		end
	end
end