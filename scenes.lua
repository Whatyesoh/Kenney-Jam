function create3DScene(scene)
    local objects = {}

    scene.objects = objects
    scene.theta = 0
    scene.floor = 0
    scene.onFloor = 1
    scene.playerHeight = 1.1
    scene.speed = 3
    scene.vertSpeed = 0
    scene.cameraPos = {5,scene.floor,5}
    scene.cameraLook = {0,scene.floor,0}
    scene.mouseX = width/2 + 100
    scene.mouseY = height/4
    scene.hovered = 0
    scene.glued = 0
    scene.chainTouching = 0
    scene.chainTimer = 0
    scene.footstepTimer = 0
    scene.changeScene = 0
    scene.sendablePos = {}
    scene.collision = {}
end

function createScenes()
    scenes = {}

    main3DScene = {}

    table.insert(scenes,main3DScene)

    currentScene = main3DScene

    create3DScene(currentScene)

    currentScene.craneChain = {}
    currentScene.craneChain2 = {}
    currentScene.lever = {}

    table.insert(currentScene.collision,{0,0,-1,20,100,1,0})
    table.insert(currentScene.collision,{0,0,20,20,100,1,0})
    table.insert(currentScene.collision,{-1,0,0,1,100,20,0})
    table.insert(currentScene.collision,{20,0,0,1,100,20,0})
    
    createObject(currentScene, dirtFloor,0,0,0,20,0,20,0,0)
    createObject(currentScene, wall,0,0,0,20,1,0,0,0)
    createObject(currentScene, wall,0,0,20,20,1,0,0,0)
    createObject(currentScene, wall,0,0,0,0,1,20,0,0)
    createObject(currentScene, wall,20,0,0,0,1,20,0,0)
    createObject(currentScene,chain,8,0,8,0,50,1,0,0,0,0,currentScene.craneChain)
    createObject(currentScene,chain,8,0,8,1,50,0,0,-.5,0,.5,currentScene.craneChain2)
    createObject(currentScene,lever,19,4,10,0,1,1,0,.5,0,0,currentScene.lever)
    createObject(currentScene,wall,19,4,10,1,1,0,0,0)
    createObject(currentScene,wall,19,4,11,1,1,0,0,0)
    createObject(currentScene,crateTop,19,4,10,1,0,1,0,0)

    createBox(currentScene, crateSide, crateTop, 10, 2, 10, 1, 1, 1,1)
    createBox(currentScene, crateSide, crateTop, 17, 0, 10, 1, 1, 1,2)

    currentScene.map = love.graphics.newCanvas(#currentScene.objects * 6,1)
    mapObjects(currentScene)


    table.insert(scenes,{})
    currentScene = scenes[2]

    create3DScene(currentScene)

    currentScene.craneChain = {}
    currentScene.craneChain2 = {}


    table.insert(currentScene.collision,{0,0,-1,20,100,1,0})
    table.insert(currentScene.collision,{0,0,20,20,100,1,0})
    table.insert(currentScene.collision,{-1,0,0,1,100,20,0})
    table.insert(currentScene.collision,{20,0,0,1,100,20,0})
    
    createObject(currentScene, dirtFloor,0,0,0,20,0,20,0,0)
    createObject(currentScene, wall,0,0,0,20,1,0,0,0)
    createObject(currentScene, wall,0,0,20,20,1,0,0,0)
    createObject(currentScene,chain,9,0,9,0,50,1,0,0,0,0,currentScene.craneChain)
    createObject(currentScene,chain,9,0,9,1,50,0,0,0,0,0,currentScene.craneChain2)

    createBox(currentScene, crateSide, crateTop, 1, 0, 1, 1, 1, 1,1)
    createBox(currentScene, crateSide, crateTop, 1, 0, 2, 1, 1, 1,2)
    createBox(currentScene, crateSide, crateTop, 1, 0, 3, 1, 1, 1,3)
    createBox(currentScene, crateSide, crateTop, 1, 0, 4, 1, 1, 1,4)
    createBox(currentScene, crateSide, crateTop, 1, 0, 5, 1, 1, 1,5)
    createBox(currentScene, crateSide, crateTop, 1, 0, 6, 1, 1, 1,6)
    createBox(currentScene, crateSide, crateTop, 1, 0, 7, 1, 1, 1,7)

    currentScene.map = love.graphics.newCanvas(#currentScene.objects * 6,1)
    mapObjects(currentScene)

end