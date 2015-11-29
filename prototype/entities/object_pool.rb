class ObjectPool
  attr_accessor :objects, :map, :camera

  def size
    @objects.size
  end

  def initialize(box)
    @tree = QuadTree.new(box)
    @objects = []
  end

  def add(objects)
    @objects << object
    @tree.insert(object)
  end

  def tree_remove(object)
    @tree.remove(object)
  end

  def tree_insert(object)
    @tree.insert(object)
  end

  def update_all
    @objects.map(&:update)
    @objects.reject! do |o|
      if o.removable?
        @tree.remove(o)
        true
      end
    end
  end

  def nearby(object, max_distance)
    cx, cy = object.location
    hx, hy = cx + max_distance, cy + max_distance
    #fast rough results
    results = @tree.query_range(
      AxisAlignedBoundingBox.new([cx,cy],[hx,hy]))
    results.select do |o|
      o != object &&
      Utils.distance_between(
        o.x, o.y, object.x, object.y) <= max_distance
    end
  end
    
  def query_range(box)
    @tree.query_range(box)
  end
end
