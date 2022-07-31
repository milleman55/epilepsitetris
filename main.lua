--[[
Copyright (c) 2016-2022 Mauritz Sverredal

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
]]--

function refreshBag()
	bag = {}
	for i = 1, 7 do
		bag[i] = i
	end
	for i = 1, 7 do
		local r = love.math.random(i, 7)
		bag[i], bag[r] = bag[r], bag[i]
	end
	return bag
end
function lockPiece(piece)
    for _,s in pairs(piece.squares) do
        field[s.x][s.y] = s
    end
end
function getPiece()
    currentPiece = makePiece(nextPiece, false)
    nextPiece = bag[1]
	if #bag == 1 then
		refreshBag()
	else
		table.remove(bag, 1)
	end
    t = 0
    for _,s in pairs(currentPiece.squares) do
        if field[s.x][s.y].color > 0 then
            gameOver = true
            if musicEnabled then
                TETRIS:stop() -- Stop music
            end
            return
        end
    end
end
function newGame() -- (re)sets the game state
    score = 0
    showScore = true -- Show score on screen

    t = 0 --Reset time

    gameOver = false

    hasHeld = false
    heldPiece = {
        squares = {}
    } -- No held piece

    shadowBorder = 0.05 -- As part of square size
    cornerRadius = 0.3 -- As part of square size

    field = {
        width = 10,
        height = 20,
    } -- Dimensions of playing field

    for i = 1, field.width do
        field[i] = {} -- Columns
        for _ = 1, field.height + 3 do
            -- Fill field, and a margin of 3 rows above with empty squares
            table.insert(field[i], {color = 0, type = "empty"})
        end
    end
	refreshBag()
    nextPiece = bag[1] -- Get first piece from bag
	if #bag == 1 then
		refreshBag()
	else
		table.remove(bag, 1)
	end
    getPiece() -- Create the piece
    updateShadow()
    if musicEnabled then
        love.audio.play(TETRIS) -- Restart music
    end
end
function movePiece(piece, x, y)
    for _,s in pairs(piece.squares) do
        if s.y - y < 1 or s.x + x < 1 or s.x + x > field.width or field[s.x + x][s.y - y].type == "normal" or field[s.x][s.y].type == "normal" then
            return true
        end
    end
    for _,s in pairs(piece.squares) do
        s.y = s.y - y
        s.x = s.x + x
    end
    piece.rotatePointY = currentPiece.rotatePointY - y
    piece.rotatePointX = currentPiece.rotatePointX + x
    return false
end
function setSquareSize()
	local width = field.width
	local height = field.height
	if showScore then
		width = width + 8
	end
	squareSize = math.floor(math.min(
		love.graphics.getHeight() / height,
		love.graphics.getWidth() / width
	))
end
function squareWindow()
	setSquareSize()
	local width = field.width
	local height = field.height
	if showScore then
		width = width + 8
	end
	love.window.updateMode(width*squareSize, height*squareSize)
    text1x = love.graphics.newFont(squareSize)
    text2x = love.graphics.newFont(squareSize * 2)
end
function makePiece(id, isShadow)
    local piece = {}
    piece.squares = {}
    for i, s in ipairs(pieces[id]) do
        piece.squares[i] = {}
        piece.squares[i].y = s.y + field.height - 2
        piece.squares[i].x = s.x + math.ceil(field.width / 2) - 2
        piece.squares[i].color = pieces[id].color
        piece.squares[i].shape = s.shape
        piece.squares[i].rotation = s.rotation
        if isShadow then
            piece.squares[i].type = "shadow"
        else
            piece.squares[i].type = "normal"
        end
    end
    piece.rotatePointY = field.height - 2 + pieces[id].rotateY
    piece.rotatePointX = math.ceil(field.width / 2) - 2 + pieces[id].rotateX
    piece.color = pieces[id].color
    piece.id = id
    return(piece)
end
function copyPiece(piece)
	-- Creates a copy of a piece, since Lua tables are always passed by reference
	local newPiece = {}
	newPiece.squares = {}
	for i, s in ipairs(piece.squares) do
		newPiece.squares[i] = {
			x = s.x,
			y = s.y,
			color = s.color,
			shape = s.shape,
			rotation = s.rotation,
			type = s.type
		}
	end
	newPiece.rotatePointX = piece.rotatePointX
	newPiece.rotatePointY = piece.rotatePointY
	newPiece.color = piece.color
	newPiece.id = piece.id
	return newPiece
