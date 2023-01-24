### ----------------------------------------------------
### Sublib for noise
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------



# Function used to make setting up a noise more pleasant
# NoiseDict is as follow: {"octaves": int, "peroid": int ...}
static func setup_noise(Noise:OpenSimplexNoise,NoiseDict:Dictionary,mapSeed:int):
	Noise.seed = mapSeed
	Noise.octaves = NoiseDict['octaves']
	Noise.period = NoiseDict['period']
	Noise.persistence = NoiseDict['persistence']
	Noise.lacunarity = NoiseDict['lacunarity']
