// Ogólny nośnik cząsteczek z tg (/obj/effect/abstract/particle_holder), wersja uproszczona.
// Atom ma tylko jedno pole particles, więc każdy zestaw cząsteczek siedzi w osobnym nośniku
// pokazywanym przez vis_contents rodzica. Sam nośnik czeka w nullspace, żeby nie wypadał
// z pojemników i nie był podnoszony. Bez PARTICLE_ATTACH_MOB z tg (nikt u nas tego nie używa).

/obj/effect/abstract/particle_holder
	name = "particle holder"
	desc = "Skąd to czytasz? Zgłoś błąd :)"
	anchored = TRUE
	appearance_flags = KEEP_APART | KEEP_TOGETHER | TILE_BOUND | PIXEL_SCALE | LONG_GLIDE
	vis_flags = VIS_INHERIT_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Atom, na którym wyświetlamy cząsteczki
	var/datum/weakref/weak_attached

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	var/atom/movable/parent = loc // turfy też mają vis_contents
	moveToNullspace()
	if(particle_path)
		particles = new particle_path()
	parent.vis_contents += src
	weak_attached = WEAKREF(parent)
	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(parent_deleted))

/obj/effect/abstract/particle_holder/Destroy(force)
	var/atom/movable/attached = weak_attached?.resolve()
	if(attached)
		attached.vis_contents -= src
		UnregisterSignal(attached, COMSIG_PARENT_QDELETING)
	weak_attached = null
	particles = null
	return ..()

/obj/effect/abstract/particle_holder/proc/parent_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)
