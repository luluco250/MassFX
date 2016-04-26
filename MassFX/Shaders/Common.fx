#ifndef INCLUDE_GUARD_MASSFX_COMMON
#define INCLUDE_GUARD_MASSFX_COMMON

#define PI 3.14159265359
#define GAMMA 2.2

namespace MassFX {
	
	texture tHDR { Width=BUFFER_WIDTH; Height=BUFFER_HEIGHT; Format=RGBA16F; };
	sampler2D sHDR { Texture=tHDR; SRGBTexture=true; };
	
	texture tExposure { Format=R32F; };
	sampler2D sExposure { Texture=tExposure; MagFilter=POINT; };
		
	struct v2f {
		float4 pos : SV_Position;
		float2 uv  : TEXCOORD0;
	};
}

#endif