end
function love.load()
    pieces = { -- The different tetrominoes
        {{x=1, y=2, shape="end", rotation=0}, {x=2, y=1, shape="end", rotation=1}, {x=2, y=2, shape="full", rotation=0}, {x=3, y=2, shape="end", rotation=2}, color = 1, rotateX = 2, rotateY = 2}, -- T Piece
        {{x=1, y=2, shape="end", rotation=0}, {x=2, y=2, shape="full", rotation=0}, {x=3, y=2, shape="full", rotation=0}, {x=4, y=2, shape="end", rotation=2}, color = 2, rotateX = 2.5, rotateY = 2.5}, -- Line Piece
        {{x=2, y=1, shape="corner", rotation=0}, {x=3, y=1, shape="corner", rotation=1}, {x=2, y=2, shape="corner", rotation=3}, {x=3, y=2, shape="corner", rotation=2}, color = 3, rotateX = 2.5, rotateY = 1.5}, -- Square Piece
        {{x=1, y=2, shape="end", rotation=0}, {x=2, y=2, shape="full", rotation=0}, {x=3, y=2, shape="corner", rotation=2}, {x=3, y=1, shape="end", rotation=1}, color = 4, rotateX = 2, rotateY = 2}, -- J Piece
        {{x=1, y=1, shape="end", rotation=1}, {x=2, y=2, shape="full", rotation=0}, {x=1, y=2, shape="corner", rotation=3}, {x=3, y=2, shape="end", rotation=2}, color = 5, rotateX = 2, rotateY = 2}, -- L Piece
        {{x=2, y=2, shape="corner", rotation=2}, {x=2, y=1, shape="corner", rotation=0}, {x=1, y=2, shape="end", rotation=0}, {x=3, y=1, shape="end", rotation=2}, color = 6, rotateX = 2, rotateY = 2}, -- Z Piece
        {{x=2, y=2, shape="corner", rotation=3}, {x=2, y=1, shape="corner", rotation=1}, {x=1, y=1, shape="end", rotation=0}, {x=3, y=2, shape="end", rotation=2}, color = 7, rotateX = 2, rotateY = 2}, -- S Piece
    }
    pieceColors = { -- The piece colors
        {love.math.random(50, 100)/100, love.math.random(0,50)/100, love.math.random(50, 100)/100},
        {love.math.random(25,75)/100, love.math.random(38,88)/100, love.math.random(50,100)/100},
        {love.math.random(50,100)/100,   love.math.random(50,100)/100, love.math.random(0,50)/100},
        {love.math.random(0,50)/100, love.math.random(0,50)/100, love.math.random(50,100)/100},
        {love.math.random(50, 100)/100,   love.math.random(25,100)/100, love.math.random(0,50)/100   },
        {love.math.random(50, 100)/100,   love.math.random(0,50)/100,     love.math.random(0,50)/100   },
        {love.math.random(0,50)/100,   love.math.random(50, 100)/100,     love.math.random(0,50)/100   }}
    if love.filesystem.getInfo("tetris.ogg") then
        musicEnabled = true
        TETRIS = love.audio.newSource("tetris.ogg", "stream") -- Load music file
        volume = 0.17
        love.audio.setVolume(volume)
        TETRIS:setLooping(true)
    else
        musicEnabled = false
    end
    love.window.setTitle("Tetris!")
	love.window.setMode(
		love.graphics.getWidth(),
		love.graphics.getHeight(),
		{resizable=true, vsync=true, msaa=16, minwidth=50, minheight=50}
	)
    love.graphics.setBackgroundColor(1/4, 1/4, 1/4)
    gamePaused = false
    newGame()
    squareWindow() -- Fix window size and aspect ratio
end
function love.resize()
	setSquareSize()
    text1x = love.graphics.newFont(squareSize)
    text2x = love.graphics.newFont(squareSize * 2)
end
function makeRotatedPiece(piece, direction)
	local rotatedPiece = copyPiece(piece)
	for _, s in pairs(rotatedPiece.squares) do
		local storedX = s.x
		local storedY = s.y
		s.x = -direction*(storedY - rotatedPiece.rotatePointY) + rotatedPiece.rotatePointX
		s.y = direction*(storedX - rotatedPiece.rotatePointX) + rotatedPiece.rotatePointY
		s.rotation = (s.rotation + direction) % 4
	end
	return rotatedPiece
