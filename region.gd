class_name Region
extends RefCounted

var _min: Vector2
var _max: Vector2
var _center: Vector2
var _extents : Vector2
var _depth = 1
var _entries = {}
var _children = [null, null, null, null]
var _child_count = 0

func add(element, position, smallest_region):
	if _child_count == 0:
		assert(not _entries.has(element))
		
		# Set the first element in this level or absorb identical positions
		if _entries.is_empty() or _entries.values().find(position) != -1:
			_entries[element] = position
			return
			
		# If the region can't subdivide further, force add the element at this level		
		if _extents / 2 < smallest_region:
			_entries[element] = position
			return
		
		# Transfer the existing entries to the children
		for existing_element in _entries:
			var existing_position = _entries[existing_element]
			var child = get_or_create_child(existing_position)
			child.add(existing_element, existing_position, smallest_region)
		_entries.clear()
			
	var child = get_or_create_child(position)
	var added = child.add(element, position, smallest_region)
	refresh_depth()

func find_nearest(position, nearest):
	# Do an early out if the position is farther away than the given distance on each axis
	var nearest_distance = nearest[1]
	if position.x < _min.x - nearest_distance or position.x > _max.x + nearest_distance or position.y < _min.y - nearest_distance or position.y > _max.y + nearest_distance:
		return
		
	# If the region has elements, consider them as candidates
	var nearest_distance_sq = nearest_distance * nearest_distance
	for element in _entries:
		var distance_sq = position.distance_squared_to(_entries[element])
		if distance_sq < nearest_distance_sq:
			nearest[0] = element
			nearest[1] = sqrt(distance_sq)
			
	# If the region has children, explore them sorted by their proximity to the query position
	if _child_count > 0:
		var is_right = int(position.x >= _center.x)
		var is_bottom = int(position.y >= _center.y)
		
		var sorted_indices: Array
		sorted_indices.resize(4)
		sorted_indices[0] = is_bottom * 2 + is_right
		sorted_indices[1] = is_bottom * 2 + (1 - is_right)
		sorted_indices[2] = (1 - is_bottom) * 2 + is_right
		sorted_indices[3] = (1 - is_bottom) * 2 + (1 - is_right)
		
		for i in sorted_indices:
			var child = _children[i]
			if child != null:
				child.find_nearest(position, nearest)
	
func get_child_index(position):
	# Child indices follow a Z-order curve
	# 0 = Top-Left
	# 1 = Top-Right
	# 2 = Bottom-Left
	# 3 = Bottom-Right
	var index = 0
	if position.x >= _center.x:
		index += 1
	if position.y >= _center.y:
		index += 2
	return index
	
func get_or_create_child(position):
	var index = get_child_index(position)
	if _children[index] == null:
		var child_min = _min
		var child_max = _max
		
		# Adjust child's position horizontally
		var half_width = _extents.x / 2
		if position.x < _center.x:
			child_max.x -= half_width
		else:
			child_min.x += half_width
		
		# Adjust child's position vertically
		var half_height = _extents.y / 2
		if position.y < _center.y:
			child_max.y -= half_height
		else:
			child_min.y += half_height
		
		_children[index] = Region.new(child_min, child_max)
		_child_count += 1
		
	return _children[index]
	
func is_empty():
	return _entries.is_empty() and _child_count == 0
	
func refresh_depth():
	var max_child_depth = 0
	for child in _children:
		if child != null:
			max_child_depth = max(child._depth, max_child_depth)
	_depth = max_child_depth + 1
	
func remove(element, position):
	# Attempt to remove the element at this level
	if _entries.erase(element):
		return
		
	# Remove the element from the child matching the position
	var index = get_child_index(position)
	var child = _children[index]
	assert(child != null)
	child.remove(element, position)
		
	# Invalidate a child if it's completely empty after a removal
	if child.is_empty():
		_children[index] = null
		_child_count -= 1
	
	# Attempt to merge the last remaining child with the parent
	if _child_count == 1:
		for i in _children.size():
			var remaining_child = _children[i]
			if remaining_child != null:
				if remaining_child._child_count == 0:
					assert(_entries.is_empty())
					_entries.merge(remaining_child._entries)
					_children[i] = null
					_child_count -= 1
				break
	
	refresh_depth()
	
func reset():
	_min = Vector2.ZERO
	_max = Vector2.ZERO
	_center = Vector2.ZERO
	_extents = Vector2.ZERO
	_depth = 1
	_entries.clear()
	_children.fill(null)
	_child_count = 0

func _init(min, max):
	_min = min
	_max = max
	_center = (min + max) / 2
	_extents = max - min
