--[[
Copyright (c) 2016 Mauritz Sverredal

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
]]--

function lockPiece(piece)
   for _,s in pairs(piece.squares) do
      field[s.x][s.y] = piece.color
   end
end
function getPiece()
   currentPiece = makePiece(nextPiece)
   nextPiece = love.math.random(#pieces)
   t = 0
   for _,s in pairs(currentPiece.squares) do
      if field[s.x][s.y] > 0 then
         gameOver = true
         TETRIS:stop() --Stop music
         return
      end
   end
end
function newGame() --(re)sets the game state
   
   score = 0
   showScore = true --Show score on screen
   
   t = 0 --Reset time
   
   gameOver = false
   
   hasHeld = false
   heldPiece = {
      squares = {}
   } --No held piece
   
   shadowBorder = 0.05 --As part of square size
   
   field = {
      width = 10,
      height = 20,
   } --Dimensions of playing field
   
   for i = 1, field.width do
      field[i] = {} --Make columns
      for _ = 1, field.height + 3 do
         table.insert(field[i], 0) --Fill field, and 3 tiles over with empty squares (0)
      end
   end
   nextPiece = love.math.random(#pieces) --Generate random piece
   getPiece() --Create the piece
   updateShadow() --Update piece shadow
   love.audio.play(TETRIS) --Restart music
end
function movePiece(piece, x, y)
   for _,s in pairs(piece.squares) do
      if s.y - y < 1 or s.x + x < 1 or s.x + x > field.width or field[s.x + x][s.y - y] > 0 or field[s.x][s.y] > 0 then
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
function squareWindow()
   if showScore == true then
      if love.graphics.getWidth() / field.width > love.graphics.getHeight() / field.height then
         squareSize = love.graphics.getHeight() / field.height
         love.window.setMode(squareSize * (field.width + 8), love.graphics.getHeight(),{resizable=true, vsync=true})
      else
         squareSize = love.graphics.getWidth() / field.width
         love.window.setMode(love.graphics.getWidth() + squareSize * 8, squareSize * field.height,{resizable=true, vsync=true})
      end
   else
      if love.graphics.getWidth() / field.width > love.graphics.getHeight() / field.height then
         squareSize = love.graphics.getHeight() / field.height
         love.window.setMode(squareSize * (field.width), love.graphics.getHeight(),{resizable=true, vsync=true})
      else
         squareSize = love.graphics.getWidth() / field.width
         love.window.setMode(love.graphics.getWidth(), squareSize * field.height,{resizable=true, vsync=true})
      end
   end
   text1x = love.graphics.newFont(squareSize)
   text2x = love.graphics.newFont(squareSize * 2)
end
function makePiece(id)
   local piece = {}
   piece.squares = {}
   for i,s in ipairs(pieces[id]) do
      piece.squares[i] = {}
      piece.squares[i].y = s.y + field.height - 2
      piece.squares[i].x = s.x + math.ceil(field.width / 2) - 2
   end
   piece.rotatePointY = field.height - 2 + pieces[id].rotateY
   piece.rotatePointX = math.ceil(field.width / 2) - 2 + pieces[id].rotateX
   piece.color = pieces[id].color
   piece.id = id
   return(piece)
end
function love.load() --Loads assets
   pieces = { --The different tetrominoes
      {{x=1, y=2}, {x=2, y=1}, {x=2, y=2}, {x=3, y=2}, color = 1, rotateX = 2, rotateY = 2}, --T Piece
      {{x=1, y=2}, {x=2, y=2}, {x=3, y=2}, {x=4, y=2}, color = 2, rotateX = 2.5, rotateY = 2.5}, --Line Piece
      {{x=2, y=1}, {x=3, y=1}, {x=2, y=2}, {x=3, y=2}, color = 3, rotateX = 2.5, rotateY = 1.5}, --Square Piece
      {{x=1, y=2}, {x=2, y=2}, {x=3, y=2}, {x=3, y=1}, color = 4, rotateX = 2, rotateY = 2}, --J Piece
      {{x=1, y=1}, {x=2, y=2}, {x=1, y=2}, {x=3, y=2}, color = 5, rotateX = 2, rotateY = 2}, --L Piece
      {{x=2, y=2}, {x=2, y=1}, {x=1, y=2}, {x=3, y=1}, color = 6, rotateX = 2, rotateY = 2}, --Z Piece
      {{x=2, y=2}, {x=2, y=1}, {x=1, y=1}, {x=3, y=2}, color = 7, rotateX = 2, rotateY = 2}, --S Piece
   }
   pieceColors = { --The piece colors
      {1, 0, 1},
      {0.5, 170/255, 1},
      {1, 1, 0},
      {0, 0, 0.75},
      {1, 2/3, 0},
      {1, 0, 0},
      {0, 1, 0}
   }
   TETRIS = love.audio.newSource("tetris.ogg", "stream") --Tetris music
   volume = 0.17
   love.audio.setVolume(volume) --Sets volume to 0.17
   TETRIS:setLooping(true) --Makes the music loop
   love.window.setTitle("Tetris!") --Sets the window title
   love.graphics.setBackgroundColor(1/4, 1/4, 1/4) --Sets the background color
   gamePaused = false --Not paused
   newGame()
   squareWindow() --Fix window size and aspect ratio
end
function love.resize()
   if love.graphics.getWidth() / (field.width + 8) > love.graphics.getHeight() / field.height then
      squareSize = love.graphics.getHeight() / field.height
   else
      squareSize = love.graphics.getWidth() / (field.width + 8)
   end
   text1x = love.graphics.newFont(squareSize)
   text2x = love.graphics.newFont(squareSize * 2)
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
               currentPiece = makePiece(heldPiece.id)
               heldPiece = makePiece(id)
            else
               heldPiece = makePiece(id)
               getPiece()
            end
            for _,s in pairs(currentPiece.squares) do
               if field[s.x][s.y] > 0 then
                  gameOver = true
                  TETRIS:stop()
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
         canSpin = true
         for _,s in pairs(currentPiece.squares) do
            if (-(s.y - currentPiece.rotatePointY)) + currentPiece.rotatePointX < 1 or (-(s.y - currentPiece.rotatePointY)) + currentPiece.rotatePointX > field.width or ((s.x - currentPiece.rotatePointX)) + currentPiece.rotatePointY < 1 or field[(-(s.y - currentPiece.rotatePointY)) + currentPiece.rotatePointX][((s.x - currentPiece.rotatePointX)) + currentPiece.rotatePointY] > 0 then
               canSpin = false
            end
         end
         if canSpin == true then
            for _,s in pairs(currentPiece.squares) do
               local storedX = s.x
               local storedY = s.y
               s.x = (-(storedY - currentPiece.rotatePointY)) + currentPiece.rotatePointX
               s.y = ((storedX - currentPiece.rotatePointX)) + currentPiece.rotatePointY
            end
            updateShadow()
         end
      elseif key == "x" then 
         canSpin = true
         for _,s in pairs(currentPiece.squares) do
            if ((s.y - currentPiece.rotatePointY)) + currentPiece.rotatePointX < 1 or ((s.y - currentPiece.rotatePointY)) + currentPiece.rotatePointX > field.width or (-(s.x - currentPiece.rotatePointX)) + currentPiece.rotatePointY < 1 or field[((s.y - currentPiece.rotatePointY)) + currentPiece.rotatePointX][(-(s.x - currentPiece.rotatePointX)) + currentPiece.rotatePointY] > 0 then
               canSpin = false
            end
         end
         if canSpin == true then
            for _,s in pairs(currentPiece.squares) do
               local storedX = s.x
               local storedY = s.y
               s.x = ((storedY - currentPiece.rotatePointY)) + currentPiece.rotatePointX
               s.y = (-(storedX - currentPiece.rotatePointX)) + currentPiece.rotatePointY
            end
            updateShadow()
         end
      end
   end
   if key == "s" then
      showScore = not showScore
   elseif key == "m" then
      volume = volume - 2 * volume + 0.17
      love.audio.setVolume(volume)
   elseif key == "q" then
      squareWindow()
   elseif key == "r" then
      newGame()
   elseif key == "p" then
      gamePaused = not gamePaused
   end
end
function love.update(dt)
   if gameOver == false and gamePaused == false then
      if t > 0.75 or (love.keyboard.isDown("down") and t > 0.05) then
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
         t = 0
      end
      t = t + dt
   end
end
function checkLines()
   linesCleared = 0
   for l = 1, field.height do
      clearLine = true
      for i = 1, field.width do
         if field[i][field.height + 1 - l] < 1 then
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
   shadow = makePiece(currentPiece.id)
   shadow.color = -1
   for i = 1, field.width do
      for l = 1, field.height do
         if field[i][l] == -1 then
            field[i][l] = 0
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
function love.draw()
    --love.graphics.setColor(0.33, 0.33, 0.33)
    --love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   love.graphics.translate(love.graphics.getWidth() / 2 - squareSize * (field.width / 2), (squareSize * field.height + love.graphics.getHeight()) / 2)
   love.graphics.scale(1, -1)
   love.graphics.setColor(0, 0, 0)
   love.graphics.rectangle("fill", 0, 0, field.width * squareSize, field.height * squareSize)
   if not gamePaused then
      for i = 1, field.width do
         for l = 1, #field[i] - 3 do
            if field[i][l] == -1 then
               shadowBorderPx = math.ceil(shadowBorder * squareSize)
               love.graphics.setColor(pieceColors[currentPiece.color])
               love.graphics.rectangle("fill", (i - 1) * squareSize, (l - 1) * squareSize, squareSize, squareSize)
               love.graphics.setColor(0, 0, 0)
               love.graphics.rectangle("fill", (i - 1) * squareSize + shadowBorderPx, (l - 1) * squareSize + shadowBorderPx, squareSize - 2 * shadowBorderPx, squareSize - 2 * shadowBorderPx)
            elseif field[i][l] > 0 then
               love.graphics.setColor(pieceColors[field[i][l]])
               love.graphics.rectangle("fill", (i - 1) * squareSize, (l - 1) * squareSize, squareSize, squareSize)
            end
         end
      end
   end
if gamePaused == false then
   love.graphics.setColor(pieceColors[currentPiece.color])
   for _,s in pairs(currentPiece.squares) do   
      love.graphics.rectangle("fill", (s.x - 1) * squareSize, (s.y - 1) * squareSize, squareSize, squareSize)
   end
else
   love.graphics.origin()
   love.graphics.setFont(text2x)
   love.graphics.setColor(255, 0, 255)
   love.graphics.print("Paused", squareSize, squareSize * (field.height / 2 - 3))
end
if showScore == true then
   if gamePaused == false then
      nextPiecePiece = makePiece(nextPiece)
      for _,s in pairs(nextPiecePiece.squares) do
         love.graphics.setColor(pieceColors[nextPiecePiece.color])
         love.graphics.rectangle("fill", (((-(s.y - math.floor(nextPiecePiece.rotatePointY))) + math.ceil(nextPiecePiece.rotatePointX)) + (field.width / 2 + 1)) * squareSize, ((((s.x - math.ceil(nextPiecePiece.rotatePointX))) + math.ceil(nextPiecePiece.rotatePointY)) - field.height / 2) * squareSize, squareSize, squareSize)
      end
      for _,s in pairs(heldPiece.squares) do
         love.graphics.setColor(pieceColors[heldPiece.color])
         love.graphics.rectangle("fill", (((-(s.y - math.floor(heldPiece.rotatePointY))) + math.ceil(heldPiece.rotatePointX)) + (field.width / 2 + 1)) * squareSize - ((field.width + 4) * squareSize), ((((s.x - math.ceil(heldPiece.rotatePointX))) + math.ceil(heldPiece.rotatePointY)) - field.height / 2) * squareSize, squareSize, squareSize)
      end
   end
   love.graphics.origin()
   love.graphics.setFont(text1x)
   love.graphics.setColor(0, 0, 0)
   love.graphics.translate(love.graphics.getWidth() / 2 + (field.width / 2) * squareSize, love.graphics.getHeight() - squareSize * field.height)
   love.graphics.print("Score", 0, 0)
   love.graphics.print(score, 0, squareSize)
end
end