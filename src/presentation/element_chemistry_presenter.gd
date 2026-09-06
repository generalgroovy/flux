class_name ElementChemistryPresenter
extends RefCounted

# A bounded immediate-mode kit: no particles, textures, nodes or game rules.
# All occupied geometry comes from authority, including growing/moving shapes.
const ELEMENTS: Array[String] = ["", "earth", "fire", "water", "wind", "ice", "charge", "light", "dark"]
const Glyph = preload("res://src/presentation/element_glyph_renderer.gd")
const INK := Color("16212a")
const LINE_SHAPES: Array[String] = ["corridor", "front", "growing_strip", "pulse_lane", "bands", "reveal_line", "water_path", "frost_path", "branch"]
var language: VisualLanguage

func configure(visual_language: VisualLanguage) -> bool:
	language = visual_language
	return language != null and not language.elements.is_empty()

static func phase_at(state: RefCounted, tick: float) -> String:
	if state == null or not is_finite(tick) or tick < state.created_tick or tick >= state.expiry_tick:
		return "expired"
	if tick < state.active_tick:
		return "forming"
	return "active" if tick < state.decay_tick else "decaying"

static func phase_opacity(state: RefCounted, tick: float) -> float:
	var phase := phase_at(state, tick)
	if phase == "expired":
		return 0.0
	if phase == "forming":
		return 0.35 + 0.65 * clampf((tick - float(state.created_tick)) / maxf(1.0, float(state.active_tick - state.created_tick)), 0.0, 1.0)
	if phase == "decaying":
		return clampf((float(state.expiry_tick) - tick) / maxf(1.0, float(state.expiry_tick - state.decay_tick)), 0.0, 1.0)
	return 1.0

static func geometry(state: RefCounted, recipe: Dictionary) -> Dictionary:
	if state == null or recipe.is_empty() or int(recipe.get("wire_id", -1)) != state.recipe_wire_id:
		return {}
	var direction := Vector2(state.direction_x, state.direction_y).normalized()
	if direction.length_squared() < 0.5:
		direction = Vector2.RIGHT
	var position := Vector2(state.position_x, state.position_y) / 1000.0
	var endpoint := Vector2(state.endpoint_x, state.endpoint_y) / 1000.0
	var radius := maxf(0.0, float(state.radius) / 1000.0)
	var length := maxf(0.0, float(state.length) / 1000.0)
	return {"position": position, "endpoint": endpoint, "direction": direction, "normal": direction.orthogonal(), "radius": radius, "length": length, "inner_radius": length if String(recipe.get("shape", "")) in ["ring","annulus"] else 0.0, "shape": String(recipe.get("shape", "")), "id": String(recipe.get("id", ""))}

static func hail_position(state: RefCounted, tick: float) -> Vector2:
	var start := Vector2(state.position_x,state.position_y)/1000.0
	var end := Vector2(state.endpoint_x,state.endpoint_y)/1000.0
	# One real pulse travels in 450ms, not a decorative string of projectiles.
	var progress := fposmod(maxf(0.0,tick-float(state.active_tick)),54.0)/54.0
	return start.lerp(end,progress)

