class_name DeckBuilder
extends RefCounted
## Builds a round-ordered list of scenario ids drawn from ALL characters.
## Spreads characters evenly and avoids the same character in consecutive rounds.


static func build(scenarios: Array[ScenarioData], count: int, avoid_consecutive: bool, rng: RandomNumberGenerator) -> Array[StringName]:
	var buckets: Dictionary = {}
	for scenario: ScenarioData in scenarios:
		var key: StringName = scenario.character.id if scenario.character != null else &"unknown"
		if not buckets.has(key):
			buckets[key] = [] as Array[ScenarioData]
		(buckets[key] as Array[ScenarioData]).append(scenario)
	for key: StringName in buckets.keys():
		_shuffle(buckets[key], rng)

	var deck: Array[StringName] = []
	var played: Dictionary = {}
	var usage: Dictionary = {}
	var last_character: StringName = &""
	while deck.size() < count:
		var candidate: ScenarioData = _pick_candidate(buckets, played, usage, last_character, avoid_consecutive, rng)
		if candidate == null:
			break
		deck.append(candidate.id)
		played[candidate.id] = true
		last_character = candidate.character.id
		usage[last_character] = int(usage.get(last_character, 0)) + 1
		(buckets[candidate.character.id] as Array[ScenarioData]).erase(candidate)
	return deck


static func _pick_candidate(buckets: Dictionary, played: Dictionary, usage: Dictionary, last_character: StringName, avoid_consecutive: bool, rng: RandomNumberGenerator) -> ScenarioData:
	# Prefer the characters used least so far in this deck so every character gets a turn.
	var best: Array[ScenarioData] = []
	var best_usage: int = 999999
	for key: StringName in buckets.keys():
		if avoid_consecutive and key == last_character and buckets.size() > 1:
			continue
		var eligible: Array[ScenarioData] = []
		for scenario: ScenarioData in buckets[key]:
			if scenario.follows == &"" or played.has(scenario.follows):
				eligible.append(scenario)
		if eligible.is_empty():
			continue
		var used: int = int(usage.get(key, 0))
		if used < best_usage or (used == best_usage and rng.randf() < 0.5):
			best_usage = used
			best = eligible
	if best.is_empty():
		# Relax the consecutive-character rule if nothing else is available.
		if avoid_consecutive and last_character != &"":
			return _pick_candidate(buckets, played, usage, &"", false, rng)
		return null
	return best[rng.randi_range(0, best.size() - 1)]


static func _shuffle(list: Array, rng: RandomNumberGenerator) -> void:
	for i: int in range(list.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Variant = list[i]
		list[i] = list[j]
		list[j] = tmp
