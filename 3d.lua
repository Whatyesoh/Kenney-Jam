function lift(amount,object)
    object.subY = object.subY + amount
    if object.subY > 1 then
        object.subY = 0
        object.y = object.y + 1
    end
end

function lower(amount,object)
    object.subY = object.subY - amount
    if object.subY < 0 then
        object.subY = 1
        object.y = object.y - 1
    end
    if object.y < 0 then
        object.y = 0
        object.subY = 0
    end
end

function move3d(scene, dt)
    local cameraPos = scene.cameraPos
    local floor = scene.floor
    local speed = scene.speed
    local playerHeight = scene.playerHeight
    local cameraLook = scene.cameraLook
    local sendablePos = scene.sendablePos
    local theta = scene.theta

    local craneSpeed = 1

    scene.chainTimer = scene.chainTimer + dt
    scene.footstepTimer = scene.footstepTimer + dt

    if love.mouse.isDown(1) or love.mouse.isDown(2) then
        local collided = 0
        local tempX = scene.craneChain.x + scene.craneChain.subX
        local tempZ = scene.craneChain.z + scene.craneChain.subY
        tempY = scene.craneChain.y + scene.craneChain.subY

        local xLower = -.25
        local xUpper = .25
        local yUpper = 0
        local zLower = .25
        local zUpper = .75

        if (scene.glued > 0) then
            for i,v in ipairs(scene.collision) do
                if (v[7] == scene.glued) then
                    tempX = v[1]
                    xUpper = v[4]
                    xLower = 0
                    tempY = v[2]
                    yUpper = v[5]
                    tempZ = v[3]
                    zLower = 0
                    zUpper = v[6]
                end
            end
        end

        if love.mouse.isDown(1) then
            tempY = tempY + craneSpeed * dt
        else
            tempY = tempY - craneSpeed * dt
        end


    
        if tempY < 0 then
            collided = 1
        end

        for i,v in ipairs(scene.collision) do
            if (v[7] ~= scene.glued) then
                if tempX + xUpper > v[1] and tempX + xLower < v[1] + v[4] and tempY + yUpper > v[2] and tempY < v[5] + v[2] and tempZ + zUpper > v[3] and tempZ + zLower < v[3] + v[6] then
                    collided = 1
                    scene.chainTimer = 0
                    scene.chainTouching = v[7]
                    break
                end
            end
        end
    
    
        if collided == 1 then
           
        else
            local creakCount = 0
            for index, sound in ipairs(creaks) do
                if sound:isPlaying() then
                    creakCount = 1
                    break
                end
            end
            if creakCount == 0 then
                creaks[love.math.random(1,3)]:play()
            end
            scene.chainTouching = 0
            if love.mouse.isDown(1) then
                lift(craneSpeed*dt,scene.craneChain)
                if scene.glued > 0 then
                    for i,v in ipairs(scene.objects) do
                        if v.boxNum == scene.glued then
                            lift(craneSpeed*dt,v)
                        end
                    end
                    for i,v in ipairs(scene.collision) do
                        if(v[7] == scene.glued) then
                            v[2] = v[2] + craneSpeed * dt
                        end
                    end
                end
                scene.craneChain2.subY = scene.craneChain.subY
                scene.craneChain2.y = scene.craneChain.y
            end
            if love.mouse.isDown(2) then
                lower(craneSpeed * dt,scene.craneChain)
                if scene.glued > 0 then
                    for i,v in ipairs(scene.objects) do
                        if v.boxNum == scene.glued then
                            lower(craneSpeed*dt,v)
                            if v.yLength == 0 then
                                local minFloor = 0
                                local floorType = 0
                                for i1,v2 in ipairs(scene.objects) do
                                    if v2.boxNum == scene.glued then
                                        if v2.yLength > 0 then
                                            minFloor = v2.yLength
                                        else
                                            if v2.y + v2.subY < v.y + v.subY then
                                                floorType = 1
                                            end
                                        end
                                    end
                                end
                                if v.y < minFloor * floorType then
                                    v.y = minFloor * floorType
                                    v.subY = 0
                                end
                            end
                        end
                    end
                    for i,v in ipairs(scene.collision) do
                        if(v[7] == scene.glued) then
                            v[2] = v[2] - craneSpeed * dt
                            if v[2] < 0 then
                                v[2] = 0
                            end
                        end
                    end
                end
                scene.craneChain2.subY = scene.craneChain.subY
                scene.craneChain2.y = scene.craneChain.y
            end
        end
    end




    cameraPos[2] = cameraPos[2] + scene.vertSpeed * dt

    local collided = 0
    local tempX = cameraPos[1]
    local tempZ = cameraPos[3]

    for i,v in ipairs(scene.collision) do
        if tempX + .5 >= v[1] and tempX - .5 <= v[1] + v[4] and tempZ + .5 >= v[3] and tempZ - .5 <= v[3] + v[6] and cameraPos[2] + scene.playerHeight >= v[2] and cameraPos[2] <= v[2] + v[5] then
            if scene.vertSpeed < 0 and cameraPos[2] >= v[2] and cameraPos[2] <= v[2] + v[5] then
                floor = v[2] + v[5]
            else
                cameraPos[2] = cameraPos[2] - scene.vertSpeed * dt
                scene.vertSpeed = 0
            end
        end
    end

    if cameraPos[2] <= floor then
        scene.onFloor = 1
        scene.vertSpeed = 0
        cameraPos[2] = floor
    else
        scene.vertSpeed = scene.vertSpeed - 10 * dt
    end


    for i,v in ipairs(scene.collision) do
        if v[7] ~= scene.glued then
            floor = scene.floor

            for i2,v2 in ipairs(scene.collision) do
                if v[7] ~= v2[7] then 
                    if 
                        ((v[1] + v[4] >= v2[1] and v[1] + v[4] <= v2[1] + v2[4]) or (v[1] >= v2[1] and v[1] <= v2[1] + v2[4])) and 
                        ((v[3] + v[6] >= v2[3] and v[3] + v[6] <= v2[3] + v2[6]) or (v[3] >= v2[3] and v[3] <= v2[3] + v2[6])) and 
                        v[2] <= v2[2] + v2[5] then

                        floor = v2[2] + v2[5]
                    end
                end
            end

            if v[2] > floor then
                v[2] = v[2] - dt
                if (v[2] < floor) then
                    crateImpact:play()
                end
                for i2,v2 in ipairs(scene.objects) do
                    if v[7] == v2.boxNum then
                        v2.subY = v2.subY - dt
                        if v2.subY < 0 then
                            v2.y = v2.y - 1
                            v2.subY = 1
                        end
                        if v2.y < floor then
                            v2.y = floor
                            v2.subY = 0
                        end
                    end
                end
            end
        end
    end


    if wheld == 1 then

        local collidedX = 0
        local collidedZ = 0
        local tempX = cameraPos[1] + math.cos(theta) * dt * speed
        local tempZ = cameraPos[3] + math.sin(theta) * dt * speed
    
        for i,v in ipairs(scene.collision) do
            if tempX + .5 >= v[1] and tempX - .5 <= v[1] + v[4] and tempZ + .5 >= v[3] and tempZ - .5 <= v[3] + v[6] and cameraPos[2] +scene.playerHeight >= v[2] and cameraPos[2] <= v[2] + v[5] then
                if tempX + .5 >= v[1] and tempX - .5 <= v[1] + v[4] then
                    if cameraPos[3] + .5 < v[3] or cameraPos[3] - .5 > v[3] + v[6] then
                        collidedZ = 1
                    end
                end
                if tempZ + .5 >= v[3] and tempZ - .5 <= v[3] + v[6] then
                    if cameraPos[1] + .5 < v[1] or cameraPos[1] - .5 > v[1] + v[4] then
                        collidedX = 1
                    end
                end
            end
        end

        if collidedX ~= 1 then
            cameraPos[1] = cameraPos[1] + math.cos(theta) * dt * speed           
        end
        if collidedZ ~= 1 then
            cameraPos[3] = cameraPos[3] + math.sin(theta) * dt * speed       
        end
        if (collidedX ~= 1 or collidedZ ~= 1) and scene.onFloor == 1 and scene.footstepTimer > .5 then
            scene.footstepTimer = 0
            local footstepCount = 0
            for index, sound in ipairs(footsteps) do
                if sound:isPlaying() then
                    footstepCount = 1
                    break
                end
            end
            if footstepCount == 0 then
                footsteps[love.math.random(1,5)]:play()
            end
        end

    end
    if aheld == 1 then
        scene.theta = scene.theta - 3 * dt
    end
    if sheld == 1 then
        local collidedX = 0
        local collidedZ = 0
        local tempX = cameraPos[1] - math.cos(theta) * dt * speed
        local tempZ = cameraPos[3] - math.sin(theta) * dt * speed
    
        for i,v in ipairs(scene.collision) do
            if tempX + .5 >= v[1] and tempX - .5 <= v[1] + v[4] and tempZ + .5 >= v[3] and tempZ - .5 <= v[3] + v[6] and cameraPos[2] +scene.playerHeight  >= v[2] and cameraPos[2]<= v[2] + v[5] then
                if tempX + .5 >= v[1] and tempX - .5 <= v[1] + v[4] then
                    if cameraPos[3] + .5 < v[3] or cameraPos[3] - .5 > v[3] + v[6] then
                        collidedZ = 1
                    end
                end
                if tempZ + .5 >= v[3] and tempZ - .5 <= v[3] + v[6] then
                    if cameraPos[1] + .5 < v[1] or cameraPos[1] - .5 > v[1] + v[4] then
                        collidedX = 1
                    end
                end
            end
        end

        if collidedX ~= 1 then
            cameraPos[1] = cameraPos[1] - math.cos(theta) * dt * speed          
        end
        if collidedZ ~= 1 then
            cameraPos[3] = cameraPos[3] - math.sin(theta) * dt * speed        
        end
        if (collidedX ~= 1 or collidedZ ~= 1) and scene.onFloor == 1 and scene.footstepTimer > .5 then
            scene.footstepTimer = 0
            local footstepCount = 0
            for index, sound in ipairs(footsteps) do
                if sound:isPlaying() then
                    footstepCount = 1
                    break
                end
            end
            if footstepCount == 0 then
                footsteps[love.math.random(1,5)]:play()
            end
        end
    end
    if dheld == 1 then
        scene.theta = scene.theta + 3 * dt
    end

    cameraLook[1] = cameraPos[1] - math.cos(math.pi - theta)
    cameraLook[2] = cameraPos[2] + playerHeight
    cameraLook[3] = cameraPos[3] + math.sin(math.pi - theta)

    sendablePos[1] = cameraPos[1]
    sendablePos[2] = cameraPos[2] + playerHeight
    sendablePos[3] = cameraPos[3]

    if (mainShader:hasUniform("lookFrom")) then
        mainShader:send("lookFrom",sendablePos)
    end
    if (mainShader:hasUniform("lookAt")) then
        mainShader:send("lookAt",cameraLook)
    end
