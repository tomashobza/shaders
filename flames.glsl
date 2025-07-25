// Enhanced Pointy Flames Shader with Multiple Perlin Noise Layers
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
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.xy;
    
    // Generate additional twirl noise for more pointed flames
    vec2 twirlNoisePos = vec2(uv.x * 12.0, uv.y * 6.0 - iTime * 1.5);
    float twirlNoise = perlin(twirlNoisePos, 0.3);
    
    // Enhanced twirling distortion with multiple layers
    float baseTwirl = sin(uv.x * 8.0 + iTime * 4.0) * uv.y * uv.y;
    float pointyTwirl = twirlNoise * uv.y * uv.y * 0.8; // Noise-based twirl
    float sharpTwirl = sin(uv.x * 20.0 + iTime * 6.0) * pow(uv.y, 3.0) * 0.3; // Higher frequency for sharpness
    
    // Combine all twirl effects
    uv.x += baseTwirl + pointyTwirl + sharpTwirl;
    
    // Add vertical stretching effect for more pointed tips
    float stretch = pow(uv.y, 1.5) * 0.2;
    uv.y += stretch * sin(uv.x * 15.0 + iTime * 3.0);
    
    // Scale and animate the main noise
    vec2 noisePos = vec2(uv.x * 15.0, uv.y * 8.0 - iTime * 2.0);
    
    // Generate main Perlin noise
    float mainNoise = perlin(noisePos, uv.y * 5.0 + 0.5);
    
    // Add secondary detail noise for more texture
    vec2 detailPos = vec2(uv.x * 25.0, uv.y * 12.0 - iTime * 3.0);
    float detailNoise = perlin(detailPos, 0.2) * uv.y;
    
    // Combine noises
    float combinedNoise = mainNoise + detailNoise;
    
    // Create more aggressive threshold that creates sharper points
    float threshold = 0.85 - uv.y * 2.2 - pow(uv.y, 2.5) * 0.5;
    
    // Threshold the noise to create flame shape
    float flame = step(combinedNoise, threshold);
    
    // Create flame colors based on noise values
    vec3 color = vec3(0.0);
    if (flame > 0.0) {
        // Convert hex colors to RGB
        vec3 lowNoiseColor = vec3(255.0/255.0, 255.0/255.0, 212.0/255.0); // #A280D4
        // rgb(183, 0, 255)
        vec3 highNoiseColor = vec3(183.0/255.0, 0.0/255.0, 255.0/255.0);

        // Normalize noise value to 0-1 range for color mixing
        float normalizedNoise = (combinedNoise + 1.0) * 0.5;
        normalizedNoise = clamp(normalizedNoise, 0.0, 1.0);
        
        // Mix colors based on noise value
        color = mix(lowNoiseColor, highNoiseColor, normalizedNoise);
        
        // Add slight intensity variation
        color *= 1.0 + detailNoise * 0.2;
    }
    
    fragColor = vec4(color * flame, 1.0);
}