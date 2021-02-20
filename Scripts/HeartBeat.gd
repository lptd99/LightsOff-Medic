extends Node

signal resuscitate
signal flatline

export var backgroundBPM = 40
export var backgroundBleedingBPM = 120
export var normalBPM = 50
export var fastBPM = 75
export var criticalBPM = 100
var audioGood = load("res://SoundEffects/good.wav")
var audioTryAgain = load("res://SoundEffects/try-again.wav")
var audioIntro = load("res://SoundEffects/cpr-prompt.wav")
var audioWarnFaster = load("res://SoundEffects/cpr-warn-faster.wav")
var audioWarnFastest = load("res://SoundEffects/cpr-warn-fastest.wav")
var audioWarnFlatline = load("res://SoundEffects/cpr-warn-flatline.wav")
var heartBeating = false
var timesPlayed = 0
var timesPressedCorrectly = 0
var currentBPM = "NONE"
var pressedKey = false
var lastWasMiss = false
var acceptingInput = false

func _ready():
	$NormalBPM.set_wait_time(getHeartBeatDelay(normalBPM))
	$FastBPM.set_wait_time(getHeartBeatDelay(fastBPM))
	$CriticalBPM.set_wait_time(getHeartBeatDelay(criticalBPM))
	$BackgroundBPM.set_wait_time(getHeartBeatDelay(backgroundBPM))

func startHeartBeat(bpm):
	lastWasMiss = false
	heartBeating = false
	timesPlayed = 0
	timesPressedCorrectly = 0
	if currentBPM == "NONE":
		acceptingInput = false
		$MainDoctor.stream = audioIntro
		$MainDoctor.play()
	currentBPM = bpm
	$NormalBPM.stop()
	$FastBPM.stop()
	$CriticalBPM.stop()
	get_parent().dbgPrint("startHeartBeat(bpm) bpm: " + str(bpm))
	match bpm:
		"normal":
			$NormalBPM.start()
		"fast":
			$FastBPM.start()
		"critical":
			$CriticalBPM.start()

func getHeartBeatDelay(bpm):
	return 1.0 / (bpm / 60.0)
	
func _on_HeartRateMonitor_finished():
	pressedKey = false
	heartBeating = false
	if acceptingInput:
		timesPlayed+=1
	get_parent().dbgPrint("_on_HeartRateMonitor_finished()")
	var mistakesLimit = 10
	var successesLimit = 10
#	match currentBPM:
#		"normal":
#			mistakesLimit = 10
#			successesLimit = 10
#		"fast":
#			mistakesLimit = 10
#			successesLimit = 10
#		"critical":
#			mistakesLimit = 10
#			successesLimit = 10
	if timesPlayed - timesPressedCorrectly >= mistakesLimit:
		increaseBPM(currentBPM)
	if timesPressedCorrectly >= successesLimit:
		decreaseBPM(currentBPM)

func _on_BPM_timeout():
	$HeartRateMonitor.play()
	heartBeating = true
	get_parent().dbgPrint("heartBeating")

func _input(event):
	if currentBPM != "NONE" and acceptingInput:
		if Input.is_action_just_pressed("simple_CPR"):
			if pressedKey == false:
				pressedKey = true
				if heartBeating:
					timesPressedCorrectly += 1
					if lastWasMiss:
						lastWasMiss = false
						$MainDoctor.stream = audioGood
						$MainDoctor.play()
				else:
					timesPressedCorrectly -= 1
					lastWasMiss = true
					$MainDoctor.stream = audioTryAgain
					$MainDoctor.play()

func increaseBPM(bpm):
	if bpm == "normal":
		acceptingInput = false
		$MainDoctor.stream = audioWarnFaster
		$MainDoctor.play()
		startHeartBeat("fast")
	elif bpm == "fast":
		acceptingInput = false
		$MainDoctor.stream = audioWarnFastest
		$MainDoctor.play()
		startHeartBeat("critical")
	elif bpm == "critical":
		currentBPM = "NONE"
		$NormalBPM.stop()
		$FastBPM.stop()
		$CriticalBPM.stop()
		$MainDoctor.stream = audioWarnFlatline
		$MainDoctor.play()
		emit_signal("flatline") #lose level

func decreaseBPM(bpm):
	get_parent().dbgPrint("decreaseBPM()")
	if bpm == "critical":
		startHeartBeat("fast")
		get_parent().dbgPrint("decreaseBPM() > \"critical\"")
	elif bpm == "fast":
		startHeartBeat("normal")
		get_parent().dbgPrint("decreaseBPM() > \"fast\"")
	elif bpm == "normal":
		currentBPM = "NONE"
		$NormalBPM.stop()
		$FastBPM.stop()
		$CriticalBPM.stop()
		emit_signal("resuscitate") #win level
		get_parent().dbgPrint("decreaseBPM() > \"normal\"")

func _on_BackgroundBPM_timeout():
	$BackgroundHeartRateMonitor.play()

func startBackgroundHeartBeat():
	$BackgroundBPM.start()
	$BackgroundBPM.set_wait_time(getHeartBeatDelay(backgroundBPM))
	get_parent().dbgPrint("startBackgroundHeartBeat()")

func stopBackgroundHeartBeat():
	$BackgroundBPM.stop()
	get_parent().dbgPrint("stopBackgroundHeartBeat()")

func setBleedingBackgroundBPM():
	$BackgroundBPM.set_wait_time(getHeartBeatDelay(backgroundBleedingBPM))
	get_parent().dbgPrint("setBleedingBackgroundBPM()")

func unsetBleedingBackgroundBPM():
	$BackgroundBPM.set_wait_time(getHeartBeatDelay(backgroundBPM))
	get_parent().dbgPrint("unsetBleedingBackgroundBPM()")

func _on_MainDoctor_finished():
	if $MainDoctor.stream == audioIntro or $MainDoctor.stream == audioWarnFaster or $MainDoctor.stream == audioWarnFastest:
		acceptingInput = true
		lastWasMiss = true