end

function mouseMove3d(scene,x,y,dx,dy)
    local sensitivity = 50
    local collided = 0
    local tempX = scene.craneChain.x + scene.craneChain.subX + dx/sensitivity
    local tempY = scene.craneChain.y + scene.craneChain.subY
    local tempZ = scene.craneChain.z + scene.craneChain.subZ + dy/sensitivity

    local firstX = scene.craneChain.x + scene.craneChain.subX
    local firstZ = scene.craneChain.z + scene.craneChain.subZ

    local xLower = -.25
    local xUpper = .25
    local yUpper = 0
    local yLower = 0
    local zLower = .25
    local zUpper = .75

    if (scene.glued > 0) then
        for i,v in ipairs(scene.collision) do
            if (v[7] == scene.glued) then
                tempX = v[1] + dx/sensitivity
                xUpper = v[4]
                xLower = 0
                tempY = v[2]
                yUpper = v[5]
                tempZ = v[3] + dy/sensitivity
                zLower = 0
                zUpper = v[6]
            end
        end
    end

    for i,v in ipairs(scene.collision) do
        if (v[7] ~= 0 and v[7] ~= scene.glued) then 
            if tempX + xUpper >= v[1] and tempX + xLower <= v[1] + v[4] and tempY + yUpper >= v[2] and tempY + yLower <= v[5] + v[2] and tempZ + zUpper >= v[3] and tempZ + zLower <= v[3] + v[6] then
                collided = 1
                --scene.chainTouching = v[7]
                scene.chainTimer = 0
                break
            end
        end
    end


    if collided == 1 then

    else
        if (scene.chainTimer > .2) then
            scene.chainTouching = 0
        end

        scene.craneChain.subX = scene.craneChain.subX + dx/sensitivity
        if (scene.craneChain.subX > 1) then
            scene.craneChain.subX = 0
            scene.craneChain.x = scene.craneChain.x + 1
        end
        if (scene.craneChain.subX < 0) then
            scene.craneChain.subX = 1
            scene.craneChain.x = scene.craneChain.x - 1
        end

        scene.craneChain.subZ = scene.craneChain.subZ + dy/sensitivity
        if (scene.craneChain.subZ > 1) then
            scene.craneChain.subZ = 0
            scene.craneChain.z = scene.craneChain.z + 1
        end
        if (scene.craneChain.subZ < 0) then
            scene.craneChain.subZ = 1
            scene.craneChain.z = scene.craneChain.z - 1
        end

        if scene.craneChain.x > 20 then
            scene.craneChain.x = 20
            scene.craneChain.subX = 0
        end
        
        if scene.craneChain.z > 20 then
            scene.craneChain.z = 20
            scene.craneChain.subz = 0
        end
        
        if scene.craneChain.x < 0 then
            scene.craneChain.x = 0
            scene.craneChain.subX = 0
        end
        
        if scene.craneChain.z < 0 then
            scene.craneChain.z = 0
            scene.craneChain.subz = 0
        end

        scene.craneChain2.x = scene.craneChain.x
        scene.craneChain2.subX = scene.craneChain.subX
        scene.craneChain2.z = scene.craneChain.z
        scene.craneChain2.subZ = scene.craneChain.subZ

        scene.craneChain2.subX = scene.craneChain2.subX - .5
        if scene.craneChain2.subX < 0 then
            scene.craneChain2.x = scene.craneChain2.x - 1
            scene.craneChain2.subX = scene.craneChain2.subX + 1
        end

        scene.craneChain2.subZ = scene.craneChain2.subZ + .5
        if scene.craneChain2.subZ > 1 then
            scene.craneChain2.z = scene.craneChain2.z + 1
            scene.craneChain2.subZ = scene.craneChain2.subZ - 1
        end


        if (scene.glued > 0) then
            local minX = 100
            local minZ = 100
            for i,v in ipairs(scene.objects) do
                if (v.boxNum == scene.glued) then
                    v.x = scene.craneChain.x
                    v.subX = scene.craneChain.subX
                    v.z = scene.craneChain.z
                    v.subZ = scene.craneChain.subZ
            
                    v.subX = v.subX + v.glueX
                    if v.subX < 0 then
                        v.x = v.x - 1
                        v.subX = v.subX + 1
                    end
                    if v.subX > 1 then
                        v.x = v.x + 1
                        v.subX = v.subX - 1
                    end
            
                    v.subZ = v.subZ + v.glueZ
                    if v.subZ > 1 then
                        v.z = v.z + 1
                        v.subZ = v.subZ - 1
                    end
                    if v.subZ < 0 then
                        v.z = v.z - 1
                        v.subZ = v.subZ + 1
                    end
                    if (v.x + v.subX < minX) then
                        minX = v.x + v.subX
                    end
                    if (v.z + v.subZ < minZ) then
                        minZ = v.z + v.subZ
                    end
                end
            end
            for i,v in ipairs(scene.collision) do
                if v[7] == scene.glued then
                    v[1] = minX
                    v[3] = minZ
                end
            end
        end
    end
    scene.mouseX = love.mouse.getX()
    scene.mouseY = love.mouse.getY()
    if love.mouse.getX() > 3 * width / 4 then
        love.mouse.setPosition(width/2,height/2)
    end
    if love.mouse.getX() < width / 4 then
        love.mouse.setPosition(width/2,height/2)
    end
    if love.mouse.getY() > 3 * height / 4 then
        love.mouse.setPosition(width/2,height/2)
    end
    if love.mouse.getY() < height / 4 then
        love.mouse.setPosition(width/2,height/2)
    end
