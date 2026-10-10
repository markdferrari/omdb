import bpy,sys,os,math
from pathlib import Path
from mathutils import Vector,Matrix
root=Path(__file__).resolve().parents[2]
kind=sys.argv[-1]
bpy.ops.wm.read_factory_settings(use_empty=True)
if kind=='spikes':
 bpy.ops.import_scene.gltf(filepath=str(root/'art/environment/kaykit_dungeon/floor_tile_big_spikes.gltf'))
 objects=[o for o in bpy.data.objects if o.type=='MESH' and o.name=='spikes']
elif kind=='anvil':
 bpy.ops.import_scene.fbx(filepath=str(root/'art/hazards/iron_anvil/Iron Anvil.fbx'))
 objects=[o for o in bpy.data.objects if o.type=='MESH']
else:
 path=next((root/'art/hazards/sawblade').rglob('sawdisc.blend'))
 bpy.ops.wm.open_mainfile(filepath=str(path),load_ui=False,use_scripts=False)
 objects=[o for o in bpy.data.objects if o.type=='MESH']
for o in list(bpy.data.objects):
 if o not in objects: bpy.data.objects.remove(o,do_unlink=True)
for o in objects:
 # Bake world transformation and evaluated modifiers; retain only mesh geometry.
 dep=bpy.context.evaluated_depsgraph_get(); ev=o.evaluated_get(dep)
 mesh=bpy.data.meshes.new_from_object(ev,depsgraph=dep)
 mesh.transform(o.matrix_world); o.modifiers.clear(); o.data=mesh; o.matrix_world=Matrix.Identity(4)
coords=[v.co.copy() for o in objects for v in o.data.vertices]
lo=Vector(tuple(min(v[i] for v in coords) for i in range(3))); hi=Vector(tuple(max(v[i] for v in coords) for i in range(3))); dims=hi-lo
if kind=='spikes':
 # Blender Z up; exported Godot Y up. Full cluster normalized to 1m square, .16m high.
 factors=Vector((1/dims.x,1/dims.y,.16/dims.z)); pivot=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
elif kind=='anvil':
 factors=Vector((1.8/max(dims.x,dims.y),)*3); pivot=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
else:
 # Disc source in XY, export in Godot YZ: Blender YZ disc, Blender X axle.
 rot=Matrix.Rotation(math.pi/2,4,'Y')
 for o in objects: o.data.transform(rot)
 coords=[v.co for o in objects for v in o.data.vertices]
 lo=Vector(tuple(min(v[i] for v in coords) for i in range(3))); hi=Vector(tuple(max(v[i] for v in coords) for i in range(3))); dims=hi-lo
 factors=Vector((.12/dims.x,1.7/max(dims.y,dims.z),1.7/max(dims.y,dims.z))); pivot=(lo+hi)/2
metal=bpy.data.materials.new('TrialMetal'); metal.diffuse_color=(.26,.30,.36,1); metal.use_nodes=True
bs=metal.node_tree.nodes.get('Principled BSDF'); bs.inputs['Base Color'].default_value=(.26,.30,.36,1); bs.inputs['Metallic'].default_value=.45; bs.inputs['Roughness'].default_value=.62
for o in objects:
 for v in o.data.vertices: v.co=Vector(tuple((v.co[i]-pivot[i])*factors[i] for i in range(3)))
 o.data.materials.clear(); o.data.materials.append(metal)
 for p in o.data.polygons: p.material_index=0
 o.select_set(True)
bpy.context.view_layer.objects.active=objects[0]
source={'spikes':'art/hazards/spikes/spikes.blend','anvil':'art/hazards/iron_anvil/anvil.blend','saw':'art/hazards/sawblade/sawblade.blend'}[kind]
runtime={'spikes':'assets/art/kaykit_dungeon/spike_cluster.glb','anvil':'assets/art/iron_anvil/anvil.glb','saw':'assets/art/sawblade/sawblade.glb'}[kind]
bpy.context.preferences.filepaths.file_preview_type = 'NONE'
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=str(root/source))
bpy.ops.export_scene.gltf(filepath=str(root/runtime),export_format='GLB',use_selection=True,export_animations=False,export_cameras=False,export_lights=False)
print('OMDB_EXPORT_COMPLETE',kind,flush=True)
# Blender's legacy shutdown can hang on this host; outputs above are finalized synchronously.
os._exit(0)
