require("sprites")
require("scenes")
require("3d")

if arg[2] == "debug" then
    require("lldebugger").start()
  end
  
io.stdout:setvbuf("no")

function love.load()

    --Screen setup

    love.window.setFullscreen(true)

    love.window.setVSync(1)

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    love.graphics.setBackgroundColor(.5,.7,1)

    love.mouse.setPosition(width/2+100,height/4)
    love.mouse.setVisible(false)

    love.window.setTitle("Stuck Together")

    --Movement variables

    wheld = 0
    sheld = 0
    aheld = 0
    dheld = 0

    --Shader/ canvas setup

    mainShader = love.graphics.newShader("Shaders/render.frag")

    bigSpriteSheet = love.graphics.newImage("Textures/bigSpriteSheet.png")
    bigSpriteSheet:setFilter("nearest","nearest")

    glueCursor = love.graphics.newImage("Textures/glueCursor.png")
    noGlueCursor = love.graphics.newImage("Textures/noGlueCursor.png")
    wrench = love.graphics.newImage("Textures/wrench.png")

    glueSplat = love.graphics.newImage("Textures/splat22.png")
    water = love.graphics.newImage("Textures/splat02.png")
    textQ = love.graphics.newImage("Textures/keyboard_q.png")
    textE = love.graphics.newImage("Textures/keyboard_e.png")
    textW = love.graphics.newImage("Textures/keyboard_w.png")
    textA = love.graphics.newImage("Textures/keyboard_a.png")
    textS = love.graphics.newImage("Textures/keyboard_s.png")
    textD = love.graphics.newImage("Textures/keyboard_d.png")
    leftArrow = love.graphics.newImage("Textures/left.png")
    rightArrow = love.graphics.newImage("Textures/right.png")
    arrow = love.graphics.newImage("Textures/arrow.png")
    leftClick = love.graphics.newImage("Textures/mouse_left.png")
    rightClick = love.graphics.newImage("Textures/mouse_right.png")
    mouseMove = love.graphics.newImage("Textures/mouse_move.png")

    font = love.graphics.newFont("Kenney Future.ttf",25)
    smallFont = love.graphics.newFont("Kenney Future.ttf",15)
    instructions = love.graphics.newText(font,"Stack the crates to reach the lever")
    title = love.graphics.newText(font,"Stuck Together")
    playButton = love.graphics.newText(smallFont,"PLAY")
    quitButton = love.graphics.newText(smallFont,"QUIT")

    crateImpact = love.audio.newSource("Sounds/crateImpact.ogg","static")
    creaks = {}
    table.insert(creaks,love.audio.newSource("Sounds/creak1.ogg","static"))
    table.insert(creaks,love.audio.newSource("Sounds/creak2.ogg","static"))
    table.insert(creaks,love.audio.newSource("Sounds/creak3.ogg","static"))
    footsteps = {}
    for i = 0,4 do
        table.insert(footsteps,love.audio.newSource("Sounds/footstep_concrete_00"..i..".ogg","static"))
    end

    spriteSize = 18
    scale = (width/2)/(20*spriteSize)

    playerQuad = love.graphics.newQuad(4*spriteSize,7*spriteSize,spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    railQuad = love.graphics.newQuad(5*spriteSize,3*spriteSize,spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    chainQuad = love.graphics.newQuad(8*spriteSize,1*spriteSize,spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    rollerQuad = love.graphics.newQuad(4*spriteSize,6*spriteSize,3*spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    wheelQuad = love.graphics.newQuad(3*spriteSize,6*spriteSize,spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    leverQuad = love.graphics.newQuad(9*spriteSize,7*spriteSize,spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    buttonQuad = love.graphics.newQuad(4*spriteSize,0*spriteSize,3*spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    gluedCrateQuad = love.graphics.newQuad(16*spriteSize,0,spriteSize,spriteSize,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())

    if(mainShader:hasUniform("spriteSheet")) then
        mainShader:send("spriteSheet",bigSpriteSheet)
    end
    if(mainShader:hasUniform("spriteSheetWidth")) then
        mainShader:send("spriteSheetWidth",bigSpriteSheet:getWidth())
    end
    if(mainShader:hasUniform("spriteSheetHeight")) then
        mainShader:send("spriteSheetHeight",bigSpriteSheet:getHeight())
    end


    screen = love.graphics.newCanvas(width/2,height)
    preDither = love.graphics.newCanvas(width/2,height)
    preKuwahara = love.graphics.newCanvas(width/2,height)

    defineSprites()

    createScenes()

    currentScene = scenes[1]

    titleScreen = {}
    titleScreen.selection = 1
    titleScreen.selectionMax = 2

    currentScene = titleScreen

    frameCount = 0
end

function love.keypressed(key) 
    if key == "return" then
        if currentScene.selection then
            if currentScene.selection == 2 then
                love.event.quit()
            else
                currentScene = scenes[1]
            end
        end
    end
    if key == "w" then
        if (currentScene.selection) then
            currentScene.selection = currentScene.selection - 1
            if currentScene.selection < 1 then
                currentScene.selection = 1
            end
        end
        wheld = 1
    end
    if key == "a" then
        aheld = 1
    end
    if key == "s" then
        sheld = 1
        if (currentScene.selection) then
            currentScene.selection = currentScene.selection + 1
            if currentScene.selection > currentScene.selectionMax then
                currentScene.selection = currentScene.selectionMax
            end
        end
    end
    if key == "d" then
        dheld = 1
    end
    if (currentScene.cameraPos) then
        keyPressed3d(currentScene,key)
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key)
    if key == "w" then
        wheld = 0
    end
    if key == "a" then
        aheld = 0
    end
    if key == "s" then
        sheld = 0
    end
    if key == "d" then
        dheld = 0
    end
end

function love.mousemoved(x,y,dx,dy)
    if (currentScene.cameraPos) then
        mouseMove3d(currentScene,x,y,dx,dy)
    end
end

function love.update(dt)
    if (currentScene.cameraPos) then
        move3d(currentScene,dt)
        if currentScene.changeScene > 0 then
            local tempScene = currentScene.changeScene
            currentScene.changeScene = 0
            currentScene = scenes[tempScene]
        end
    end
    
end

function love.draw()
    if (currentScene.cameraPos) then
        draw3D(currentScene)
    else
        love.graphics.draw(title,width/2-title:getWidth()/2,height/4)
        love.graphics.draw(bigSpriteSheet,rollerQuad,width/2-spriteSize*scale*1.5,height/4-scale*spriteSize,0,scale,scale)
        love.graphics.draw(bigSpriteSheet,railQuad,width/2 - spriteSize * scale/2,height/4 - 2*scale*spriteSize,0,scale,scale)
        love.graphics.draw(bigSpriteSheet,railQuad,width/2 - spriteSize * scale/2,height/4 - 3*scale*spriteSize,0,scale,scale)
        for i = 1,10 do
            love.graphics.draw(bigSpriteSheet,railQuad,width/2 + i * spriteSize * scale/2,height/4 - 4*scale*spriteSize,math.pi/2,scale,scale)
        end
        love.graphics.draw(bigSpriteSheet,buttonQuad,width/2 - 1.5*3*spriteSize * scale/2,height/2-1.5*scale*spriteSize,0,1.5*scale,1.5*scale)
        love.graphics.draw(bigSpriteSheet,buttonQuad,width/2 - 1.5*3*spriteSize * scale/2,height/2+1.5*scale*spriteSize,0,1.5*scale,1.5*scale)
        love.graphics.draw(playButton,width/2-playButton:getWidth()/2,height/2-37)
        love.graphics.draw(quitButton,width/2-quitButton:getWidth()/2,height/2+78)
        if currentScene.selection == 1 then
            for i = 1,((height/2-1.5*scale*spriteSize)-(height/4- 4*scale*spriteSize))/(spriteSize*scale) + 1 do
                if i < ((height/2-1.5*scale*spriteSize)-(height/4- 4*scale*spriteSize))/(spriteSize*scale) then
                    love.graphics.draw(bigSpriteSheet,chainQuad,width/2 + 8.5 * spriteSize * scale/2,height/4 + (i-4)*scale*spriteSize,0,scale,scale)
                else
                    love.graphics.draw(bigSpriteSheet,gluedCrateQuad,width/2 + 8.5 * spriteSize * scale/2,height/4 + (i-4)*scale*spriteSize,0,scale,scale)
                    love.graphics.draw(bigSpriteSheet,playerQuad,width/2 + 7.5 * spriteSize * scale/2,height/4 + (i-5)*scale*spriteSize,0,scale,scale)
                end
            end

        else
            for i = 1,((height/2+1.5*scale*spriteSize)-(height/4- 4*scale*spriteSize))/(spriteSize*scale) + 1 do
                if i < ((height/2+1.5*scale*spriteSize)-(height/4- 4*scale*spriteSize))/(spriteSize*scale) then
                    love.graphics.draw(bigSpriteSheet,chainQuad,width/2 + 8.5 * spriteSize * scale/2,height/4 + (i-4)*scale*spriteSize,0,scale,scale)
                else
                    love.graphics.draw(bigSpriteSheet,gluedCrateQuad,width/2 + 8.5 * spriteSize * scale/2,height/4 + (i-4)*scale*spriteSize,0,scale,scale)
                    love.graphics.draw(bigSpriteSheet,playerQuad,width/2 + 7.5 * spriteSize * scale/2,height/4 + (i-5)*scale*spriteSize,0,scale,scale)
                end
            end
        end
    end
end