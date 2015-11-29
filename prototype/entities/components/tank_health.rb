class TankHealth < Component
	attr_accessor :health
	RESPAWN_DELAY = 5000

	def initialize(object, object_pool)
		super(object)
		@object_pool = object_pool
		@health = 100
		@health_updated = true
		@last_damage = Gosu.milliseconds
	end

	def update
		update_image
	end

	def update_image
		if @health_updated
			if dead?
				text = '✝'
				font_size = 25
			else
				text = @health.to_s
				font_size = 18
			end
			@image = Gosu::Image.from_text(
				$window, text, Gosu.default_font_name, font_size)
			@health_updated = false
		end
	end

	def dead?
		@health < 1
	end

	def inflict_damage(amount)
		if @health > 0
			@health_updated = true
			@health = [@health - amount.to_i, 0].max
			if @health < 1
				Explosion.new(@object_pool, x,y)
			end
		end
	end

	def draw(viewport)
		@image.draw(
			x - @image.width/2,
			y - object.graphics.height/2 - 
			@image.height,100)
	end

	def should_respawn?
		Gosu.milliseconds - @death_time > RESPAWN_DELAY
	end

	def after_death
		@death_time = Gosu.milliseconds
	end
end