#include "Common.fx"

#if USE_GRAIN

#pragma message "MassFX: Grain Initialized\n"

namespace MassFX {
		
	float3 Main(v2f i) : COLOR {
		float2 coord = i.uv;
		coord += ReShade::FrameTime;
		float grain = GRAIN_Brightness - frac(sin(dot(coord,float2(12.9898,78.233))) * 43758.5453); //actual grain "texture"
		float3 col = tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		#if GRAIN_Debug == 1
		col = 0;
		#elif GRAIN_Debug == 2
		col = 1;
		#endif
		float3 avrgCol = col*GRAIN_BrightnessFactor;
		float average = (avrgCol.r + avrgCol.g + avrgCol.b)/3;
		grain = lerp(grain, GRAIN_Brightness, saturate(average));
		#if GRAIN_UseHDRAutoExposure
		grain = saturate(lerp(grain, saturate(lerp(0, grain, tex2Dfetch(sExposure, int2(0,0)).r)), HDR_GrainPower));
		#endif
		#if GRAIN_MixMode == 1
		return lerp(col, col + grain, GRAIN_Power);
		#else
		return lerp(col, col * grain, GRAIN_Power);
		#endif
	}
	
	technique Grain_Tech <bool enabled=RESHADE_START_ENABLED; int toggle=GRAIN_ToggleKey;> {
		
		pass main {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Main;
		}
	}
}

#endif