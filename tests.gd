extends Node2D

func _ready():
	add()
	add_cannot_subdivide()
	add_out_of_bounds()
	add_overlapping()
	find_nearest()
	find_nearest_empty()
	find_nearest_out_of_bounds()	
	find_nearest_single()
	remove()
	remove_not_found()

func add():
	$Quadtree.clear()
	
	#  ______________________
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |______________________|
	
	assert($Quadtree.get_size() == 0)
	assert($Quadtree.get_depth() == 1)
	
	$Quadtree.add($Element1, $Element1.position)
	
	#  ______________________
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |    *                 |
	# |                      |
	# |______________________|
	
	assert($Quadtree.get_size() == 1)
	assert($Quadtree.get_depth() == 1)
	
	$Quadtree.add($Element2, $Element2.position)
	
	#  __________ ___________
	# |          |        *  |
	# |          |           |
	# |          |           |
	# |__________|___________|
	# |          |           |
	# |    *     |           |
	# |          |           |
	# |__________|___________|
	
	assert($Quadtree.get_size() == 2)
	assert($Quadtree.get_depth() == 2)
	
	$Quadtree.add($Element3, $Element3.position)
	
	#  __________ ___________
	# |          |     |  *  |
	# |          |_____|_____|
	# |          | *   |     |
	# |__________|_____|_____|
	# |          |           |
	# |    *     |           |
	# |          |           |
	# |__________|___________|
	
	assert($Quadtree.get_size() == 3)
	assert($Quadtree.get_depth() == 3)
	
	$Quadtree.add($Element4, $Element4.position)
	
	#  __________ ___________
	# |          |     |  *  |
	# |          |_____|_____|
	# |          |_*|__|     |
	# |__________|__|*_|_____|
	# |          |           |
	# |    *     |           |
	# |          |           |
	# |__________|___________|
	
	assert($Quadtree.get_size() == 4)
	assert($Quadtree.get_depth() == 4)
	
func add_cannot_subdivide():
	var previous_area = $Quadtree.area
	
	$Quadtree.area = Rect2(0, 0, 1, 1)
	$Quadtree.clear()
	
	$Quadtree.add('A', Vector2.ZERO)
	
	assert($Quadtree.get_size() == 1)
	assert($Quadtree.get_depth() == 1)
	
	$Quadtree.add('B', Vector2(0.5, 0.5))
	
	assert($Quadtree.get_size() == 2)	
	assert($Quadtree.get_depth() == 1)
	
	$Quadtree.area = previous_area
	
func add_out_of_bounds():
	$Quadtree.clear()
	
	var added = $Quadtree.add('A', Vector2(500, 500))
	assert(not added)
	
	assert($Quadtree.get_size() == 0)
	assert($Quadtree.get_depth() == 1)
	
func add_overlapping():
	$Quadtree.clear()
	
	var position = Vector2(250, 250)
	$Quadtree.add('A', position)
	$Quadtree.add('B', position)
	
	assert($Quadtree.get_size() == 2)
	assert($Quadtree.get_depth() == 1)
	
func find_nearest():
	$Quadtree.clear()
	
	$Quadtree.add($Element1, $Element1.position)
	$Quadtree.add($Element2, $Element2.position)
	$Quadtree.add($Element3, $Element3.position) #<-
	$Quadtree.add($Element4, $Element4.position)
	
	#  __________ ___________
	# |          |     |  *  |
	# |    o     |_____|_____|
	# |          |_*|__|     |
	# |__________|__|*_|_____|
	# |          |           |
	# |    *     |           |
	# |          |           |
	# |__________|___________|
	
	var nearest = $Quadtree.find_nearest(Vector2(125, 125))
	assert(nearest == $Element3)
	
func find_nearest_empty():
	$Quadtree.clear()
	
	var nearest = $Quadtree.find_nearest(Vector2(250, 250))
	assert(nearest == null)
	
func find_nearest_out_of_bounds():
	$Quadtree.clear()
	
	$Quadtree.add($Element1, $Element1.position)
	
	var nearest = $Quadtree.find_nearest(Vector2(500, 500))
	assert(nearest == null)
	
func find_nearest_single():
	$Quadtree.clear()
	
	$Quadtree.add($Element1, $Element1.position)
	
	var nearest = $Quadtree.find_nearest(Vector2(250, 250))
	assert(nearest == $Element1)
	
func remove():
	$Quadtree.clear()

	$Quadtree.add($Element1, $Element1.position)
	$Quadtree.add($Element2, $Element2.position)
	$Quadtree.add($Element3, $Element3.position)
	$Quadtree.add($Element4, $Element4.position)
	
	#  __________ ___________
	# |          |     |  *  |
	# |          |_____|_____|
	# |          |_*|__|     |
	# |__________|__|*_|_____|
	# |          |           |
	# |    *     |           |
	# |          |           |
	# |__________|___________|
	
	assert($Quadtree.get_size() == 4)
	assert($Quadtree.get_depth() == 4)
	
	var removed = $Quadtree.remove($Element4)
	assert(removed)
	
	#  __________ ___________
	# |          |     |  *  |
	# |          |_____|_____|
	# |          | *   |     |
	# |__________|_____|_____|
	# |          |           |
	# |    *     |           |
	# |          |           |
	# |__________|___________|
	
	assert($Quadtree.get_size() == 3)
	assert($Quadtree.get_depth() == 3)
	
	removed = $Quadtree.remove($Element3)
	assert(removed)
	
	#  __________ ___________
	# |          |        *  |
	# |          |           |
	# |          |           |
	# |__________|___________|
	# |          |           |
	# |    *     |           |
	# |          |           |
	# |__________|___________|
	
	assert($Quadtree.get_size() == 2)
	assert($Quadtree.get_depth() == 2)
	
	removed = $Quadtree.remove($Element2)
	assert(removed)
	
	#  ______________________
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |    *                 |
	# |                      |
	# |______________________|
	
	assert($Quadtree.get_size() == 1)
	assert($Quadtree.get_depth() == 1)
	
	removed = $Quadtree.remove($Element1)
	assert(removed)
	
	#  ______________________
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |                      |
	# |______________________|
	
	assert($Quadtree.get_size() == 0)
	assert($Quadtree.get_depth() == 1)

func remove_not_found():
	$Quadtree.clear()
	
	var removed = $Quadtree.remove('A')
	assert(not removed)
