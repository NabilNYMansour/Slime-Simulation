#version 430

uniform sampler2D texture0;
in vec2 uv;
out vec4 fragColor;

uniform vec2 boundary;
uniform vec2 padding;
uniform vec3 paddingColor;
uniform vec3 backgroundColor;
uniform bool applyBlur;

// Comparison functions
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
    float out_bound = 1.;
    out_bound *= gt(uv.x, padding.x/boundary.x);
    out_bound *= lt(uv.x, (boundary.x-padding.x)/boundary.x);
    out_bound *= gt(uv.y, padding.y/boundary.y);
    out_bound *= lt(uv.y, (boundary.y-padding.y)/boundary.y);
    float in_bound = 1.-out_bound;

    // Final color
    fragColor = text*out_bound + vec4(paddingColor*in_bound,1) + vec4(backgroundColor,1)*(1.-text.w)*out_bound;
}
