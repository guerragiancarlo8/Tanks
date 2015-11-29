class PlayState < GameState
  attr_accessor :update_interval, :object_pool

  def initialize
    @names = Names.new(
      Utils.media_path('names.txt'))
    @object_pool = ObjectPool.new(Map.bounding_box)
    @map = Map.new(@object_pool)
    @map.spawn_points(15)
    @camera = Camera.new
    @tank = Tank.new(@object_pool,
      PlayerInput.new('Player', @camera, @object_pool))
    @camera.target = @tank
    @object_pool.camera = @camera
    @radar = Radar.new(@object_pool,@tank)
    10.times do |i|
      Tank.new(@object_pool, AiInput.new(
        @names.random, @object_pool))
    end
    puts "Object Pool: #{@object_pool.objects.size}"
    @hud = HUD.new(@object_pool, @tank)
  end

  def update
    StereoSample.cleanup
    @object_pool.update_all
    @camera.update
    @radar.update
    update_caption
    @hud.update
  end

  def draw
    cam_x = @camera.x
    cam_y = @camera.y
    off_x =  $window.width / 2 - cam_x
    off_y =  $window.height / 2 - cam_y
    viewport = @camera.viewport
    x1, x2, y1, y2 = viewport
    box = AxisAlignedBoundingBox.new(
      [x1 + (x2 - x1)/2, y1 + (y2 - y1)/2],
      [x1 - Map::TILE_SIZE, y1 - Map::TILE_SIZE])
    $window.translate(off_x, off_y) do
      zoom = @camera.zoom
      $window.scale(zoom, zoom, cam_x, cam_y) do
        @map.draw(viewport)
        @object_pool.query_range(box).map do |o|
          o.draw(viewport)
        end
      end
    end
    @camera.draw_crosshair
    @radar.draw
    @hud.draw
  end

  def button_down(id)
    if id == Gosu::KbQ
      leave
      $window.close
    end
    if id == Gosu::KbEscape
      pause = PauseState.instance
      pause.play_state = self
      GameState.switch(pause)
    end
    if id == Gosu::KbT
      t = Tank.new(@object_pool,
                    AiInput.new(@object_pool))
      t.x, t.y = @camera.mouse_coords
    end
  end

  def leave
    StereoSample.stop_all
    @hud.active = false
  end

  def enter
    @hud.active = true
  end

  private

  def toggle_profiling
    require 'ruby-prof' unless defined?(RubyProf)
    if @profiling_now
      result = RubyProf.stop
      printer = RubyProf::FlatPrinter.new(result)
      printer.print(STDOUT, min_percent: 0.01)
      @profiling_now = false
    else
      RubyProf.start
      @profiling_now = true
    end
  end

  def update_caption
    now = Gosu.milliseconds
    if now - (@caption_updated_at || 0) > 1000
      $window.caption = 'Tanks Prototype. ' <<
        "[FPS: #{Gosu.fps}. " <<
        "Tank @ #{@tank.x.round}:#{@tank.y.round}]"
      @caption_updated_at = now
    end
  end
end
