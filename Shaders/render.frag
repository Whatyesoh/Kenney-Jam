extern vec3 lookFrom = vec3(1.5,1.5,-3);
extern vec3 lookAt = vec3(1.5,1.5,-2);
extern Image spriteSheet;
extern float spriteSheetWidth;
extern float spriteSheetHeight;
extern Image map;
extern float mapWidth;
extern float mapHeight;
extern float selected;
float spriteSize = 18;

struct ray {
    vec3 orig;
    vec3 dir;
};

struct quad {
    vec3 Q;
    vec3 u;
    vec3 v;
    vec4 color;
    vec4 texInfo;
    float id;
};

struct hit {
    vec4 color;
    float t;
    bool hit;
    float layer;
    float id;
    bool transparent;
};

struct hitTransparent {
    vec4 color;
    float t;
    float id;
};

vec3 rayAt (ray r, float t) {
    return r.orig + t * r.dir;
}

bool quadHit(quad q, ray r, in hit inHit, out hit outHit, in hitTransparent iHT, out hitTransparent oHT) {

    outHit = inHit;
    oHT = iHT;

    vec3 n = cross(q.u,q.v);
    vec3 normal = normalize(n);
    float denom = dot(normal,r.dir);

    if (abs(denom) <= 1e-8) {
        return false;
    }

    float t = (dot(normal,q.Q) - dot(normal,r.orig))/denom;

    if (t < 0) {
        return false;
    }
    if (t > inHit.t) {
        return false;
    }

    vec3 intersection = rayAt(r,t);

    vec3 planarHitptVector = intersection - q.Q;
    vec3 w = n / dot(n,n);
    float alpha = dot(w,cross(planarHitptVector, q.v));
    float beta = dot(w,cross(q.u,planarHitptVector));

    if (alpha > 1 || alpha < 0 || beta > 1 || beta < 0 ) {
        return false;
    }

    outHit.t = t;
    outHit.color = q.color;
    outHit.hit = true;
    outHit.layer = q.texInfo.r;
    outHit.id = 1;
    outHit.transparent = false;

    if (q.texInfo.g > 0) {
        bool vertical = false;
        vec4 textureColor;

        if (q.texInfo.g == 1) {
            vertical = true;
        }

        vec3 uvHit = rayAt(r,t) - q.Q;
        if (vertical) {
            float quadHeight = q.u.y + q.v.y;
            float quadWidth = sqrt(pow(q.u.x + q.v.x,2) + pow(q.u.z + q.v.z,2));
            if (quadWidth > quadHeight) {
                outHit.color.g = fract((quadWidth/quadHeight)*(1 - uvHit.y / quadWidth));
                outHit.color.b = fract((quadWidth/quadHeight)*(1 * sqrt(uvHit.x * uvHit.x + uvHit.z * uvHit.z) / quadWidth));
            }
            else {
                outHit.color.g = fract((1/quadWidth)*(1 - uvHit.y / quadWidth));
                outHit.color.b = fract((1/quadWidth)*(1 * sqrt(uvHit.x * uvHit.x + uvHit.z * uvHit.z) / quadWidth));   
            }
        }
        //MUST BE NOT BE ROTATED!!!!
        else {
            float quadHeight = q.u.z + q.v.z;
            float quadWidth = q.u.x + q.v.x; 

            outHit.color.g = fract(((quadWidth/(q.color.b*255)))*uvHit.z / quadHeight);
            outHit.color.b = fract(((quadHeight/(q.texInfo.b*255)))*uvHit.x / quadWidth);
        }

        textureColor = Texel(spriteSheet,vec2(
            (floor(outHit.color.b * q.color.b * 255 * spriteSize) + spriteSize * 255 * q.color.r+.5)/spriteSheetWidth,
            (floor(outHit.color.g * q.texInfo.b * 255 * spriteSize) + spriteSize * 255 * q.color.g+.5)/spriteSheetHeight
        ));

        if (textureColor.a < 1) {
            outHit = inHit;
            outHit.transparent = true;
            if (t < oHT.t && textureColor.a > 0) {
                oHT.t = t;
                oHT.color = textureColor;
                if (vertical) {
                    oHT.id = 244.0/255;
                }
            }
        }
        else {
            outHit.color = textureColor;
            if (vertical) {
                outHit.id = 244.0/255;
            }
        }
    }

    /*
    if (q.id == 1) {
        outHit.color *= vec4(.5,.7,1,1);
    }
    */

    outHit.id = q.id / 255.0;

    return true;

}

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 xy) {

    float width = xy.x / uv.x;
    float height = xy.y / uv.y;
    float vPHeight = 2;
    float vPWidth = vPHeight * (width/height);


    vec3 cameraCenter = lookFrom;
    float focalLength = 1;
    vec3 vup = normalize(vec3(0,1,0));
    vec3 w = normalize(lookFrom-lookAt);
    vec3 u = normalize(cross(vup,w));
    vec3 v = cross(w,u);
    vec3 vPU = vPWidth * u;
    vec3 vPV = vPHeight * -v;
    vec3 pDU = vPU / width;
    vec3 pDV = vPV / height;
    vec3 vUL = cameraCenter - (focalLength * w) - vPU/2 - vPV/2;
    vec3 pixelOrigin = vUL + .5 * pDV + .5 * pDU;

    ray r;
    r.orig = cameraCenter;
    r.dir = pixelOrigin + xy.x * pDU + xy.y * pDV - r.orig;
    vec3 point = r.orig;
    r.dir = normalize(r.dir);

    hit oldHit;
    hit newHit;

    hitTransparent oldHitT;
    hitTransparent newHitT;

    oldHit.t = 1000;
    oldHit.color = vec4(.5,.7,1,1);
    oldHit.hit = false;
    oldHit.layer = 0;
    oldHit.id = 0;
    oldHit.transparent = false;

    newHit = oldHit;

    oldHitT.t = 1000;
    oldHitT.color = vec4(0,0,0,0);
    oldHitT.id = 1;

    newHitT = oldHitT;

    quad currentQuad;


    for (int i = 0; i < mapWidth; i += 6) {
        oldHit = newHit;
        oldHitT = newHitT;
        currentQuad.Q = Texel(map,vec2((.5 + 0 + i)/mapWidth,(.5)/mapHeight)).rgb * 255;
        currentQuad.Q.rb += Texel(map,vec2((.5 + 5 + i)/mapWidth,(.5)/mapHeight)).rb;
        currentQuad.id = Texel(map,vec2((.5 + 5 + i)/mapWidth,(.5)/mapHeight)).g * 255;
        currentQuad.u = Texel(map,vec2((.5 + 1 + i)/mapWidth,(.5)/mapHeight)).rgb * 255;
        currentQuad.v = Texel(map,vec2((.5 + 2 + i)/mapWidth,(.5)/mapHeight)).rgb * 255;
        currentQuad.color = Texel(map,vec2((.5 + 3 + i)/mapWidth,(.5)/mapHeight));
        currentQuad.texInfo = Texel(map,vec2((.5 + 4 + i)/mapWidth,(.5)/mapHeight));
        currentQuad.Q.g += currentQuad.texInfo.r;
        quadHit(currentQuad,r,oldHit,newHit,oldHitT,newHitT);
    }

    vec4 outputColor;

    if (newHitT.t <= newHit.t) {
        outputColor = newHit.color * (1-newHitT.color.a) + newHitT.color;
    }
    else {
        outputColor = newHit.color;
    }

    if (xy.y >= height/2 + 98 && xy.y <= height/2 + 102 && xy.x >= width/2 -2 && xy.x <= width/2+2) {
        outputColor.r = newHit.id;
        outputColor.a = 1;
        return outputColor; 
    }
    if (newHit.transparent == false) {
        if (newHit.id*255 == int(selected) && selected > 0) {
            outputColor.a = 1;
            return outputColor * vec4(.6,.75,1,1);
        }
    }

    outputColor.a = 1;
    return outputColor;

}