end

function keyPressed3d(scene, key)
    if key == "space" then
        if scene.onFloor == 1 then
            scene.onFloor = 0
            scene.vertSpeed = 5
        end
    end
    if key == "e" then
        if (scene.glued == 0 and scene.hovered > 0 and scene.chainTouching == scene.hovered) or scene.hovered == 255 then
            if scene.hovered ~= 255 then
                scene.glued = scene.hovered
            end
            for i,v in ipairs(scene.objects) do
                if v.boxNum == scene.hovered then
                    tempTop = v.textureTop
                    tempLeft = v.textureLeft
                    v.textureTop = v.glueTop
                    v.textureLeft = v.glueLeft
                    v.glueTop = tempTop
                    v.glueLeft = tempLeft
                    v.color ={v.textureLeft/255.0,v.textureTop/255.0,v.textureWidth/255.0,1}
                    v.glueX = v.x - scene.craneChain.x + v.subX - scene.craneChain.subX
                    v.glueY = v.y - scene.craneChain.y + v.subY - scene.craneChain.subY
                    v.glueZ = v.z - scene.craneChain.z + v.subZ - scene.craneChain.subZ
                end
            end
            if scene.hovered == 255 then
                scene.changeScene = 2
            end
        end
    end
    if key == "q" then
        if scene.glued > 0 and scene.hovered == scene.glued then
            scene.glued = 0
            for i,v in ipairs(scene.objects) do
                if v.boxNum == scene.hovered then
                    tempTop = v.textureTop
                    tempLeft = v.textureLeft
                    v.textureTop = v.glueTop
                    v.textureLeft = v.glueLeft
                    v.glueTop = tempTop
                    v.glueLeft = tempLeft
                    v.color ={v.textureLeft/255.0,v.textureTop/255.0,v.textureWidth/255.0,1}
                end
            end
        end
    end
