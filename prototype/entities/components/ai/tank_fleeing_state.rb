class TankFleeingState < TankMotionState
	MAX_FLEE_TIME = 15 * 1000 #15 seconds
	def initialize(object,vision,gun)
		super(object,vision)
		@object = object
		@vision = vision
		@gun = gun
	end

	def enter
		@started_fleeing ||= Gosu.milliseconds
	end
	
	def update
		change_direction if should_change_direction?
		drive
	end

	def change_direction
		closest_powerup = @vision.closest_powerup(
			RepairPowerup, HealthPowerup)
		if closest_powerup
			angle = Utils.angle_between(
				@object.x, @object.y,
				closest_powerup.x, closest_powerup.y)
			@object.physics.x, closest_powerup.y)
			@object.physics.change_direction(
				angle - angle % 45)
		else
			#reverse from enemy
		end
		@changed_direction_at = Gosu.milliseconds
		@will_keep_direction_for = turn_time
	end
		
	def drive_time
		10000
	end

	def can_flee?
		return true unless @started_fleeing
		Gosu.milliseconds - @started_fleeing < MAX_FLEE_TIME
	end

	def turn_time
		rand(300..600)
	end
end