func draw_deposit(canvas: CanvasItem, deposit: RefCounted, tick: float, reduced_effects: bool = false) -> bool:
	if canvas == null or language == null or deposit == null or not is_finite(tick):
		return false
	var element_wire := int(deposit.element_wire_id)
	if element_wire < 1 or element_wire > 8 or tick < deposit.created_tick or tick >= deposit.expiry_tick:
		return false
	var position := Vector2(deposit.position_x, deposit.position_y) / 1000.0
	var radius := maxf(1.0, float(deposit.radius) / 1000.0)
	var age := (tick - float(deposit.created_tick)) / 120.0
	var remaining := float(deposit.expiry_tick) - tick
	var alpha := clampf(remaining / 36.0, 0.0, 1.0)
	var color := language.element_color(ELEMENTS[element_wire])
	canvas.draw_circle(position, radius, Color(color, 0.09 * alpha))
	canvas.draw_arc(position, radius, 0.0, TAU, 24, Color(color, 0.38 * alpha), 1.0, false)
	var motion := 0.0 if reduced_effects else age
	match element_wire:
		1: # Grounded, stepped stone pillar; no camera-height collision fiction.
			var rock := PackedVector2Array([position+Vector2(-10,6),position+Vector2(-11,-5),position+Vector2(-5,-12),position+Vector2(7,-12),position+Vector2(12,-4),position+Vector2(10,6)])
			canvas.draw_colored_polygon(rock, Color(color, 0.84 * alpha))
			_closed(canvas, rock, Color(INK, alpha), 2.0)
			canvas.draw_line(position+Vector2(-5,-10), position+Vector2(-5,4), Color(color.lightened(0.4),alpha), 2.0)
		2:
			for i: int in range(3):
				var p := position + Vector2(float(i-1)*9.0, sin(motion*6.0+float(i))*2.0)
				var flame := PackedVector2Array([p+Vector2(-5,5),p+Vector2(-3,-4),p+Vector2(0,-12-float(i%2)*5),p+Vector2(5,5)])
				canvas.draw_colored_polygon(flame, Color(color,alpha*0.85))
		3:
			for i: int in range(2):
				var r := 6.0+fposmod(motion*7.0+float(i)*10.0,18.0)
				canvas.draw_arc(position,r,0,TAU,20,Color(color,alpha*0.65),2.0,false)
		4:
			for i: int in range(3):
				canvas.draw_arc(position+Vector2(float(i-1)*3,0),8.0+float(i)*6.0,motion+float(i),motion+float(i)+PI*1.25,12,Color(color,alpha*0.7),2.0,false)
		5:
			for i: int in range(3):
				var p := position+Vector2(float(i-1)*9, float(i%2)*4)
				_diamond(canvas,p,5.0,11.0,Color(color,alpha*0.8))
		6:
			canvas.draw_arc(position,15.0,0,TAU,12,Color(color,alpha*0.4),1.0,false)
			_zigzag(canvas,position+Vector2(-16,0),position+Vector2(16,0),5.0,Color(color,alpha),int(motion*5.0)%2)
		7:
			_star(canvas,position,12.0,Color(color,alpha*0.85),4)
			canvas.draw_arc(position,20.0,0,TAU,24,Color(color,alpha*0.35),1.0,false)
		8:
			canvas.draw_circle(position,12.0,Color(INK,alpha*0.45))
			for i: int in range(2):
				canvas.draw_arc(position,10.0+float(i)*7.0,-motion+float(i)*PI,-motion+float(i)*PI+PI*1.4,16,Color(color,alpha*0.7),2.0,false)
	# One fixed identity rune remains readable in the reduced-effects path.
	Glyph.draw(canvas,language,position+Vector2(0,radius-5.0),ELEMENTS[element_wire],4.0,Color(color,alpha))
	return true

