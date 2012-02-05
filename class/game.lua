require 'class/map.lua'
require 'class/player.lua'

-- A Game handles a collection of rooms
Game = class()

function Game:init()
	self.frameState = 1 -- 0: erase, 1: draw
end

function Game:switch_to_room(roomIndex)
	print('switching to room ' .. roomIndex)

	prevRoom = self.currentRoom

	-- Remove player from previous room
	if prevRoom ~= nil then
		prevRoom:remove_sprite(self.player)
	end

	-- Set the new room as the current room
	self.currentRoom = self.rooms[roomIndex]

	-- Add player to current room
	self.currentRoom:add_sprite(self.player)

	-- Move player to corresponding doorway
	if prevRoom ~= nil then
		exit = self.currentRoom:get_exit({roomIndex = prevRoom.index})
		self.player:move_to(exit:get_doorway())
	end

	-- Make sure room has been generated
	if self.rooms[roomIndex].generated == false then
		self.rooms[roomIndex]:generate()
	end
end

function Game:draw()
	if flickerMode and self.frameState == 0 then
		self.currentRoom:erase()
	else
		self.currentRoom:draw()
	end
end

function Game:generate()
	-- Generate a new map
	mapPath = {}
	self.map = Map()
	self.rooms = self.map:generate()

	-- Create a player
	self.player = Player()

	-- Switch to the first room and put the player at the midPoint
	self:switch_to_room(1)
	self.player:move_to(self.currentRoom.midPoint)

	-- Generate the first room
	--self.currentRoom = self.rooms[1]
	--self.currentRoom:generate()

	-- Put a player in the first room
	--self.player = Player()
	--self.player:move_to(self.currentRoom.midPoint)
	--self.currentRoom:add_sprite(self.player)
end

function Game:input()
	-- Get player's directional input
	if love.keyboard.isDown('w') then
		self.player:step(1)
	elseif love.keyboard.isDown('d') then
		self.player:step(2)
	elseif love.keyboard.isDown('s') then
		self.player:step(3)
	elseif love.keyboard.isDown('a') then
		self.player:step(4)
	end

	-- Get monsters' directional input
	if self.currentRoom ~= nil then
		self.currentRoom:character_input()
	end
end

function Game:keypressed(key)
	-- Get player input for shooting arrows
	shootDir = nil
	if key == 'up' then
		shootDir = 1
	elseif key == 'right' then
		shootDir = 2
	elseif key == 'down' then
		shootDir = 3
	elseif key == 'left' then
		shootDir = 4
	end
	if shootDir ~= nil then
		self.player:shoot(shootDir, self.currentRoom)
	end
end

function Game:update()
	if flickerMode and self.frameState == 0 then
		self.frameState = 1
		return
	else
		self.frameState = 0
	end

	self:input()
	self.currentRoom:update()

	-- Switch rooms when player is on an exit
	for i,e in pairs(self.currentRoom.exits) do
		if tiles_overlap(self.player.position, e) then
			self:switch_to_room(e.roomIndex)
			break
		end
	end
end
