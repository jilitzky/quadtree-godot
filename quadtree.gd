extends Node

## The surface covered by the quadtree
@export var area: Rect2

## The smallest subdivision the quadtree can have
@export var smallest_region = Vector2.ONE

var _root: Region
var _entries: Dictionary

## Adds an element at a given position
func add(element, position):
	if _entries.has(element) or not area.has_point(position):
		return false
	
	_root.add(element, position, smallest_region)
	_entries[element] = position
	return true

## Removes all elements from the tree
func clear():
	_root = Region.new(area.position, area.position + area.size)
	_entries = {}

## Returns the maximum depth of the tree
func get_depth():
	return _root._depth

## Returns the number of elements in the tree
func get_size():
	return _entries.size()

## Returns the nearest element to a given position
func find_nearest(position, max_distance):
	if not area.has_point(position):
		return null
	
	var nearest = [null, max_distance]
	_root.find_nearest(position, nearest)
	return nearest[0];
	
## Removes an element from the tree
func remove(element):
	if not _entries.has(element):
		return false
	
	var position = _entries[element]
	_root.remove(element, position)
	_entries.erase(element)
	return true
	
func _ready():
	clear()
