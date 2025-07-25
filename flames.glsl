// Simple 2D Flame Shader using Perlin Noise + Thresholding
// Copy this code into Shadertoy (shadertoy.com)

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float perlin(vec2 p, float amplitude) {
    float value = 0.0;
    // float amplitude = 0.6;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Add twirling distortion that increases with height
    float twirl = sin(uv.x * 8.0 + iTime * 4.0) * uv.y * uv.y;
    uv.x += twirl;
    
    // Scale and animate the noise
    vec2 noisePos = vec2(uv.x * 15.0, uv.y * 8.0 - iTime * 2.0);
    
    // Generate Perlin noise
    float noise = perlin(noisePos,  uv.y * 5.0 + 0.5 );

    
    // Create threshold that decreases with height
    float threshold = 0.8 - uv.y * 1.8;

    // float threshold = 0.5; 
    
    // Threshold the noise to create flame shape
    float flame = step(noise, threshold);


    // Create flame colors based on height
    vec3 color = vec3(0.0);
    if (flame > 0.0) {
        vec3 purpleColor = vec3(0.6, 0.0, 0.7);
        color = purpleColor;
        // vec3 orangeColor = vec3(1.0, 0.6, 1.0);
        
        // color = mix(blueColor, orangeColor, uv.y / 0.2);
    }

    
    fragColor = vec4(color * flame, 1.0);
}