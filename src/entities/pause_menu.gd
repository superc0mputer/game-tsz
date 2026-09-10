class_name PauseMenu
extends Control
## In-game pause overlay. Keeps processing while the tree is paused.

signal resume_pressed
signal save_quit_pressed
signal restart_pressed

@onready var _resume_button: Button = %ResumeButton
@onready var _save_quit_button: Button = %SaveQuitButton
@onready var _restart_button: Button = %RestartButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(func() -> void: resume_pressed.emit())
	_save_quit_button.pressed.connect(func() -> void: save_quit_pressed.emit())
	_restart_button.pressed.connect(func() -> void: restart_pressed.emit())


func open() -> void:
	show()
	_resume_button.grab_focus()


func close() -> void:
	hide()