end
function rotateCurrentPiece(direction)
	local rotatedPiece = makeRotatedPiece(currentPiece, direction)
	canSpin = true
	for _, s in pairs(rotatedPiece.squares) do
		if
			s.x < 1
			or s.x > field.width
			or s.y < 1
			or field[s.x][s.y].type == "normal"
		then
			canSpin = false
		end
	end
	if canSpin then
		currentPiece = rotatedPiece
		updateShadow()
	end
end
function love.keypressed(key)
    if gameOver == false and gamePaused == false then
        if key == "left" then
            movePiece(currentPiece, -1, 0)
            updateShadow()
        elseif key == "right" then
            movePiece(currentPiece, 1, 0)
            updateShadow()
        elseif key == "space" then
            if not hasHeld then
                local id = currentPiece.id
                if #heldPiece.squares > 0 then
                    currentPiece = makePiece(heldPiece.id, false)
                    heldPiece = makePiece(id)
                else
                    heldPiece = makePiece(id)
                    getPiece()
                end
                for _,s in pairs(currentPiece.squares) do
                    if field[s.x][s.y].color > 0 then
                        gameOver = true
                        if musicEnabled then
                            TETRIS:stop()
                        end
                        return
                    end
                end
                updateShadow()
                hasHeld = true
            end
        elseif key == "up" then
            while movePiece(currentPiece, 0, 1) == false do score = score + 1 end
            lockPiece(currentPiece)
            checkLines()
            getPiece()
            updateShadow()
            hasHeld = false
        elseif key == "z" then
            rotateCurrentPiece(1)
        elseif key == "x" then 
            rotateCurrentPiece(-1)
        end
    end
    if key == "s" then
        showScore = not showScore
    elseif key == "m" then
        if musicEnabled then
            volume = volume - 2 * volume + 0.17
            love.audio.setVolume(volume)
        end
    elseif key == "q" then
        squareWindow()
    elseif key == "r" then
        newGame()
    elseif key == "p" then
        gamePaused = not gamePaused
	elseif key == "down" then
		-- Prevent pieces dropping multiple squares at once when toggling fast drop
		t = math.min(t, 0.05)
    end
end
function love.update(dt)
	pieceColors = { -- The piece colors
        {love.math.random(50, 100)/100, love.math.random(0,50)/100, love.math.random(50, 100)/100},
        {love.math.random(25,75)/100, love.math.random(38,88)/100, love.math.random(50,100)/100},
        {love.math.random(50,100)/100,   love.math.random(50,100)/100, love.math.random(0,50)/100},
        {love.math.random(0,50)/100, love.math.random(0,50)/100, love.math.random(50,100)/100},
        {love.math.random(50, 100)/100,   love.math.random(25,100)/100, love.math.random(0,50)/100   },
        {love.math.random(50, 100)/100,   love.math.random(0,50)/100,     love.math.random(0,50)/100   },
        {love.math.random(0,50)/100,   love.math.random(50, 100)/100,     love.math.random(0,50)/100   }}
	local dropDelay = 0.75
	if love.keyboard.isDown("down") then
		dropDelay = 0.05
	end
    if gameOver == false and gamePaused == false then
        if t >= dropDelay then
            if movePiece(currentPiece, 0, 1) then
                lockPiece(currentPiece)
                checkLines()
                getPiece()
                updateShadow()
                hasHeld = false
            end
            if love.keyboard.isDown("down") then
                score = score + 1
            end
			t = t - dropDelay
        end
        t = t + dt
    end
end
function checkLines()
    linesCleared = 0
    for l = 1, field.height do
        clearLine = true
        for i = 1, field.width do
            if field[i][field.height + 1 - l].color < 1 then
                clearLine = false
                break
            end
        end
        if clearLine == true then
            linesCleared = linesCleared + 1
            for j = field.height + 1 - l, field.height + 1 do
                for k = 1, field.width do
                    field[k][j] = field[k][j + 1]
                end
            end
        end
    end
    if linesCleared > 0 then
        score = score + 3 ^ (linesCleared - 1) * 100
    end
end
function updateShadow()
    shadow = makePiece(currentPiece.id, true)
    for i = 1, field.width do
        for l = 1, field.height do
            if field[i][l].type == "shadow" then
                field[i][l] = {
                    color = 0,
                    type = "empty"
                }
            end
        end
    end
    for i,s in pairs(shadow.squares) do
        s.x = currentPiece.squares[i].x
        s.y = currentPiece.squares[i].y
    end
    while not (movePiece(shadow, 0, 1)) do end
    lockPiece(shadow)
end
function inCurrentPiece(x, y)
	for _, s in pairs(currentPiece.squares) do
		if s.x == x and s.y == y then
			return true
		end
	end
	return false
