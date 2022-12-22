#version 450

layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba32f, location=0) uniform image2D texture_buffer;

void main() {
    ivec2 index = ivec2(gl_GlobalInvocationID.xy);

    vec4 col = imageLoad(texture_buffer, index);

    imageStore(texture_buffer, index, vec4(max(col.xyz-vec3(0.01)*(1.-col.w), vec3(0)), col.w));
}
