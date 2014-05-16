-- The nebulae generator is tasked with generating random nebulae for 
-- display in the star background
-- the implementation is heavily based on randomnoise ideas explored here:
-- http://lodev.org/cgtutor/randomnoise.html
-- So many thanks to Lode
--
-- Generating clouds takes time and should be done once on startup not
-- during game time (or worse: during draw operations)
--
-- One should remember that randomseeds that are nearly identically tend
-- tend to produce similiar distributions of numbers
--
-- The nebulator is implemented as a thread as it takes a while to generate
-- even one background. This allows us to generate backgrounds while the 
-- player is in the menu and show a loading bar/play the game without background
-- until it is finished
--


-- load modules needed to run a thread
require 'love.filesystem'
require 'love.image'
require 'love.timer'

local output = love.thread.getChannel("nebulator_output")
local percentage = love.thread.getChannel("nebulator_percentage")
local input = love.thread.getChannel("nebulator_input")

-- define noise parameters locally so that they can used in all nebulator methods
local noiseWidth = 400
local noiseHeight = 400
local noise = {}

-- smooth the noise at a specified position by interpolating
-- over nearby points
local function smoothNoise(x, y)

   -- get fractional part of x and y
   local fractX = x - math.floor(x)
   local fractY = y - math.floor(y)
   
   -- wrap around
   local x1 = (math.floor(x) + noiseWidth) % noiseWidth;
   local y1 = (math.floor(y) + noiseHeight) % noiseHeight;
   
   -- neighbor values
   local x2 = (x1 + noiseWidth - 1) % noiseWidth;
   local y2 = (y1 + noiseHeight - 1) % noiseHeight;

   -- smooth the noise with bilinear interpolation
   local value = 0.0;
   value = value + fractX       * fractY       * noise[x1][y1]
   value = value + fractX       * (1 - fractY) * noise[x1][y2]
   value = value + (1 - fractX) * fractY       * noise[x2][y1]
   value = value + (1 - fractX) * (1 - fractY) * noise[x2][y2]

   return value
end


-- add turbulence at specified position
-- basically mixes everything up by the factor size
-- the larger the size the smoother the end result will seem
local function turbulence(x, y, size)
	local value = 0.0
	local currentSize = size

	while currentSize >= 1 do
		value = value + smoothNoise(x / currentSize, y / currentSize) * currentSize
		currentSize = currentSize / 2
	end

	return(128.0 * value / size)
end

-- (re)fill the noise array
local function initNoise(w, h)
	-- if the size parameters are set use them
	if w ~= nil and h ~= nil then
		noiseWidth = w
		noiseHeight = h
	else
		noiseWidth = 500
		noiseHeight = noiseWidth
	end
	
	-- create noise.
	-- basically a 2d array with values between 0 and 1
	noise= {}
	for i=0,noiseWidth do
		noise[i] = {}
		for j=0,noiseHeight do
			noise[i][j] = math.random(0,10000) / 10000
		end
	end
end


percentage:push(0)

local w = input:pop()
local h = input:pop()
local id = input:pop()

-- randomseeds that are nearly identically tend to produce the same
math.randomseed(id)

initNoise(w, h)

-- create imgData to write into
local imgData = love.image.newImageData( noiseWidth + 1, noiseHeight + 1)

-- number of rifts with general orientation (horizontal/vertical)
local xPeriod = 0 -- number of base lines in x
local yPeriod = 0 -- number of base lines in y

local turbPower = 2 -- 0 = no twists, the higher the more twists
local turbSize = 768 -- initial turbulence size

-- copy the individual pixels into the imageData
for i=1,noiseWidth do
	percentage:push(i/noiseWidth)
	for j=1,noiseHeight do
		local xyValue = i * xPeriod / noiseHeight + j * yPeriod / noiseWidth + turbPower * turbulence(i, j, turbSize) / 256.0
		local sineValue = 256 * math.abs(math.sin(xyValue * 3.14159))
		imgData:setPixel( i, j, sineValue, sineValue, sineValue, 255 )
	end
end

-- pass data and set finished
--local file = love.filesystem.newFile("output.png")
--imgData:encode(file)

output:push(imgData)



