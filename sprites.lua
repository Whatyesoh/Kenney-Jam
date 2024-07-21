function defineSprites()
    dirtFloor = {
        vertical = .5,
        textureWidth = 1,
        textureHeight = 1,
        textureTop = 2,
        textureLeft = 2
    }

    wall = {
        vertical = 1,
        textureWidth = 1,
        textureHeight = 1,
        textureTop = 5,
        textureLeft = 8
    }

    chain = {
        vertical = 1,
        textureWidth = 1,
        textureHeight = 1,
        textureTop = 1,
        textureLeft = 8
    }
    
    crateTop = {
        vertical = .5,
        textureWidth = 1,
        textureHeight = 1,
        textureTop = 3,
        textureLeft = 14,
        glueTop = 0,
        glueLeft = 17
    }

    crateSide = {
        vertical = 1,
        textureWidth = 1,
        textureHeight = 1,
        textureTop = 1,
        textureLeft = 9,
        glueTop = 0,
        glueLeft = 16
    }

    lever = {
        vertical = 1,
        textureWidth = 1,
        textureHeight = 1,
        textureTop = 7,
        textureLeft = 9,
        glueTop = 7,
        glueLeft = 10,
        boxNum = 255
    }
end

function createBox(scene, sides, floor, x, y, z, xLength, yLength, zLength,id)

    createObject(scene,sides,x,y,z,xLength,yLength,0,0,0,0,0,{},id)
    createObject(scene,sides,x,y,z,0,yLength,zLength,0,0,0,0,{},id)
    createObject(scene,sides,x+xLength,y,z,0,yLength,zLength,0,0,0,0,{},id)
    createObject(scene,sides,x,y,z+zLength,xLength,yLength,0,0,0,0,0,{},id)
    createObject(scene,floor,x,y,z,xLength,0,zLength,0,0,0,0,{},id)
    createObject(scene,floor,x,y+yLength,z,xLength,0,zLength,0,0,0,0,{},id)

    table.insert(scene.collision,{x,y,z,xLength,yLength,zLength,id})
end

function createObject(scene,sprite, x, y, z, xlength, yLength, zLength, flip, subX, subY, subZ, id, boxNum)
    local tempObject = id or {}
    tempObject.textureWidth = sprite.textureWidth or 0
    tempObject.textureHeight = sprite.textureHeight or 0
    tempObject.textureTop = sprite.textureTop or 0
    tempObject.textureLeft = sprite.textureLeft or 0
    tempObject.color = sprite.color or {tempObject.textureLeft/255.0,tempObject.textureTop/255.0,tempObject.textureWidth/255.0,1}
    tempObject.vertical = sprite.vertical or 0
    tempObject.x = x
    tempObject.y = y
    tempObject.z = z
    tempObject.xLength = xlength
    tempObject.yLength = yLength
    tempObject.zLength = zLength
    tempObject.subX = subX or 0
    tempObject.subY = subY or 0
    tempObject.subZ = subZ or 0
    tempObject.flip = flip or 0
    tempObject.glueTop = sprite.glueTop or 0
    tempObject.glueLeft = sprite.glueLeft or 0
    tempObject.glueX = 0
    tempObject.glueY = 0
    tempObject.glueZ = 0
    tempObject.vertSpeed = 0
    tempObject.boxNum = boxNum or sprite.boxNum or 0
    tempObject.quad = love.graphics.newQuad(tempObject.textureLeft*spriteSize,tempObject.textureTop*spriteSize,spriteSize * tempObject.textureWidth,spriteSize*tempObject.textureHeight,bigSpriteSheet:getWidth(),bigSpriteSheet:getHeight())
    table.insert(scene.objects,tempObject)
end

function mapObjects(scene)
    local map = scene.map
    love.graphics.setCanvas(map)

    love.graphics.clear()

    for i in pairs(scene.objects) do
        love.graphics.setColor(scene.objects[i].x/255,scene.objects[i].y/255,scene.objects[i].z/255,1)
        love.graphics.points(.5 + (6 * (i-1)),.5)
        if (scene.objects[i].yLength == 0) then
            love.graphics.setColor(0,0,scene.objects[i].zLength/255.0,1)
            love.graphics.points(1.5 + (6 * (i-1)),.5)
            love.graphics.setColor(scene.objects[i].xLength/255.0,0,0,1)
            love.graphics.points(2.5 + (6 * (i-1)),.5)
        elseif (scene.objects[i].xLength == 0) then
            love.graphics.setColor(0,scene.objects[i].yLength/255.0,0,1)
            love.graphics.points(1.5 + (6 * (i-1)),.5)
            love.graphics.setColor(0,0,scene.objects[i].zLength/255.0,1)
            love.graphics.points(2.5 + (6 * (i-1)),.5)    
        else
            love.graphics.setColor(0,scene.objects[i].yLength/255.0,0,1)
            love.graphics.points(1.5 + (6 * (i-1)),.5)
            love.graphics.setColor(scene.objects[i].xLength/255.0,0,0,1)
            love.graphics.points(2.5 + (6 * (i-1)),.5)
        end
        love.graphics.setColor(scene.objects[i].color[1],scene.objects[i].color[2],scene.objects[i].color[3],1)
        love.graphics.points(3.5 + (6 * (i-1)),.5)
        love.graphics.setColor(scene.objects[i].subY,scene.objects[i].vertical,scene.objects[i].textureHeight/255.0,1)
        love.graphics.points(4.5 + (6 * (i-1)),.5)  
        love.graphics.setColor(scene.objects[i].subX,scene.objects[i].boxNum/255,scene.objects[i].subZ,1)
        love.graphics.points(5.5 + (6 * (i-1)),.5)  
    end

    love.graphics.setCanvas()
    local mapImage = love.graphics.newImage(map:newImageData())

    if (mainShader:hasUniform("map")) then
        mainShader:send("map",mapImage)
    end
    if (mainShader:hasUniform("mapWidth")) then
        mainShader:send("mapWidth",mapImage:getWidth())
    end
    if (mainShader:hasUniform("mapHeight")) then
        mainShader:send("mapHeight",mapImage:getHeight())
    end

    love.graphics.setColor(1,1,1,1)
end