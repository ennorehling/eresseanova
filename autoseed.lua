local table_dump = require('tabledump')
local tiles = {}

function tiles_add(x,y,r)
	if not tiles[y] then tiles[y] = {} end
	tiles[y][x] = r
end

function tiles_get(x,y)
	if not tiles[y] then return nil end
	return tiles[y][x]
end

local tile7 = {
	xof = { x = 3, y = -1 },
	yof = { x = 1, y = 2 },
	length = 2,
	hexes = {
		{ x = 0, y = 0 },
		{ x = -1, y = 0 },
		{ x = -1, y = 1 },
		{ x = 0, y = 1 },
		{ x = 1, y = 0 },
		{ x = 1, y = -1 },
		{ x = 0, y = -1 }
	}
}

local tile19 = {
	xof = { x = 5, y = -2 },
	yof = { x = 2, y = 3 },
	length = 3,
	hexes = {
		{ x = 0, y = 0 },

		{ x = -1, y = 0 },
		{ x = -1, y = 1 },
		{ x = 0, y = 1 },
		{ x = 1, y = 0 },
		{ x = 1, y = -1 },
		{ x = 0, y = -1 },

		{ x = -2, y = 0 },
		{ x = -2, y = 1 },
		{ x = -2, y = 2 },
		{ x = -1, y = 2 },
		{ x = 0, y = 2 },
		{ x = 1, y = 1 },
		{ x = 2, y = 0 },
		{ x = 2, y = -1 },
		{ x = 2, y = -2 },
		{ x = 1, y = -2 },
		{ x = 0, y = -2 },
		{ x = -1, y = -1 }
	}
}

local terrains = {
	'Ebene',
	'Gletscher',
	'Berge',
	'Hochland',
	'Wueste',
	'Sumpf',
	'Ozean',
	'Ozean',
}

function print_tile(x, y, tile, def, edge)
	if tile then
		local rx = x * def.xof.x + y * def.yof.x
		local ry = x * def.xof.y + y * def.yof.y
		local size = #def.hexes
		local estart = size + 1 - 6 * (def.length - 1)
		local ebegin = size + 1 - edge * (def.length - 1) -- ocean edge starts here
		local eend = ebegin + def.length
		-- io.stderr:write(string.format("%d, %d edge %d\n", x, y, estart))
		for i, hex in ipairs(def.hexes) do
			local dx = rx + hex.x
			local dy = ry + hex.y
			print('REGION ' .. dx .. ' ' .. dy)
			local terrain = tile.terrain
			if tile.terrain ~= 'Ozean' then
				if (edge == 1 and i == estart) or (i >= ebegin and i < eend) then
					terrain = 'Ozean'
				elseif hex.x ~= 0 or hex.y ~= 0 then
					local r = math.random(1, #terrains)
					terrain = terrains[r]
				else
					terrain = 'Ebene'
				end
			end
			print('"' .. terrain .. '";Terrain')
		end
	end
end

function find_tile(min_turn)
	local avail = {}
	for y, row in pairs(tiles) do
		for x, tile in pairs(row) do
			for e = 2, 7 do
				local tx = x + tile7.hexes[e].x
				local ty = y + tile7.hexes[e].y
				local n = tiles_get(tx, ty)
				if not n then
					local key = string.format('%d,%d', tx, ty)
					local match = avail[key]
					if not match then
						match = {
							x = tx,
							y = ty
						}
					end
					match.nb = (match.nb or 0) + 1
					local turn = tile.turn
					if (not match.turn) or turn < match.turn then
						match.turn = turn
					end
					avail[key] = match
				end
			end
		end
	end
	local choices = {}
	local first
	for _, match in pairs(avail) do
		if (match.turn or 0) >= min_turn then
			table.insert(choices, match)
			if not first or match.turn < first then
				first = match.turn
			end
		end
	end
	for _, choice in ipairs(choices) do
		if first == choice.turn then
			return choice
		end
	end
	return nil
end

function build()
	for turn = 1, 20 do
		local t = 'Ebene'
		choice = find_tile(turn - 5)
		tiles_add(choice.x, choice.y, {
			terrain = 'Ozean',
			turn = turn
		})
		choice = find_tile(turn - 5)
		tiles_add(choice.x, choice.y, {
			terrain = 'Ebene',
			turn = turn
		})
	end
end

function report(def)
	print('VERSION 68')
	print('"Eressea";Spiel')
	print('1;Runde')
	print('PARTEI 1')
	print('"Les Maîtres Du Temps";Parteiname')
	print('"enno@eressea.de";email')
	for y, v in pairs(tiles) do
		for x, tile in pairs(v) do
			local edge = math.random(1, 6)
			print_tile(x, y, tile, def, edge)
		end
	end
end

tiles_add(0, 0, {
	terrain = 'Ebene',
	turn = 0
})
build()
report(tile19)
