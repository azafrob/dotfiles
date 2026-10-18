// Inverted Night Vision Shader for Hyprland
// Inverts colors and applies green night vision tint
// ES 3.00 compatible
#version 300 es
precision mediump float;
// ===== CONFIGURATION =====
#define INVERSION_STRENGTH 1.0     // 1.0 = full inversion, 0.5 = partial
#define GREEN_TINT_STRENGTH 0.8    // How strong the green tint is (0.0-1.0)
#define BRIGHTNESS_BOOST -0.4       // Additional brightness for visibility
// ========================
// Standard Hyprland shader inputs
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;
void main() {
    // Sample the screen texture
    vec4 color = texture(tex, v_texcoord);
    vec3 rgb = color.rgb;
    
    // Apply color inversion
    vec3 inverted = mix(rgb, 1.0 - rgb, INVERSION_STRENGTH);
    
    // Add brightness boost for better visibility in dark areas
    inverted += BRIGHTNESS_BOOST;
    
    // Apply green night vision tint
    if(GREEN_TINT_STRENGTH > 0.0) {
        // Calculate luminance for green channel
        float luminance = dot(inverted, vec3(0.299, 0.587, 0.114));
        
        // Create green-tinted version
        vec3 greenTinted = vec3(0.0, luminance, 0.0);
        
        // Blend between inverted colors and green tint
        rgb = mix(inverted, greenTinted, GREEN_TINT_STRENGTH);
    } else {
        rgb = inverted;
    }
    
    // Clamp to valid range
    rgb = clamp(rgb, 0.0, 1.0);
    
    // Preserve alpha
    fragColor = vec4(rgb, color.a);
}
