#ifndef INCLUDE_GUARD_MASSFX_COMMON
#define INCLUDE_GUARD_MASSFX_COMMON

#define PI 3.14159265359
#define GAMMA 2.2

#if USE_HDR
	#define FinalSampler sHDR
	#define FinalTarget RenderTarget=tHDR;
#else
	#define FinalSampler ReShade::BackBuffer
	#define FinalTarget 
#endif

namespace MassFX {
	
	texture tHDR { Width=BUFFER_WIDTH; Height=BUFFER_HEIGHT; Format=RGBA16F; };
	sampler2D sHDR { Texture=tHDR; SRGBTexture=false; };
	
	texture tExp { Width=HDR_ExposureResolution; Height=HDR_ExposureResolution; Format=RGBA16F; MipLevels=sqrt(HDR_ExposureResolution); };
	sampler2D sExp { Texture=tExp; };
	
	texture tExposure { Format=R16F; };
	sampler2D sExposure { Texture=tExposure; };
		
	struct v2f {
		float4 pos : SV_Position;
		float2 uv  : TEXCOORD0;
	};
	
	float average(float2 f2) {
		return (f2.x + f2.y)/2;
	}
	
	float average(float3 f3) {
		return (f3.x + f3.y + f3.z)/3;
	}
	
	float average(float4 f4) {
		return (f4.x + f4.y + f4.z + f4.w)/4;
	}
}

#endif