end
function drawSquare(square, x, y)
	love.graphics.push()
    love.graphics.translate(x, y)
	love.graphics.scale(squareSize)
	local scaledX = x/squareSize
	local scaledY = y/squareSize
    if square.type == "shadow" then
		if not inCurrentPiece(square.x, square.y) then
			-- Ensure shadow border is equally thick on both sides when scaled
			shadowBorderPx = math.ceil(shadowBorder*squareSize)/squareSize

			love.graphics.setColor(pieceColors[square.color])
			love.graphics.rectangle("fill", 0, 0, 1, 1)
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", shadowBorderPx, shadowBorderPx, 1 - 2*shadowBorderPx, 1 - 2*shadowBorderPx)
		end
    elseif square.type == "normal" then
		love.graphics.push()
        love.graphics.translate(0.5, 0.5)
        love.graphics.rotate(square.rotation*math.pi/2)
        love.graphics.translate(-0.5, -0.5)
        love.graphics.setColor(pieceColors[square.color])
        if square.shape == "end" then
            love.graphics.rectangle("fill", cornerRadius, 0, 1-cornerRadius, 1)
            love.graphics.rectangle("fill", 0, cornerRadius, 1, 1-2*cornerRadius)
            love.graphics.circle("fill", cornerRadius, cornerRadius, cornerRadius)
            love.graphics.circle("fill", cornerRadius, 1-cornerRadius, cornerRadius)
        elseif square.shape == "corner" then
            love.graphics.rectangle("fill", cornerRadius, 0, 1-cornerRadius, 1)
            love.graphics.rectangle("fill", 0, cornerRadius, 1, 1-cornerRadius)
            love.graphics.circle("fill", cornerRadius, cornerRadius, cornerRadius)
        elseif square.shape == "full" then
            love.graphics.rectangle("fill", 0, 0, 1, 1)
        end
		love.graphics.pop()
    end
	love.graphics.pop()
end
function drawField(x0, y0)
	love.graphics.push()
    love.graphics.translate(x0, y0)
    love.graphics.scale(1, -1)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, field.width * squareSize, field.height * squareSize)
    for i = 1, field.width do
        for l = 1, #field[i] - 3 do
			drawSquare(field[i][l], (i-1)*squareSize, (l-1)*squareSize)
        end
    end
    love.graphics.pop()
end
function drawCurrentPiece(fieldOffsetX, fieldOffsetY)
	love.graphics.push()
    love.graphics.translate(fieldOffsetX, fieldOffsetY)
    love.graphics.scale(1, -1)
    love.graphics.setColor(pieceColors[currentPiece.color])
    for _,s in pairs(currentPiece.squares) do
        drawSquare(s, (s.x - 1) * squareSize, (s.y - 1) * squareSize)
    end
    love.graphics.pop()
end
function love.draw()
    local fieldOffsetX = love.graphics.getWidth() / 2 - squareSize * (field.width / 2)
    local fieldOffsetY = (squareSize * field.height + love.graphics.getHeight()) / 2
    if not gamePaused then
        drawField(fieldOffsetX, fieldOffsetY)
        drawCurrentPiece(fieldOffsetX, fieldOffsetY)
        love.graphics.translate(fieldOffsetX, fieldOffsetY)
        love.graphics.scale(1, -1)
		if showScore == true then
			nextPiecePiece = makeRotatedPiece(makePiece(nextPiece, false), 1)
            for _,s in pairs(nextPiecePiece.squares) do
				drawSquare(s, (s.x + (math.floor(field.width / 2) + 1))*squareSize, (s.y - field.height / 2)*squareSize)
            end
			if #heldPiece.squares > 0 then
				for _,s in pairs(makeRotatedPiece(heldPiece, 1).squares) do
					drawSquare(s, (s.x - math.ceil(field.width/2) - 3) * squareSize, (s.y - field.height / 2)*squareSize)
				end
			end
		end
    else
        love.graphics.origin()
        love.graphics.setFont(text2x)
        love.graphics.setColor(1, 0, 1)
        love.graphics.print("Paused", squareSize, squareSize * (field.height / 2 - 3))
    end
    if showScore == true then
        love.graphics.origin()
        love.graphics.setFont(text1x)
        love.graphics.setColor(0, 0, 0)
        love.graphics.translate(fieldOffsetX + field.width*squareSize, fieldOffsetY - field.height*squareSize)
        love.graphics.print("Score", 0, 0)
        love.graphics.print(score, 0, squareSize)
    end
end
