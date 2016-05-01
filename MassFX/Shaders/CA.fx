#include "Common.fx"

#if USE_CA

#pragma message "MassFX: Chromatic Aberration Initialized\n"

namespace MassFX {
		
	float3 Main(v2f i) : SV_Target {
		float red = 1 + (i.uv.x-0.5) * (i.uv.x-0.5) + (i.uv.y-0.5) * (i.uv.y-0.5) * 0;
		float green = 1 + (i.uv.x-0.5) * (i.uv.x-0.5) + (i.uv.y-0.5) * (i.uv.y-0.5) * 0;
		float blue = 1 + (i.uv.x-0.5) * (i.uv.x-0.5) + (i.uv.y-0.5) * (i.uv.y-0.5) * 0;
		float2 redDistort = float2(red*(i.uv.x-0.5)+0.5, red*(i.uv.y-0.5)+0.5);
		float2 greenDistort = float2(green*(i.uv.x-0.5)+0.5, green*(i.uv.y-0.5)+0.5);
		float2 blueDistort = float2(blue*(i.uv.x-0.5)+0.5, blue*(i.uv.y-0.5)+0.5);
		return float3(
			tex2Dfetch(ReShade::BackBuffer, redDistort).r,
			tex2Dfetch(ReShade::BackBuffer, greenDistort).g,
			tex2Dfetch(ReShade::BackBuffer, blueDistort).b
		);
		
	}
	technique CA_Tech <bool enabled = RESHADE_START_ENABLED; int toggle = CA_ToggleKey; > {
		pass {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = Main;
		}
	}
}

#endif