end

function draw3D(scene)
    mapObjects(scene)

    for i,v in ipairs(scene.objects) do
        if v.boxNum == 0 and (v.textureTop ~= 1 or v.textureLeft ~= 8) and v.y == 0 then
            if (v.yLength == 0) then
                for j = 0,v.xLength do
                    for k = 0,v.zLength do
                        love.graphics.draw(bigSpriteSheet,v.quad,width/2 + j * spriteSize * scale,k * spriteSize * scale + (height/2)-(scale*v.zLength*spriteSize)/2,0,scale,scale)
                    end
                end
            end
            if (v.zLength == 0) then
                for j = 0,v.xLength do
                    love.graphics.draw(bigSpriteSheet,v.quad,width/2 + j * spriteSize * scale + v.x * scale * spriteSize,(height-20*spriteSize*scale)/2 + v.z * scale * spriteSize,0,scale,scale)
                end
            end
            if (v.xLength == 0) then
                for j = 0,v.zLength do
                    love.graphics.draw(bigSpriteSheet,v.quad,width/2 + (v.x+.5)*spriteSize*scale,(height-20*spriteSize*scale)/2 + j*spriteSize*scale + v.z * scale * spriteSize,math.pi/2,scale,scale)
                end
            end
        elseif v.boxNum > 0 then
            if v.yLength == 0 then
                love.graphics.draw(bigSpriteSheet,v.quad,width/2 + (v.x-.5 + v.subX) * scale * spriteSize,(height-20*spriteSize*scale)/2 + (v.z + v.subZ+.25) * scale * spriteSize,0,scale,scale)
            end
        end
    end

    if mainShader:hasUniform("selected") then
        mainShader:send("selected",scene.hovered)
    end

    love.graphics.setCanvas(preDither)
    love.graphics.setShader(mainShader)
    love.graphics.draw(screen)

    love.graphics.setCanvas()
    love.graphics.setShader()
    love.graphics.draw(preDither)

    frameCount = frameCount + 1
    if (frameCount >= 10) then
        frameCount = 0
        checkBox = preDither:newImageData()
        local test = 255*checkBox:getPixel(preDither:getWidth()/2,preDither:getHeight()/2+100)
        if scene.chainTouching == test or test == 255 or scene.glued == test then
            scene.hovered = test
        else
            scene.hovered = 0
        end
    end

    if scene.hovered > 0 then
        if scene.hovered < 255 then
            love.graphics.draw(glueCursor,preDither:getWidth()/2-8 * scale,preDither:getHeight()/2+100 - 8 * scale,0,scale,scale)
        else
            love.graphics.draw(wrench,preDither:getWidth()/2-8 * scale,preDither:getHeight()/2+100 - 8 * scale,0,scale,scale)
        end
    else
        love.graphics.draw(noGlueCursor,preDither:getWidth()/2-8 * scale,preDither:getHeight()/2 + 100 - 8 * scale,0,scale,scale)
    end

    love.graphics.draw(bigSpriteSheet,playerQuad,(scene.cameraPos[1]-1) * scale * spriteSize+width/2,(scene.cameraPos[3]-.25) * scale * spriteSize+(height-20*spriteSize*scale)/2,0,scale,scale)
    for i=0,height/(spriteSize*scale) do
        love.graphics.draw(bigSpriteSheet,railQuad,width/2-scale*spriteSize,i*spriteSize*scale,0,scale,scale)
    end
    for i=1,(width/2)/(spriteSize*scale) do
        love.graphics.draw(bigSpriteSheet,railQuad,width/2+i*scale*spriteSize,0,math.pi/2,scale,scale)
    end
    for i=0,scene.craneChain.z+2 do
        love.graphics.draw(bigSpriteSheet,chainQuad,width/2-(scale*spriteSize)/2 + (scene.craneChain.x + scene.craneChain.subX-.5) * scale * spriteSize,(i+scene.craneChain.subZ+.5)*spriteSize*scale,0,scale,scale)
    end
    love.graphics.draw(bigSpriteSheet,rollerQuad,width/2-spriteSize*scale*1.5,height-scale*spriteSize,0,scale,scale)
    love.graphics.draw(bigSpriteSheet,wheelQuad,width/2 - spriteSize*scale,0,0,scale,scale)
    if (scene.lever) then
        love.graphics.draw(bigSpriteSheet,leverQuad,width/2 + scale*spriteSize*(currentScene.lever.x),(height-20*spriteSize*scale)/2 + (currentScene.lever.z + currentScene.lever.subZ) * spriteSize * scale,0,scale,scale)
    end
    love.graphics.setColor(0,0,0,1)
    love.graphics.circle("line",323,height-120+23,30)
    love.graphics.circle("line",123,height-120+23,30)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(glueSplat,300,height-120,0,.2,.2)
    love.graphics.draw(water,100,height-120,0,.2,.2)
    love.graphics.draw(textE,305,height-150,0,.6,.6)
    love.graphics.draw(textQ,105,height-150,0,.6,.6)
    love.graphics.draw(textW,205,height-150,0,.6,.6)
    love.graphics.draw(textA,175,height-120,0,.6,.6)
    love.graphics.draw(textS,205,height-120,0,.6,.6)
    love.graphics.draw(textD,235,height-120,0,.6,.6)
    love.graphics.draw(arrow,209,height-175,0,2,2)
    love.graphics.draw(arrow,240,height-57,math.pi,2,2)
    love.graphics.draw(rightArrow,269,height-110,0,1.5,1.5)
    love.graphics.draw(leftArrow,155,height-110,0,1.5,1.5)
    love.graphics.draw(mouseMove,3*width/4,height-60)
    love.graphics.draw(leftClick,3*width/4-60,height-60)
    love.graphics.draw(rightClick,3*width/4+60,height-60)
    love.graphics.draw(arrow,3*width/4-45,height-80,0,2,2)
    love.graphics.draw(arrow,3*width/4+105,height-50,math.pi,2,2)
    love.graphics.setFont(font)
    love.graphics.setColor(1,.4,.2,1)
    love.graphics.print("Stack the crates to reach the lever",width-((instructions:getWidth())+50),50)
    love.graphics.setColor(1,1,1,1)
end