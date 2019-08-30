#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;

#define PXSIZE -texOffset.s

uniform int STEPS = 30;
uniform float blurRange = 10.0;

float SIGMA = 0.25;

float blurWeight(float x) {
    return exp(-0.5*(x*x)/(SIGMA*SIGMA));
}

vec4 blur(vec2 coord, vec2 dir) {
    vec4 total = vec4(0.0);
    float totalWeight = 0.0;
    for (int step = -STEPS; step <= STEPS; ++step) {
        vec2 texCoord = coord + dir*float(step)/float(STEPS)*blurRange*PXSIZE;
        float weight = blurWeight(float(step)/float(STEPS));
        total += weight*texture(texture, texCoord);
        totalWeight += weight;
    }
    return total / totalWeight;
}

void main(void) {

	vec4 sum = blur(vertTexCoord.st, vec2(1.0,0.0));
				
  gl_FragColor = vec4(sum.rgb, 1.0) * vertColor;  
}
