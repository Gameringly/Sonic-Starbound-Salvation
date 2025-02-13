class_name R10 extends BossBase

@onready var left_hand: StaticBody2D = $LeftHand
@onready var right_hand: StaticBody2D = $RightHand

enum State {
	IDLE,
	FOLLOW,
	SMASH,
}

enum Hand {
	LEFT,
	RIGHT,
}

var tween: Tween
var player: PhysicsObject = null
var y_origin: float = 0.0
var is_activated: bool = false
var active_hand: Hand = Hand.LEFT
var current_state: State = State.IDLE
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	y_origin = left_hand.global_position.y
	player = Global.players[0]

func _physics_process(delta) -> void:
	if not is_activated and active:
		_activate()
	elif is_activated:
		var hand: StaticBody2D = _get_active_hand()
		match current_state:
			State.FOLLOW:
				hand.global_position.x = \
				  move_toward(hand.global_position.x, player.global_position.x, 6.0)
			State.SMASH:
				hand.global_position = \
				  hand.global_position.move_toward(target_position, 12.0)
				if hand.global_position == target_position:
					current_state = State.IDLE
			_:
				pass

func _activate() -> void:
	is_activated = true
	tween = create_tween()
	var hand: StaticBody2D = _get_active_hand()
	tween.tween_property(hand, "position", hand.position + Vector2(0.0, -128.0), 0.4).set_delay(1.5)
	tween.tween_callback(_set_state.bind(State.FOLLOW)).set_delay(0.2)
	tween.tween_callback(_set_state.bind(State.IDLE)).set_delay(2.0)
	tween.tween_callback(_smash).set_delay(0.4)

func _smash() -> void:
	target_position = Vector2(player.global_position.x, y_origin)
	_set_state(State.SMASH)

func _set_state(state: State) -> void:
	current_state = state

func _get_active_hand() -> StaticBody2D:
	if active_hand == Hand.RIGHT:
		return right_hand
	else:
		return left_hand
