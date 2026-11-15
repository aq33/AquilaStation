// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define AQ_CACHE_TEST_FOLDER "tmp/aq_spritesheet_cache_test/"

/// Sheet with two icon sizes, cached in its own folder (independent of CACHE_ASSETS); abstract so SSassets skips it
/datum/asset/spritesheet/aq_cache_test
	_abstract = /datum/asset/spritesheet/aq_cache_test
	name = "aq_cache_test"

/datum/asset/spritesheet/aq_cache_test/aq_cache_file(suffix)
	return "[AQ_CACHE_TEST_FOLDER]spritesheet.[name][suffix]"

/datum/asset/spritesheet/aq_cache_test/register()
	InsertAll("stack", 'icons/obj/stack_objects.dmi')
	Insert("big", 'icons/effects/96x96.dmi', "explosion") // second size: 96x96
	return ..()

/// AQUILA: a spritesheet read from the cross-round cache has the same sprites, files and CSS as the built one
/datum/unit_test/aquila_spritesheet_cache

/datum/unit_test/aquila_spritesheet_cache/Run()
	fdel(AQ_CACHE_TEST_FOLDER)
	var/datum/asset/spritesheet/aq_cache_test/built = new
	TEST_ASSERT(!built.aq_cached_files, "The sheet was read from a cache that does not exist")
	TEST_ASSERT(length(built.sizes) == 2, "The test sheet should have two sizes, has [length(built.sizes)]")
	var/datum/asset_cache_item/built_css = SSassets.cache["spritesheet_[built.name].css"]
	var/list/built_sprites = built.sprites.Copy()
	var/list/built_mappings = built.get_url_mappings()
	built.aq_write_cache()

	GLOB.asset_datums -= built.type
	var/datum/asset/spritesheet/aq_cache_test/cached = new
	TEST_ASSERT(length(cached.aq_cached_files) == 2, "The sheet was not read from the cache ([length(cached.aq_cached_files)] files)")
	TEST_ASSERT(!length(cached.sizes), "The cached sheet was built again")
	for(var/sprite_name in built_sprites)
		var/list/a = built_sprites[sprite_name]
		var/list/b = cached.sprites[sprite_name]
		TEST_ASSERT(islist(b) && a[1] == b[1] && a[2] == b[2], "Sprite [sprite_name] differs after the cache: [json_encode(a)] vs [json_encode(b)]")
	TEST_ASSERT(length(cached.sprites) == length(built_sprites), "The cached sheet has [length(cached.sprites)] sprites, the built one [length(built_sprites)]")
	var/list/cached_mappings = cached.get_url_mappings()
	for(var/asset_name in built_mappings)
		TEST_ASSERT(cached_mappings[asset_name] == built_mappings[asset_name], "Asset [asset_name] has another URL after the cache")
	var/datum/asset_cache_item/cached_css = SSassets.cache["spritesheet_[cached.name].css"]
	TEST_ASSERT(cached_css.hash == built_css.hash, "The CSS read from the cache differs from the built one")

	fdel(AQ_CACHE_TEST_FOLDER)
	GLOB.asset_datums -= cached.type

	// md5asfile hashes a file on disk directly, the result must match hashing a copy (the old way)
	var/disk_file = file("tgui/public/tgui.html")
	var/copy_path = "[AQ_CACHE_TEST_FOLDER]copy.html"
	fcopy(disk_file, copy_path)
	TEST_ASSERT(md5asfile(disk_file) == rustg_hash_file(RUSTG_HASH_MD5, copy_path), "md5asfile of a file on disk differs from the hash of its copy")
	fdel(AQ_CACHE_TEST_FOLDER)

#undef AQ_CACHE_TEST_FOLDER
#undef TEST_ASSERT

