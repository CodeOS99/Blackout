shader_type canvas_item;

uniform float snow_speed : hint_range(0.1, 3.0) = 1.5;
uniform float particle_density : hint_range(0.0, 1.0) = 0.4;
uniform float wind_chaos : hint_range(0.0, 2.0) = 1.2;
uniform float vignette_amount : hint_range(0.0, 0.4) = 0.12;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float hash13(vec3 p3) {
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
    vec2 uv = UV;
    float alpha = 0.0;
    
    // Tiny zippy particles - super fast diagonal movement
    for (float i = 0.0; i < 3.0; i++) {
        vec2 zip_uv = uv * vec2(60.0 + i * 10.0, 45.0 + i * 8.0);
        float speed_mult = 2.0 + i * 0.5;
        zip_uv.y += TIME * snow_speed * 8.0 * speed_mult;
        zip_uv.x += TIME * wind_chaos * 3.0 * speed_mult;
        zip_uv.x += sin(TIME * 3.0 + uv.y * 15.0) * wind_chaos * 0.8;
        
        float particle = hash(floor(zip_uv));
        float size = hash13(vec3(floor(zip_uv), i));
        
        if (particle > 0.98) {
            alpha += 0.15 * particle_density * size;
        }
    }
    
    // Medium speed streaking particles
    vec2 streak_uv = uv * vec2(35.0, 30.0);
    streak_uv.y += TIME * snow_speed * 4.0;
    streak_uv.x += TIME * wind_chaos * 1.5;
    streak_uv.x += cos(TIME * 2.0 + uv.y * 8.0) * wind_chaos * 0.6;
    float streaks = hash(floor(streak_uv));
    if (streaks > 0.95) {
        alpha += 0.2 * particle_density;
    }
    
    // Occasional visible snowflakes
    vec2 snow_uv = uv * vec2(8.0, 12.0);
    snow_uv.y += TIME * snow_speed * 1.2;
    snow_uv.x += sin(TIME * 0.6 + uv.y * 3.0) * wind_chaos * 0.3;
    float snow = hash(floor(snow_uv));
    if (snow > 0.88) {
        alpha += 0.25 * particle_density * 0.8;
    }
    
    // Atmospheric haze/wind effect
    float wind_x = uv.x + TIME * 0.3;
    float wind_y = uv.y * 2.0 + TIME * 0.15;
    float haze = hash(vec2(floor(wind_x * 4.0), floor(wind_y * 3.0)));
    alpha += haze * 0.03;
    
    // Subtle vignette - just darkens the outer edges
    vec2 center = uv - 0.5;
    float dist = length(center);
    float vignette = smoothstep(0.5, 1.2, dist);
    
    // Keep particles white
    vec3 color = vec3(0.95, 0.97, 1.0);
    
    // Apply subtle dark vignette
    float edge_dark = vignette * vignette_amount;
    color = mix(color, vec3(0.3, 0.35, 0.4), edge_dark);
    alpha = max(alpha, edge_dark * 0.5);
    
    // Clamp final alpha to keep it subtle
    alpha = clamp(alpha, 0.0, 0.6);
    
    COLOR = vec4(color, alpha);
}