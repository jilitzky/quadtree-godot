class_name Region
extends RefCounted

var _area: Rect2
var _depth = 1
var _entries = {}
var _children = [null, null, null, null]

func add(element, position, smallest_region):
	if get_child_count() == 0:
		assert(not _entries.has(element))
		
		# Set the first element in this level or absorb identical positions
		if _entries.is_empty() or _entries.values().find(position) != -1:
			_entries[element] = position
			return
			
		# If the region can't subdivide further, force add the element at this level		
		if (_area.size / 2 < smallest_region):
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
	var min = _area.position
	var max = _area.position + _area.size
	var nearest_distance = nearest[1]
	if (position.x < min.x - nearest_distance or position.x > max.x + nearest_distance or position.y < min.y - nearest_distance or position.y > max.y + nearest_distance):
		return
		
	# If the region has elements, consider them as candidates
	for element in _entries:
		var distance = position.distance_to(_entries[element])
		if (distance < nearest_distance):
			nearest[0] = element
			nearest[1] = distance
			
	# If the region has children, explore them sorted by their proximity to the query position
	if get_child_count() > 0:
		var center = _area.get_center()
		var is_right = int(position.x >= center.x)
		var is_bottom = int(position.y >= center.y)
		
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

func get_child_count():
	var count = 0
	for child in _children:
		if child != null:
			count += 1
	return count
	
func get_child_index(position):
	# Child indices follow a Z-order curve
	# 0 = Top-Left
	# 1 = Top-Right
	# 2 = Bottom-Left
	# 3 = Bottom-Right
	var index = 0
	var center = _area.get_center()
	if (position.x >= center.x):
		index += 1
	if (position.y >= center.y):
		index += 2
	return index
	
func get_or_create_child(position):
	var index = get_child_index(position)
	if (_children[index] == null):
		var childArea = _area
		childArea.size /= 2
		
		# Adjust the child's position relative to the region's center
		var center = _area.get_center()
		if position.x >= center.x:
			childArea.position.x += childArea.size.x
		if position.y >= center.y:
			childArea.position.y += childArea.size.y
		
		_children[index] = Region.new(childArea)
		
	return _children[index]
	
func is_empty():
	return _entries.is_empty() and get_child_count() == 0
	
func refresh_depth():
	var max_child_depth = 0
	for child in _children:
		if child != null:
			max_child_depth = max(child._depth, max_child_depth)
	_depth = max_child_depth + 1
	
func remove(element, position):
	# Attempt to remove the element at this level
	if (_entries.erase(element)):
		return
		
	# Remove the element from the child matching the position
	var index = get_child_index(position)
	var child = _children[index]
	assert(child != null)
	child.remove(element, position)
		
	# Invalidate a child if it's completely empty after a removal
	if child.is_empty():
		_children[index] = null
	
	# Attempt to merge the last remaining child with the parent
	if (get_child_count() == 1):
		for i in _children.size():
			var remaining_child = _children[i]
			if (remaining_child != null):
				assert(_entries.is_empty())
				_entries.merge(remaining_child._entries)
				_children[i] = null
				break
	
	refresh_depth()
	
func _init(area):
	_area = area
