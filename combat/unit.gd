class_name Unit extends Resource

@export var unit_type : String
@export var name_origin : String
@export var evil_last_name : bool
@export var has_last_name : bool
@export var portrait : Texture2D
@export var tags : Array[String] = []
@export var preferences : Array[PlacementPreference] = []
@export var is_female : bool
@export var cost : int

enum Currency {
	Gold,
	Pacts
}

@export var cost_currency : Currency = Currency.Gold

@export_group("Stats")
@export var max_health : int
@export var armour : float
@export var resist : float
@export var movement_cooldown : int

@export_group("Melee")
@export var melee_damage : int
@export var melee_is_magic : bool
@export var melee_attack_cooldown : int
@export var reach : int

@export_group("Ranged")
@export var ranged_damage : int
@export var ranged_is_magic : bool
@export var ranged_attack_cooldown : int
@export var attack_range : int

var names_by_origin : Dictionary = {
	"german_male": [
		"Albrecht", "Alex", "Arnulf", "Berchtold", "Bertram", "Caspar", "Conrad",
		"Diterich", "Eckehard", "Erasmus", "Fabian", "Friderch", "Georg", "Gerhard",
		"Goswin", "Gregor", "Gündel", "Heinrich", "Herman", "Hieronymus", "Horst",
		"Hugo", "Jacob", "Johannes", "Lamprecht", "Ludwig", "Lukas", "Martin",
		"Mathias", "Melchior", "Nicolaus", "Oswald", "Paul", "Peter", "Philipp",
		"Reinhard", "Rüdeger", "Sigfrid", "Sigmund", "Steffan", "Thadeus", "Thomas",
		"Ulrich", "Urban", "Volkmar", "Warmund", "Wernher", "Wilhelm", "Wikman",
		"Wolfgang", "Zobeslaus"
	],
	"german_female": [
		"Agnise", "Anna", "Beatke", "Benedicta", "Cecilia", "Christine", "Clare",
		"Dorothye", "Elzebeth", "Gertrude", "Hedwig", "Helena", "Hildegard", "Jutte",
		"Katherine", "Lucie", "Magdalena", "Margarthe", "Marie", "Osanna", "Ottilie",
		"Sophie", "Ursula", "Veronica"
	],
	"english_male": [
		"Aldus", "Elric", "Hamon", "Harry", "Hopkin", "Hudde", "Ilbert", "Jack",
		"Jordan", "Larkin", "Laurence", "Mack", "Morris", "Nicol", "Pate", "Ranulf",
		"Wilkins", "Wymond"
	],
	"english_female": [
		"Aldith", "Amice", "Amphelice", "Dye", "Eda", "Etheldred", "Jocosa", "Malle",
		"Matty", "Martha", "Meggy", "Molle", "Rose"
	],
	"italian_male": [
		"Arlotto", "Bonaccorso", "Bonizzone", "Ermo", "Petruccio", "Adamo", "Adelmo",
		"Adone", "Alfonso", "Alfredo", "Benigno", "Benito", "Biaggio", "Cesare",
		"Diego", "Edmondo", "Faustino", "Fabrizio", "Maurizio", "Gaspare", "Luigi",
		"Giovanni", "Giraldo", "Giuseppe", "Leonardo", "Nico", "Orlando", "Oscar",
		"Piero", "Manuele", "Matteo", "Mercurio", "Melchiorre", "Umberto", "Valerio",
		"Vito"
	],
	"italian_female": [
		"Adele", "Agostina", "Alessandra", "Alessia", "Alfonsa", "Amelia", "Aurelia",
		"Bartolomea", "Benedetta", "Bianca", "Celeste", "Cladia", "Cornelia",
		"Concetta", "Delfina", "Desdemona", "Donata", "Doretta", "Elsa", "Gemma",
		"Fracesca", "Giorgina", "Giulietta", "Isabella", "Leonora"
	],
	"french_male": [
		"Jehan", "Guillaume", "Pierre", "Colin", "Jaquet", "Estienne", "Robin",
		"Perrin", "Regnault", "Gillet", "Henry", "Philippe", "Nicolas", "Simon",
		"Jaques", "Loys", "Michiel", "Gieffroy", "Martin", "Noel", "Arnould",
		"Bernard", "Hugues", "Lambert"
	],
	"french_female": [
		"Jehanne", "Gillette", "Marguerite", "Collete", "Margot", "Marie", "Marion",
		"Nicole", "Ysabel", "Perrette", "Isabel"
	],
	"arab_male": [
		"Amate", "Aldara", "Abrahen", "Brahen", "Darras", "Farraj", "Galib",
		"Garsiyya", "Hamet", "Hazm", "Jalid", "Jawar", "Mahomad", "Nayar"
	],
	"arab_female": [
		"Dhana", "Durr", "Amat", "Fathuna", "Fatyan", "Gaya", "Halawa", "Hulla",
		"Safya", "Satara", "Muzna", "Wallada"
	],
	"korean_male": [
		"Byeong Ho", "Dae Jung", "Dae Seong", "Eun", "Gyeong", "Ha Joon", "Hyeon",
		"Jeong", "Jeong Hun", "Joon", "Min Jun", "Myeong", "Sang Hun", "Seok",
		"Seok Jin", "Seong Hun", "Seong Jin", "Seong Su", "Sun", "Woo Jin",
		"Yeong Hwan"
	],
	"korean_female": [
		"Bora", "Duri", "Eun", "Eun Young", "Gyeong Ja", "Hana", "Ha Yoon", "Hyun",
		"Jae", "Ji Min", "Jong", "Jung Hee", "Jung Sook", "Min", "Min Ji", "Min Suk",
		"Nari", "Sang", "Soo Jin", "Sung", "Young Ja"
	],
	"fae_male": [
		"Araenel", "Arsene", "Elariel", "Elathael", "Fangael", "Finae", "Lorethael",
		"Lathoric", "Maele", "Malael", "Narael", "Malic", "Finic", "Aric", "Raele",
		"Rathoric", "Ranae", "Varic", "Varael"
	],
	"fae_female": [
		"Araenei", "Arseni", "Elaria", "Elthaer", "Fangaer", "Finar", "Lotethi",
		"Lathori", "Maei", "Malaer", "Naraer", "Mali", "Fini", "Ari", "Raer",
		"Rathoria", "Ranaea", "Varia", "Varaer"
	],
	"tree": [
		"Birch", "Bark", "Oak", "Branch", "Root", "Ash", "Acorn", "Autumn", "Spring"
	],
	"troll": [
		"Bubith", "Buob", "Buroc", "Borbas", "Boatmur", "Bolth", "Boras", "Bunish"
	],
	"lore_master": [
		"Bartolemeo", "Andronicus", "Faust", "Melchiorre", "Lamprecht"
	],
	"imp": [
		"Whimsicus", "Mischefus", "Trixus", "Hootus", "Goofsicus", "Hijinx", "Jinx",
		"Parodicus", "Jokes", "Daniel"
	],
	"jailor": [
		"Despair", "Desparation", "Hopelessness", "Defeat", "Forlorn", "Isolation",
		"Fear"
	],
	"d_warr": [
		"Violence", "Killfrenzy", "Bloodataur", "Goreforge", "Hatred", "Deathdealer",
		"Bloodthirst", "Lifedrinker", "Hatemonger", "Rendflesh", "Meatcrusher",
		"Vengeance", "Bloodwine", "Warorder", "Battleborn", "Skullcrush"
	],
	"succ": [
		"Lilith", "Lustina", "Lust", "Sexica", "Liliam", "Joy", "Calliope",
		"Desdemona", "Deirdre", "Delilah", "Cunilina"
	],
	"dog": [
		"Rex", "Bruce", "Snowball", "Coco", "Charlie", "Cooper", "Bear", "Beau",
		"Daisy", "Fitz", "Baloo", "Carter", "Moxie"
	]
}