func draw_reaction(canvas: CanvasItem, reaction: RefCounted, recipe: Dictionary, tick: float, reduced_effects: bool = false) -> bool:
	if canvas == null or language == null:
		return false
	var g := geometry(reaction,recipe)
	var opacity := phase_opacity(reaction,tick)
	if g.is_empty() or opacity <= 0.0:
		return false
	var p: Vector2 = g.position
	var end: Vector2 = g.endpoint
	var d: Vector2 = g.direction
	var n: Vector2 = g.normal
	var radius: float = g.radius
	var length: float = g.length
	var shape: String = g.shape
	var id: String = g.id
	var elements: Array = recipe.get("elements", [1,1])
	if elements.size() != 2 or int(elements[0]) not in range(1,9) or int(elements[1]) not in range(1,9):
		return false
	var first := language.element_color(ELEMENTS[int(elements[0])])
	var second := language.element_color(ELEMENTS[int(elements[1])])
	if id == "steam":
		first = Color("becfc7")
		second = Color("dfebdf")
	elif id == "magma":
		first = language.element_color("fire")
		second = first.lightened(0.15)
	var edge := Color(first, opacity*0.88)
	var accent := Color(second, opacity*0.82)
	var fill := Color(first, opacity*0.10)
	var time := 0.0 if reduced_effects else (tick-float(reaction.created_tick))/120.0
	var forming := phase_at(reaction,tick) == "forming"
	# Occupied boundary is always present. Formation uses broken preview edges.
	if shape in ["cover", "plane", "lens"]:
		var a := p-n*length*0.5
		var b := p+n*length*0.5
		canvas.draw_line(a,b,Color(INK,opacity*0.6),radius*2.0+3.0,false)
		canvas.draw_line(a,b,Color(first,opacity*(0.25 if forming else 0.65)),maxf(2.0,radius*2.0),false)
		for i: int in range(5):
			var point := a.lerp(b,float(i)/4.0)
			if id == "fortify":
				canvas.draw_rect(Rect2(point-Vector2(6,7),Vector2(12,14)),accent,false,2.0)
			else:
				_diamond(canvas,point,5.0 if id=="permafrost" else 8.0,radius,accent)
		if id == "permafrost":
			_zigzag(canvas,a,b,5.0,Color(INK,opacity),0)
		elif id == "glacier":
			canvas.draw_line(a-d*radius*0.5,b-d*radius*0.5,edge,3.0,false)
		elif id == "crystal_prism":
			_arrow(canvas,p,d,18.0,accent)
		elif id == "crystal_lens":
			for branch_sign: float in [-1.0,1.0]:
				canvas.draw_line(p,p+d.rotated(branch_sign*PI/12.0)*length,accent,1,false)
	elif shape in ["water_path","frost_path","branch"] and reaction.path_points.size() < 4:
		# No linked source means no invisible imaginary connection. Conductive
		# Flood retains its real local disk; the other two await a linked node.
		if shape == "water_path":
			canvas.draw_circle(p,radius,fill)
			canvas.draw_arc(p,radius,0,TAU,24,edge,2,false)
		Glyph.draw(canvas,language,p,ELEMENTS[int(elements[1])],6.0,accent)
	elif shape in LINE_SHAPES:
		var path := PackedVector2Array([p,end])
		if shape in ["water_path","frost_path","branch"] and reaction.path_points.size() >= 4:
			path = PackedVector2Array()
			for i: int in range(0,reaction.path_points.size()-1,2):
				path.append(Vector2(reaction.path_points[i],reaction.path_points[i+1])/1000.0)
		canvas.draw_polyline(path,fill,maxf(1.0,radius*2.0),false)
		for i: int in range(path.size()-1):
			var a: Vector2 = path[i]
			var b: Vector2 = path[i+1]
			var side := (b-a).normalized().orthogonal()*radius
			canvas.draw_line(a+side,b+side,edge,1.0,false)
			canvas.draw_line(a-side,b-side,edge,1.0,false)
			if id != "hailstream":
				_line_identity(canvas,id,a,b,d,n,radius,time,edge if id == "firestorm" else accent,forming,reduced_effects)
		if id == "hailstream":
			var pulse := hail_position(reaction,tick)
			_diamond(canvas,pulse,6.0,minf(radius,10.0),accent)
			canvas.draw_arc(pulse,minf(radius,14.0),0,TAU,16,accent,1.0,false)
	else:
		if shape in ["ring","annulus"]:
			canvas.draw_arc(p,(radius+length)*0.5,0,TAU,32,fill,maxf(1.0,radius-length),false)
		else:
			canvas.draw_circle(p,radius,fill)
		canvas.draw_arc(p,radius,0,TAU,32,edge,1.0 if forming else 2.0,false)
		_area_identity(canvas,id,p,d,n,radius,length,time,accent,edge,forming,reduced_effects)
	if forming:
		# Four nonflashing ticks separate preview from active matter.
		for axis: Vector2 in [d,n,-d,-n]:
			canvas.draw_line(p+axis*(radius+3.0),p+axis*(radius+7.0),Color(first,opacity),2.0,false)
	return true

