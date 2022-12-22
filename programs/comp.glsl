#version 450

#define PI 3.1415926538

layout (local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

// refer to this https://www.khronos.org/opengl/wiki/Layout_Qualifier_(GLSL)

struct Slime {
    float x, y, dx, dy;
};

layout(rgba32f, location=0) uniform image2D texture_buffer;

layout(std430, binding=1) buffer slimes_in {
    Slime slimes[];
};

uniform vec2 boundary;
uniform vec2 padding;

uniform float speed;
uniform float senseDis;
uniform float senseAngle;

uniform bool iSsolidColor;
uniform vec3 solidColor;

/*
   +----------+---------+----------+
    1:x-1,y+1 | 2:x,y+1 | 3:x+1,y+1
   +----------+---------+----------+
    4:x-1, y  | 5:x, y  | 6:x+1,y
   +----------+---------+----------+
    7:x-1,y-1 | 8:x,y-1 | 9:x+1,y-1
   +----------+---------+----------+
*/

vec2 car2pol(vec2 v) {
    float mag = sqrt(v.x*v.x+v.y*v.y);
    float ang = atan(v.y,v.x);
    return vec2(mag, ang);
}

vec2 pol2car(float mag, float ang) {
    float x = mag * cos(ang);
    float y = mag * sin(ang);
    return normalize(vec2(x,y));
}

vec2 vecOffset(vec2 v, float angOffset) {
    vec2 pol = car2pol(v);
    pol.y += angOffset;// angle offseting
    return pol2car(pol.x, pol.y);
}

vec3 senseSlimes(vec2 pos, vec2 dt, vec2 dL, vec2 dR) {
    vec4 forward = imageLoad(texture_buffer, ivec2(pos.x+senseDis*dt.x,pos.y+senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dt.x,pos.y     +senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dt.x,pos.y     +senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x     +senseDis*dt.x,pos.y + 1 +senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x     +senseDis*dt.x,pos.y - 1 +senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dt.x,pos.y + 1 +senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dt.x,pos.y - 1 +senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dt.x,pos.y + 1 +senseDis*dt.y));
    forward += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dt.x,pos.y - 1 +senseDis*dt.y));

    vec4 left = imageLoad(texture_buffer, ivec2(pos.x+senseDis*dL.x,pos.y+senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dL.x,pos.y    +senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dL.x,pos.y    +senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x     +senseDis*dL.x,pos.y + 1 +senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x     +senseDis*dL.x,pos.y - 1 +senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dL.x,pos.y + 1 +senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dL.x,pos.y - 1 +senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dL.x,pos.y + 1 +senseDis*dL.y));
    left += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dL.x,pos.y - 1 +senseDis*dL.y));

    vec4 right = imageLoad(texture_buffer, ivec2(pos.x+senseDis*dR.x,pos.y+senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dR.x,pos.y     +senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dR.x,pos.y     +senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x     +senseDis*dR.x,pos.y + 1 +senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x     +senseDis*dR.x,pos.y - 1 +senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dR.x,pos.y + 1 +senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x + 1 +senseDis*dR.x,pos.y - 1 +senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dR.x,pos.y + 1 +senseDis*dR.y));
    right += imageLoad(texture_buffer, ivec2(pos.x - 1 +senseDis*dR.x,pos.y - 1 +senseDis*dR.y));

    return vec3(left.w, forward.w, right.w);
}

// https://gist.github.com/sugi-cho/6a01cae436acddd72bdf
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main() {
    int index = int(gl_GlobalInvocationID.x);
    // curr slime
    Slime s = slimes[index];

    // remove previous place
    imageStore(texture_buffer, ivec2(s.x,s.y), vec4(0));

    // new slime
    Slime ns;

    // calc new slime position
    vec2 d = normalize(vec2(s.dx,s.dy));
    ns.x = s.x+speed*d.x;
    ns.y = s.y+speed*d.y;

    // calc new slime angle
    ns.dx = d.x;
    ns.dy = d.y;

    // reflections
    if (ns.x > boundary.x - padding.x || ns.x < padding.x) {
        ns.dx = -ns.dx;
    }

    if (ns.y > boundary.y - padding.y || ns.y < padding.y) {
        ns.dy = -ns.dy;
    }

    // sense nearby slime
    vec2 dFor = vec2(ns.dx, ns.dy);
    vec2 dLeft = vecOffset(dFor,-senseAngle);
    vec2 dRight = vecOffset(dFor,senseAngle);
    vec3 sensedSlimes = senseSlimes(vec2(ns.x,ns.y), dFor, dLeft, dRight);

    vec2 dt = (dLeft*sensedSlimes.x+
              dFor  *sensedSlimes.y+
              dRight*sensedSlimes.z+ 
              dFor);

    dt = normalize(dt);

    ns.dx = dt.x;
    ns.dy = dt.y;

    // update slimes
    slimes[index] = ns;

    // draw slimes
    if (iSsolidColor) {
        imageStore(texture_buffer, ivec2(ns.x,ns.y), vec4(solidColor,1));
    } else {
        float varRatio = speed/senseDis;
        imageStore(texture_buffer, ivec2(ns.x,ns.y), vec4(sensedSlimes.r*varRatio,
                                                          sensedSlimes.g/senseAngle,
                                                          sensedSlimes.b/varRatio,1));
    }
}