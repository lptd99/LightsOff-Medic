extends Node
var debug = false
var flatlined = false
var bleedingOut = false
var gameIsOver = false
var audioIntro = load("res://SoundEffects/intro.wav")
var audioTestOver = load("res://SoundEffects/test-over.wav")
var audioResuscitate = load("res://SoundEffects/cpr-resuscitate.wav")
var audioFlatline = load("res://SoundEffects/cpr-warn-flatline.wav")
var audioWoundClosed = load("res://SoundEffects/suture-wound-closed.wav")
var audioBleedout = load("res://SoundEffects/suture-bleedout.wav")
var audioHeartMonitorFlatline = load("res://SoundEffects/heart-monitor-flatline.wav")
var delaysUsed = 0

func _ready():
	$Delayer.set_wait_time(10)
	$Delayer.start()

func _on_HeartBeatScene_flatline():
	backgroundBPMFlatline()
	$MainDoctor.stream = audioFlatline
	$MainDoctor.play()

func _on_HeartBeatScene_resuscitate():
	$HeartBeatScene.startBackgroundHeartBeat()
	$MainDoctor.stream = audioResuscitate
	$MainDoctor.play()
	$Delayer.set_wait_time(2)
	$Delayer.start()

func startHeartBeatScene():
	$HeartBeatScene.stopBackgroundHeartBeat()
	$HeartBeatScene.startHeartBeat("normal")
	dbgPrint("startHeartBeatScene()")

func startSutureScene():
	$SutureScene.startSuture()
	$HeartBeatScene.setBleedingBackgroundBPM()
	dbgPrint("startSutureScene()")

func backgroundBPMFlatline():
	$HeartBeatScene.stopBackgroundHeartBeat()
	$HeartBeatScene/HeartRateMonitor.stream = audioHeartMonitorFlatline
	$HeartBeatScene/HeartRateMonitor.play()

func gameOver():
	if not gameIsOver:
		gameIsOver = true
		$MainTimer.set_wait_time(5)

#func _input(event):
#	if not $HeartBeatScene.currentBPM != "NONE" and not $SutureScene.onScene and not gameIsOver:
#		if event is InputEventMouseButton:
#			if event.button_index == BUTTON_LEFT:
#				startHeartBeatScene()
#			elif event.button_index == BUTTON_RIGHT:
#				startSutureScene()

func dbgPrint(msg):
	if debug:
		print(msg)

func _on_SutureScene_patientBleedout():
	backgroundBPMFlatline()
	$MainDoctor.stream = audioBleedout
	$MainDoctor.play()

func _on_SutureScene_sutureClosed():
	$MainDoctor.stream = audioWoundClosed
	$MainDoctor.play()
	$HeartBeatScene.unsetBleedingBackgroundBPM()
	$Delayer.start()

func _on_MainTimer_timeout():
	$HeartBeatScene/HeartRateMonitor.stop()
	exitGame()

func _on_MainDoctor_finished():
	if $MainDoctor.stream == audioFlatline or $MainDoctor.stream == audioBleedout:
		exitGame()
	if $MainDoctor.stream == audioIntro:
		startHeartBeatScene()
	if $MainDoctor.stream == audioTestOver:
		exitGame()

func _on_Delayer_timeout():
	delaysUsed += 1
	match (delaysUsed):
		1:
			$MainDoctor.stream = audioIntro
			$MainDoctor.play()
			$HeartBeatScene.startBackgroundHeartBeat()
			dbgPrint("$HeartBeatScene.startBackgroundHeartBeat()")
			$Delayer.set_wait_time(2)
		2:
			startSutureScene()
		3:
			$MainDoctor.stream = audioTestOver
			$MainDoctor.play()
			
func exitGame():
	$MainTimer.stop()
	$Delayer.stop()
	$HeartBeatScene/HeartRateMonitor.stop()
	$HeartBeatScene/BackgroundHeartRateMonitor.stop()
	$HeartBeatScene/BackgroundBPM.stop()
	$HeartBeatScene/NormalBPM.stop()
	$HeartBeatScene/FastBPM.stop()
	$HeartBeatScene/CriticalBPM.stop()
	$SutureScene/BleedoutTimer.stop()
	get_tree().quit()
	
	
	
	
	
	
	
	
	
	
	
	
	
	