func _line_identity(canvas: CanvasItem,id: String,a: Vector2,b: Vector2,d: Vector2,n: Vector2,radius: float,time: float,color: Color,_forming: bool,reduced: bool) -> void:
	var count := 3 if reduced else 5
	for i: int in range(count):
		var progress := float(i+1)/float(count+1)
		var p := a.lerp(b,progress)
		match id:
			"magma":
				_zigzag(canvas,p-n*radius*0.75,p+n*radius*0.75,4.0,color,0)
				_arrow(canvas,p,d,10.0,color)
			"dustfront":
				canvas.draw_arc(p,7, time+float(i),time+float(i)+PI,8,color,2,false)
			"firestorm":
				canvas.draw_colored_polygon(PackedVector2Array([p-n*6,p+d*(11+sin(time*4+float(i))*3),p+n*6]),color)
			"mistcurrent":
				canvas.draw_arc(p,10.0,0,PI,10,Color(color,color.a*0.6),2,false)
			"freeze":
				_diamond(canvas,p,6,10,color)
			"conductive_flood":
				canvas.draw_arc(p,8,0,TAU,12,Color(color,color.a*0.5),1,false)
				_zigzag(canvas,p-d*9,p+d*9,4,color,0)
			"superconduct":
				canvas.draw_line(p-n*radius,p+n*radius,color,2,false)
				canvas.draw_line(a,b,Color(color,color.a*0.6),1,false)
			"plasma_arc":
				_zigzag(canvas,p-d*12,p+d*12,5,color,1)
				canvas.draw_line(p,p+n*14,color,1,false)
			"shadowdraft":
				var offset := sin(time*2+float(i))*radius*0.25
				canvas.draw_line(p+n*(radius+offset),p-n*(radius-offset),Color(color,color.a*0.5),4,false)
			"arcflash":
				_star(canvas,p,5,color,4)
				canvas.draw_line(a,b,color,2,false)

func _area_identity(canvas: CanvasItem,id: String,p: Vector2,d: Vector2,n: Vector2,r: float,length: float,time: float,color: Color,edge: Color,forming: bool,reduced: bool) -> void:
	var count := 3 if reduced else 6
	match id:
		"mud":
			for i: int in range(3):
				canvas.draw_arc(p+n*float(i-1)*r*0.3,r*0.32,0.3,PI*1.3,12,color,2,false)
		"grounding_network":
			for axis: Vector2 in [d,n,-d,-n]:
				canvas.draw_line(p,p+axis*r*0.7,color,2,false)
				canvas.draw_rect(Rect2(p+axis*r*0.7-Vector2(3,3),Vector2(6,6)),color,true)
			canvas.draw_circle(p,5,edge)
		"blightsoil":
			for i: int in range(5):
				var axis := Vector2.from_angle(float(i)*TAU/5.0)
				_zigzag(canvas,p,p+axis*r*0.85,5,color,i%2)
		"conflagration":
			canvas.draw_arc(p,length,0,TAU,32,color,2,false)
			for i: int in range(count):
				var axis := Vector2.from_angle(float(i)*TAU/float(count))
				_arrow(canvas,p+axis*r*0.85,axis,7+sin(time*5)*2,color)
		"steam":
			for i: int in range(count):
				var axis := Vector2.from_angle(float(i)*TAU/float(count)+time*0.12)
				canvas.draw_arc(p+axis*r*0.42,r*0.28,PI,TAU,12,Color("dfebdf",color.a*0.48),2,false)
		"thermal_shock":
			for i: int in range(count):
				var axis := Vector2.from_angle(float(i)*TAU/float(count))
				_zigzag(canvas,p+axis*r*0.2,p+axis*r,5,color,i%2)
		"solar_flare":
			_star(canvas,p,r*(0.35 if forming else 0.7),color,8)
		"cinderveil":
			for i: int in range(count):
				var ember := p+Vector2.from_angle(float(i)*TAU/float(count))*r*0.58
				canvas.draw_rect(Rect2(ember-Vector2(2,2+sin(time*4+float(i))*2),Vector2(4,4)),edge,true)
		"flood":
			for i: int in range(3):
				_arrow(canvas,p+n*float(i-1)*r*0.35+d*sin(time*2)*4,d,r*0.25,color)
		"mirrorwater":
			canvas.draw_arc(p,r*0.65,0,TAU,24,color,1,false)
			_diamond(canvas,p,12,7,color)
			canvas.draw_circle(p,3,edge)
		"blackwater":
			for i: int in range(3):
				canvas.draw_arc(p-d*float(i)*8,r*(0.2+float(i)*0.14),-0.8,0.8,10,color,2,false)
		"vortex":
			canvas.draw_arc(p,length,0,TAU,24,color,1,false)
			for i: int in range(3):
				var angle := time+float(i)*TAU/3.0
				canvas.draw_arc(p,(length+r)*0.5,angle,angle+PI*0.45,12,color,2,false)
				_arrow(canvas,p+Vector2.from_angle(angle+PI*0.45)*(length+r)*0.5,Vector2.from_angle(angle+PI*0.95),7,color)
		"ion_storm":
			for i: int in range(3):
				var point := p+Vector2.from_angle(time*0.3+float(i)*TAU/3.0)*r*0.55
				canvas.draw_circle(point,4,color)
				_zigzag(canvas,p,point,3,edge,i%2)
		"lightbend":
			canvas.draw_polyline(PackedVector2Array([p-d*r,p,p+d.rotated(PI/12.0)*r]),color,2,false)
			canvas.draw_arc(p,r*0.45,d.angle(),d.angle()+PI/12.0,10,edge,2,false)
		"crystal_lens":
			_diamond(canvas,p,6,r,color)
			for sign_value: float in [-1.0,1.0]:
				canvas.draw_line(p,p+d.rotated(sign_value*PI/12.0)*length,edge,1,false)
		"black_ice":
			_diamond(canvas,p,r*0.65,r*0.65,color)
			canvas.draw_line(p-d*r*0.4,p+d*r*0.4,edge,2,false)
			canvas.draw_circle(p-d*r*0.75,4,edge)
		"overload":
			canvas.draw_arc(p,r*(0.2 if forming else 0.75),0,TAU,24,color,3,false)
			for axis: Vector2 in [d,n,-d,-n]:
				_arrow(canvas,p+axis*r*0.7,axis,9,edge)
		"static_shroud":
			for i: int in range(count):
				var axis := Vector2.from_angle(float(i)*TAU/float(count))
				_zigzag(canvas,p+axis*r*0.72,p+axis*r,3,color,i%2)
		"radiance":
			_star(canvas,p,12,color,4)
			canvas.draw_arc(p,r*0.7,0,TAU,32,color,1,false)
		"penumbra":
			canvas.draw_arc(p,r*0.82,-PI*0.5,PI*0.5,20,color,3,false)
			canvas.draw_arc(p,r*0.82,PI*0.5,PI*1.5,20,edge,3,false)
			canvas.draw_line(p-n*r,p+n*r,Color(color,color.a*0.5),1,false)
		"umbral_field":
			for i: int in range(3):
				var rr := r*(0.25+fposmod(time*0.18+float(i)*0.2,0.65))
				canvas.draw_arc(p,rr,0,TAU,24,Color(color,color.a*0.6),1,false)

