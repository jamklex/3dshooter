extends Node

const alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
const numbers = ["0","1","2","3","4","5","6","7","8","9"]
const specials = ["!","§","$","%",";",":","&"]

const subjects = [
	"Puppy", "Car", "Rabbit", "Girl", "Monkey", "Astronaut"
]
const verbs = [
	"runs", "hits", "jumps", "drives", "barfs", "thinks", "eats", "bites"
]
const adverbs = [
	"crazily", "dutifully", "foolishly", "merrily", "occasionally", "risky", "safely", "stupidly"
]
const adjectives = [
	"adorable", "clueless", "dirty", "odd", "stupid"
]

func generate(rng: RandomNumberGenerator, withKey: bool = false) -> String:
	var sentence = "%s %s %s %s" % [
		pick(rng, subjects),
		pick(rng, verbs),
		pick(rng, adverbs),
		pick(rng, adjectives)
	]
	if !withKey:
		return sentence
	return "%s - %s" % [generate_key(rng), sentence]

func generate_key(rng: RandomNumberGenerator) -> String:
	var format = "ccncsnnc"
	var result = ""
	for f in format:
		if f == "c":
			result += pick(rng, alphabet)
		if f == "n":
			result += pick(rng, numbers)
		if f == "s":
			result += pick(rng, specials)
	return result

func pick(rng: RandomNumberGenerator, choices: Array) -> String:
	return choices[rng.randi_range(0, choices.size()-1)]
