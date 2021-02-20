extends Node

signal sutureClosed
signal patientBleedout

var audioIntro = load("res://SoundEffects/suture-prompt.wav")
var sutureSequence = [KEY_S, KEY_X, KEY_D, KEY_C, KEY_F, KEY_V, KEY_G, KEY_B, KEY_H, KEY_N]
var onScene = false
var pos = 0
export var maxErrors = 3
export var bleedoutTime = 4
var errors = 0
var woundClosed = false
var acceptingInput = false

func _input(event):
	if onScene:
		if event is InputEventKey:
			if event.is_pressed() and not event.is_echo():
				if event.scancode == sutureSequence[pos]:
					pos+=1
					$CorrectSuture.play()
				else:
					errors+=1
					$IncorrectSuture.play()
		if pos >= sutureSequence.size():
			woundClosed = true
			emit_signal("sutureClosed")
			onScene = false
		if errors >= maxErrors:
			emit_signal("patientBleedout")
			onScene = false

func startSuture():
	$BleedoutTimer.set_wait_time(bleedoutTime)
	acceptingInput = false
	$MainDoctor.stream = audioIntro
	$MainDoctor.play()
	onScene = true
	pos = 0
	errors = 0

func _on_BleedoutTimer_timeout():
	if not woundClosed and errors < maxErrors:
		emit_signal("patientBleedout")
		onScene = false


func _on_MainDoctor_finished():
	if $MainDoctor.stream == audioIntro:
		acceptingInput = true
		$BleedoutTimer.start()
