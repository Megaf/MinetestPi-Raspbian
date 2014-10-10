uniform mat4 mWorldViewProj;
uniform mat4 mInvWorld;
uniform mat4 mTransWorld;
uniform mat4 mWorld;

uniform float dayNightRatio;
uniform vec3 eyePosition;
uniform float animationTimer;

varying vec3 vPosition;
varying vec3 worldPosition;

varying vec3 eyeVec;
varying vec3 lightVec;
varying vec3 tsEyeVec;
varying vec3 tsLightVec;

const float e = 2.718281828459;
const float BS = 10.0;

float smoothCurve( float x ) {
  return x * x *( 3.0 - 2.0 * x );
}
float triangleWave( float x ) {
  return abs( fract( x + 0.5 ) * 2.0 - 1.0 );
}
float smoothTriangleWave( float x ) {
  return smoothCurve( triangleWave( x ) ) * 2.0 - 1.0;
}

void main(void)
{
	gl_TexCoord[0] = gl_MultiTexCoord0;
	
#if (MATERIAL_TYPE == TILE_MATERIAL_LIQUID_TRANSPARENT || MATERIAL_TYPE == TILE_MATERIAL_LIQUID_OPAQUE) && ENABLE_WAVING_WATER
	vec4 pos = gl_Vertex;
	pos.y -= 2.0;
	pos.y -= sin (pos.z/WATER_WAVE_LENGTH + animationTimer * WATER_WAVE_SPEED * WATER_WAVE_LENGTH) * WATER_WAVE_HEIGHT
		+ sin ((pos.z/WATER_WAVE_LENGTH + animationTimer * WATER_WAVE_SPEED * WATER_WAVE_LENGTH) / 7.0) * WATER_WAVE_HEIGHT;
	gl_Position = mWorldViewProj * pos;
#elif MATERIAL_TYPE == TILE_MATERIAL_WAVING_LEAVES && ENABLE_WAVING_LEAVES
	vec4 pos = gl_Vertex;
	vec4 pos2 = mWorld * gl_Vertex;
	pos.x += (smoothTriangleWave(animationTimer*10.0 + pos2.x * 0.01 + pos2.z * 0.01) * 2.0 - 1.0) * 0.4;
	pos.y += (smoothTriangleWave(animationTimer*15.0 + pos2.x * -0.01 + pos2.z * -0.01) * 2.0 - 1.0) * 0.2;
	pos.z += (smoothTriangleWave(animationTimer*10.0 + pos2.x * -0.01 + pos2.z * -0.01) * 2.0 - 1.0) * 0.4;
	gl_Position = mWorldViewProj * pos;
#elif MATERIAL_TYPE == TILE_MATERIAL_WAVING_PLANTS && ENABLE_WAVING_PLANTS
	vec4 pos = gl_Vertex;
	vec4 pos2 = mWorld * gl_Vertex;
	if (gl_TexCoord[0].y < 0.05) {
	pos.x += (smoothTriangleWave(animationTimer * 20.0 + pos2.x * 0.1 + pos2.z * 0.1) * 2.0 - 1.0) * 0.8;
			pos.y -= (smoothTriangleWave(animationTimer * 10.0 + pos2.x * -0.5 + pos2.z * -0.5) * 2.0 - 1.0) * 0.4;
	}
	gl_Position = mWorldViewProj * pos;
#else
	gl_Position = mWorldViewProj * gl_Vertex;
#endif

	vPosition = gl_Position.xyz;
	worldPosition = (mWorld * gl_Vertex).xyz;
	vec3 sunPosition = vec3 (0.0, eyePosition.y * BS + 900.0, 0.0);

	vec3 normal, tangent, binormal;
	normal = normalize(gl_NormalMatrix * gl_Normal);
	if (gl_Normal.x > 0.5) {
		//  1.0,  0.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0, -1.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.x < -0.5) {
		// -1.0,  0.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.y > 0.5) {
		//  0.0,  1.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	} else if (gl_Normal.y < -0.5) {
		//  0.0, -1.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	} else if (gl_Normal.z > 0.5) {
		//  0.0,  0.0,  1.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.z < -0.5) {
		//  0.0,  0.0, -1.0
		tangent  = normalize(gl_NormalMatrix * vec3(-1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	}
	mat3 tbnMatrix = mat3(	tangent.x, binormal.x, normal.x,
							tangent.y, binormal.y, normal.y,
							tangent.z, binormal.z, normal.z);

	lightVec = sunPosition - worldPosition;
	tsLightVec = lightVec * tbnMatrix;
	eyeVec = (gl_ModelViewMatrix * gl_Vertex).xyz;
	tsEyeVec = eyeVec * tbnMatrix;

	gl_FrontColor = gl_BackColor = gl_Color;
}
