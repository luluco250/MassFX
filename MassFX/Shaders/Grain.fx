#include "Common.fx"

#if USE_GRAIN

#pragma "MassFX: Grain Initialized\n"

namespace MassFX {
		
	float3 Main(v2f i) : COLOR {
		float2 coord = i.uv;
		coord += ReShade::FrameTime;
		float grain = frac(sin(dot(coord,float2(12.9898,78.233))) * 43758.5453);
		float3 col = tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		float3 avrgCol = col*GRAIN_BrightnessFactor;
		float average = (avrgCol.r + avrgCol.g + avrgCol.b)/3;
		grain = lerp(grain, 1, saturate(average));
		return lerp(col, col * grain, GRAIN_Power);
	}
	
	technique Grain_Tech <bool enabled=RESHADE_START_ENABLED; int toggle=GRAIN_ToggleKey;> {
		
		pass main {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Main;
		}
	}
}

#endif