static func _closed(canvas: CanvasItem,points: PackedVector2Array,color: Color,width: float) -> void:
	var outline := points.duplicate()
	outline.append(points[0])
	canvas.draw_polyline(outline,color,width,false)

static func _diamond(canvas: CanvasItem,p: Vector2,width: float,height: float,color: Color) -> void:
	var points := PackedVector2Array([p+Vector2(0,-height),p+Vector2(width,0),p+Vector2(0,height),p+Vector2(-width,0)])
	canvas.draw_colored_polygon(points,Color(color,color.a*0.25))
	_closed(canvas,points,color,2.0)

static func _arrow(canvas: CanvasItem,p: Vector2,d: Vector2,size: float,color: Color) -> void:
	var n := d.orthogonal()
	canvas.draw_polyline(PackedVector2Array([p-d*size*0.4+n*size*0.45,p+d*size*0.6,p-d*size*0.4-n*size*0.45]),color,2.0,false)

static func _star(canvas: CanvasItem,p: Vector2,radius: float,color: Color,rays: int) -> void:
	for i: int in range(rays):
		var axis := Vector2.from_angle(float(i)*TAU/float(rays))
		canvas.draw_line(p+axis*radius*0.25,p+axis*radius,color,2.0,false)

static func _zigzag(canvas: CanvasItem,a: Vector2,b: Vector2,width: float,color: Color,parity: int) -> void:
	var normal := (b-a).normalized().orthogonal()
	var points := PackedVector2Array([a])
	for i: int in range(1,5):
		points.append(a.lerp(b,float(i)/5.0)+normal*width*(1.0 if (i+parity)%2==0 else -1.0))
	points.append(b)
	canvas.draw_polyline(points,color,2.0,false)
