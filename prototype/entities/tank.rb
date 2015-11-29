class Tank < GameObject
  SHOOT_DELAY = 500
  attr_accessor :x, :y, :throttle_down, :direction,
    :gun_angle, :sounds, :physics, :graphics, :health

  def initialize(object_pool, input)
    super(object_pool)
    @input = input
    @input.control(self)
    @physics = TankPhysics.new(self, object_pool)
    @sounds = TankSounds.new(self, object_pool)
    @health = TankHealth.new(self, object_pool)
    @graphics = TankGraphics.new(self)
    @direction = rand(0..7) * 45
    @gun_angle = rand(0..360)
  end

  def box
    @physics.box
  end

  def effect?
    false
  end

  def shoot(target_x, target_y)
    if Gosu.milliseconds - (@last_shot || 0) > SHOOT_DELAY
      @last_shot = Gosu.milliseconds
      Bullet.new(object_pool, @x, @y, target_x, target_y).fire(self, 100)
    end
  end

  def can_shoot?
    Gosu.milliseconds - (@last_shot || 0) > SHOOT_DELAY
  end

  def to_s
    "Tank [#{@health.health}@#{@x}:#{@y}@#{@physics.speed.round(2)}px/tick]"
  end

  def on_collision(object)
    return unless object
    #avoid recursion
    if object.class == Tank
      #Inform ai about hit
      object.input.on_collision(object)
    else
      #call only non-tanks
      object.on_collision(self)
    end
    if object.class != Bullet
      @sounds.collide if @physics.speed > 1
    end
  end
end
