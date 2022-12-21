#version 430

uniform sampler2D texture0;
in vec2 uv;
out vec4 fragColor;

uniform vec2 boundary;
uniform vec2 padding;
uniform vec3 color;

float gt(float v1, float v2)
{
    return step(v2,v1);
}

float lt(float v1, float v2)
{
    return step(v1, v2);
}

void main() {
    vec4 text = texture(texture0, uv);
    float bound = 1.;
    bound *= gt(uv.x, padding.x/boundary.x);
    bound *= lt(uv.x, (boundary.x-padding.x)/boundary.x);
    bound *= gt(uv.y, padding.y/boundary.y);
    bound *= lt(uv.y, (boundary.y-padding.y)/boundary.y);
    bound = 1.-bound;
    fragColor = text + vec4(color*bound,1);
}
