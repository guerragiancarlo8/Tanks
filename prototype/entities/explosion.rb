class Explosion
	FRAME_DELAY = 16.66

	def animation
		@@animation ||=
			Gosu::Image.load_tiles(Game.media_path('explosion.png'),128,128,{:tileable => false})
	end

	def sound
		@@sound ||= Gosu::Sample.new($window, Game.media_path('explosion.mp3'))
	end

	def initialize(x,y)
		sound.play
		@x,@y = x,y
		@current_frame = 0
	end

	def update
		advance_frame
		#@current_frame += 1 if frame_expired?
	end

	def draw
		return if done?
		image = current_frame
		image.draw(
			@x - image.width/2 + 3,
			@y - image.height/2 - 35,
			20)
	end

	def done?
		@done ||= @current_frame >= animation.size
	end

	private

	def advance_frame
		now = Gosu.milliseconds
		delta = now - (@last_frame ||= now)
		if delta > FRAME_DELAY
			@last_frame = now
		end
		@current_frame += (delta/FRAME_DELAY).floor
	end
end
