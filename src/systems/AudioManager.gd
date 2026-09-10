extends Node
## Procedural sound effects rendered into AudioStreamWAV at startup. Autoload: AudioManager.

const SAMPLE_RATE: int = 22050
const PLAYER_COUNT: int = 4

var _sounds: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0


func _ready() -> void:
	for i: int in PLAYER_COUNT:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		_players.append(player)
	_sounds[&"click"] = _render(0.08, _click)
	_sounds[&"deal"] = _render(0.14, _deal)
	_sounds[&"swipe"] = _render(0.22, _swipe)
	_sounds[&"positive"] = _render(0.32, _positive)
	_sounds[&"negative"] = _render(0.36, _negative)
	_sounds[&"tick"] = _render(0.05, _tick)
	_sounds[&"finish"] = _render(0.9, _finish)
	_sounds[&"fail"] = _render(0.9, _fail)


func play(sound_name: StringName, volume_db: float = -6.0) -> void:
	var stream: AudioStreamWAV = _sounds.get(sound_name) as AudioStreamWAV
	if stream == null:
		return
	var player: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % PLAYER_COUNT
	player.stream = stream
	player.volume_db = volume_db
	player.play()


# ---------------------------------------------------------------- synthesis

func _render(duration: float, generator: Callable) -> AudioStreamWAV:
	var frame_count: int = int(duration * SAMPLE_RATE)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(frame_count * 2)
	for i: int in frame_count:
		var t: float = float(i) / SAMPLE_RATE
		var sample: float = clampf(float(generator.call(t, duration)), -1.0, 1.0)
		bytes.encode_s16(i * 2, int(sample * 32000.0))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream


func _envelope(t: float, duration: float, attack: float = 0.005, release_power: float = 3.0) -> float:
	if t < attack:
		return t / attack
	var progress: float = (t - attack) / maxf(duration - attack, 0.001)
	return pow(1.0 - clampf(progress, 0.0, 1.0), release_power)


func _sine(freq: float, t: float) -> float:
	return sin(TAU * freq * t)


func _noise() -> float:
	return randf() * 2.0 - 1.0


func _click(t: float, duration: float) -> float:
	return _sine(880.0, t) * _envelope(t, duration, 0.002, 4.0) * 0.6


func _tick(t: float, duration: float) -> float:
	return _sine(1320.0, t) * _envelope(t, duration, 0.001, 5.0) * 0.4


func _deal(t: float, duration: float) -> float:
	var body: float = _sine(320.0 - 120.0 * t / duration, t) * 0.5
	var air: float = _noise() * 0.15
	return (body + air) * _envelope(t, duration, 0.004, 2.5)


func _swipe(t: float, duration: float) -> float:
	var progress: float = t / duration
	var sweep: float = _sine(380.0 + 700.0 * progress, t) * 0.35
	var air: float = _noise() * (0.35 * (1.0 - progress))
	return (sweep + air) * _envelope(t, duration, 0.01, 2.0)


func _positive(t: float, duration: float) -> float:
	var half: float = duration * 0.5
	var freq: float = 523.25 if t < half else 659.25
	var local_t: float = t if t < half else t - half
	return (_sine(freq, t) * 0.5 + _sine(freq * 2.0, t) * 0.15) * _envelope(local_t, half, 0.004, 2.5)


func _negative(t: float, duration: float) -> float:
	var half: float = duration * 0.5
	var freq: float = 329.63 if t < half else 246.94
	var local_t: float = t if t < half else t - half
	return (_sine(freq, t) * 0.5 + _sine(freq * 0.5, t) * 0.2) * _envelope(local_t, half, 0.004, 2.0)


func _finish(t: float, duration: float) -> float:
	var notes: Array[float] = [523.25, 659.25, 783.99, 1046.5]
	var step: float = duration / notes.size()
	var index: int = mini(int(t / step), notes.size() - 1)
	var local_t: float = t - index * step
	return (_sine(notes[index], t) * 0.45 + _sine(notes[index] * 2.0, t) * 0.12) * _envelope(local_t, step * 1.4, 0.004, 2.0)


func _fail(t: float, duration: float) -> float:
	var notes: Array[float] = [392.0, 349.23, 311.13, 261.63]
	var step: float = duration / notes.size()
	var index: int = mini(int(t / step), notes.size() - 1)
	var local_t: float = t - index * step
	return (_sine(notes[index], t) * 0.45 + _sine(notes[index] * 0.5, t) * 0.2) * _envelope(local_t, step * 1.4, 0.004, 2.0)
