class TankHealth < Health
	RESPAWN_DELAY = 5000
	attr_accessor :health

	def initialize(object, object_pool)
		super(object, object_pool, 100, true)
	end

	def should_respawn?
		Gosu.milliseconds - @death_time > RESPAWN_DELAY
	end

	protected

	def draw?
		true
	end

	def after_death(cause)
		object.reset_modifiers
		object.input.stats.add_death
		kill = object != cause ? 1 : -1
		cause.input.stats.add_kill(kill)
		@death_time = Gosu.milliseconds
      Thread.new do
        sleep(rand(0.1..0.3))
        Explosion.new(@object_pool, x, y, cause)
      end
	end
end