var last_name_prefix : Array[String] = [
	"Red",
	"Green",
	"Blue",
	"Black",
	"White",
	"Swift",
	"Strong",
	"Dog",
	"Cat",
	"Horse",
	"Raven",
	"Grey",
	"Gold",
	"Silver",
	"Iron"
]

var last_name_suffix : Array[String] = [
	"field",
	"tree",
	"hilt",
	"sword",
	"bow",
	"axe",
	"price",
	"rider",
	"hand",
	"hawk",
	"castle",
	"ridge",
	"vow",
	"heart",
	"stone",
	"hart",
	"helm",
	"wood",
	"fist",
]

var evil_last_name_prefox : Array[String] = [
	"Death",
	"Dark",
	"Shadow",
	"Blood",
	"Night",
	"Vile",
	"Evil",
	"Ebony",
	"Doom"
]

var evil_last_name_suffix : Array[String] = [
	"slayer",
	"destroyer",
	"bane",
	"doom",
	"malice",
	"tyrant",
	"chain",
	"spike",
	"spite",
	"murder",
]

func generate_name() -> String:
	var first_name = names_by_origin[name_origin].pick_random()
	var last_name = ""

	if not has_last_name:
		return first_name

	if evil_last_name:
		last_name = [last_name_prefix.pick_random(), evil_last_name_prefox.pick_random()].pick_random() + \
		[evil_last_name_suffix.pick_random(), last_name_suffix.pick_random()].pick_random()
	else:
		last_name = last_name_prefix.pick_random() + last_name_suffix.pick_random()

	return first_name + " " + last_name
