#version 430

uniform sampler2D texture0;
in vec2 uv;
out vec4 fragColor;

uniform vec2 boundary;
uniform vec2 padding;
uniform vec3 paddingColor;
uniform vec3 backgroundColor;
uniform bool applyBlur;

float gt(float v1, float v2)
{
    return step(v2,v1);
}

float lt(float v1, float v2)
{
    return step(v1, v2);
}

void main() {
    // texture val
    vec4 text = texture(texture0, uv);

    // blur
    if (applyBlur) {
        int blurRadius = 1;
        for (int i = -blurRadius; i <= blurRadius; ++i) {
            for (int j = -blurRadius; j <= blurRadius; ++j) {
                vec2 offset = vec2(i/boundary.x, j/boundary.y);
                text += texture(texture0, uv+offset);
            }
        }
        text /= blurRadius*9;
    }

    // boundary
    float bound = 1.;
    bound *= gt(uv.x, padding.x/boundary.x);
    bound *= lt(uv.x, (boundary.x-padding.x)/boundary.x);
    bound *= gt(uv.y, padding.y/boundary.y);
    bound *= lt(uv.y, (boundary.y-padding.y)/boundary.y);
    bound = 1.-bound;

    // Final color
    fragColor = text*(1.-bound) + vec4(paddingColor*bound,1) + vec4(backgroundColor,1)*(1.-text.w)*(1.-bound);
}
