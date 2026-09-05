extends FluxTestSuite


const ElementGlyphRendererScript = preload("res://src/presentation/element_glyph_renderer.gd")


func run() -> int:
	var language := VisualLanguage.new()
	check(language.load_from_file(), "visual language loads for shared element glyphs")
	var topology_claims: Dictionary = {}
	for element_id: String in VisualLanguage.REQUIRED_ELEMENTS:
		var contract: Dictionary = ElementGlyphRendererScript.contract(language, element_id)
		check(not contract.is_empty(), "%s has a reusable glyph contract" % element_id)
		equal(String(contract.get("shape", "")), language.element_shape(element_id), "%s glyph uses the central shape token" % element_id)
		equal(String(contract.get("cadence", "")), language.element_cadence(element_id), "%s glyph preserves its motion-cadence token" % element_id)
		var topology := String(contract.get("topology", ""))
		check(not topology_claims.has(topology), "%s remains shape-distinct without relying on color" % element_id)
		topology_claims[topology] = element_id
	equal(topology_claims.size(), VisualLanguage.REQUIRED_ELEMENTS.size(), "all element glyph topologies are unique")
	check(ElementGlyphRendererScript.contract(language, "unknown").is_empty(), "unknown element cannot invent a glyph")
	return finish("element-glyph-renderer")
