@tool # lets you run scripts within the editor:
	#https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html
extends Node3D

@export var x_size = 20
@export var z_size = 20

@export var update = false # update within editor
@export var clear_vert_vis = false 

@onready var mesh = $MeshInstance3D

func _ready():
	generate_terrain()
	
func generate_terrain():
	var arr_mesh:ArrayMesh 
	
	# used to generate geometry
	var st = SurfaceTool.new()
	
	# random generation
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_PERLIN # perlin noises (search this up)
	n.frequency = 0.1 # higher frequency = more detail, repeated patterns
	
	var modifier = 5
	
	# starts the surface tool (constructors in java)
	# the paramater tells you the shape of each entries in the array mesh
		# Mesh.PRIMITIVE_TRIANGLES has a conversion rate of 3 points to a triangle
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# loop through, each x,z entry is a point for the triangle vertices
	for z in range(z_size + 1):
		for x in range(x_size + 1):
			var y = n.get_noise_2d(x, z) * modifier # y position
			
			var uv = Vector2() # uv mapping 
			uv.x = inverse_lerp(0, x_size, x) # return the percentage value of 0 and x_size
			uv.y = inverse_lerp(0, z_size, z) #pretend the y variable is z (x and z are 2 variable)
			st.set_uv(uv)
			
			# create a vertex for the surface tool at the specified
			# x (iter in loop inner)
			# z (iter in loop outer)
			# y specified above
			st.add_vertex(Vector3(x, y, z))
			draw_sphere(Vector3(x,y,z)) # adds a sphere on the corners of the vertices
	
	# draw squares
	var vert = 0 # yheight
	for z in z_size:
		for x in x_size:		
			# create triangles
			st.add_index(vert+0)
			st.add_index(vert+1)
			st.add_index(vert+x_size+1) # why x_size + 1? 
				#because x_size+1 index gets you the index of the next sphere at the beginning 
				# of the next row 
			
			st.add_index(vert+x_size+1) # same logic
			st.add_index(vert+1)
			st.add_index(vert+x_size+2) # same logic
			vert += 1
		vert += 1
	
	st.generate_normals()
	# Finish generating the vertexes, send it to the array
	arr_mesh = st.commit()
	
	# set the mesh's mesh to the array mesh
	mesh.mesh = arr_mesh
	mesh.create_multiple_convex_collisions()
	



func draw_sphere(pos:Vector3):
	# intended to draw sphere markers on the corners of the vertices
	var ins = MeshInstance3D.new()
	mesh.add_child(ins)
	
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	ins.mesh = sphere
	

func _process(delta):
	# not required, just qol for editor
	if (update):
		generate_terrain()
		update = false
	
	# not required, just qol
	if clear_vert_vis:
		for i in mesh.get_children():
			i.free()
		clear_vert_vis = false
