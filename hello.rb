require 'gosu'

def media_path(file)
	File.join(File.dirname(File.dirname(__FILE__)), 'media',file)
end

class Explosion
	#mientras mas algo este valor, más lento el proceso de la animación. Es decir, que mientras más
	#alto esté este número, más tiempo tardará el array con la animación en recorrer. 
	FRAME_DELAY = 10 

	#esta es el spritesheet. tiene 64 "frames" y se leen de izquierda a derecha
	SPRITE = media_path('explosion.png')

	def self.load_animation()
		#cada frame mide 128 x 128. saca las imagenes del spritesheet, guardado en la variable SPRITE
		Gosu::Image.load_tiles(SPRITE,128,128,{:tileable => false})
	end

	def self.load_sound(window)
		Gosu::Sample.new(window, media_path('explosion.mp3'))
	end

	def initialize(animation, sound, x, y)
		#le pasas una animación, junto con unas coordenadas. inicializa en @animation[0]
		@animation = animation
		sound.play
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

	def sound
		#podríamos haber simplemente invocado la variable @sound arriba
		#pero parece que el autor quiso hacer un método específico para ello. 
		@sound.play
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


class GameWindow < Gosu::Window
	BACKGROUND = media_path('country_field.png')

	def initialize(width=800, height=600, fullscreen=false)
		super
		self.caption = "Hola Animación"
		@background = Gosu::Image.new(self, BACKGROUND, {:tileable => false})
		#@animation va a ser el spritesheet. 
		@animation = Explosion.load_animation()
		#la musiquita que tocará en el transcurso de todo el juego
		@music = Gosu::Song.new(self, media_path('menu_music.mp3'))
		@music.volume = 0.5
		@music.play(true)
		#ahora sí vamos a bajar el sonido de una explosión
		@sound = Explosion.load_sound(self)
		@explosions = []
		
	end

	def update
		#traversar el array de @explosions. Si ve que hay una para la cual
		#su método 'done?' sea true, la saca del array. 
		@explosions.reject!(&:done?)
		#para todas las explosiones que queden en @explosions, llama
		#el método de clase Explosion::update a cada una y recalcula
		#su variable de Explosion::@current_frame. 
		@explosions.map(&:update)
	end

	def button_down(id)
		#si apretamos escape. salir del juego
		close if id == Gosu::KbEscape

		#si apretamos el ratón, creamos una nueva instancia de Exposion, supliéndole
		#el array de imágenes de fueguito, junto con la x,y de donde se dio click en pantalla
		if id == Gosu::MsLeft
			@explosions.push(Explosion.new(@animation, @sound, mouse_x, mouse_y))
		end
	end

	def needs_cursor?
		true
	end

	def needs_redraw?
		#esto evita tener que renderizar cada una de las imágenes cada vez
		#que invocamos la función "Draw". Es un método específico de Gosu
		#que se puede re-escribir. Así conservamos memoria. 
		!@scene_ready || @explosions.any? 
	end

	def draw
		#pinta la imagen de trasfondo (la del campito)
		#llama al método de Explosion::draw a todas
		#las explosiones que hayan en el array.
		@scene_ready ||= true
		@background.draw(0,0,0)
		@explosions.map(&:draw)
	end

end

GameWindow.new.show