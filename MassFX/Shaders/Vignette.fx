#include "Common.fx"

#if USE_VIGNETTE

#pragma message "MassFX: Vignette Initialized\n"

namespace MassFX {
	float3 Main(v2f i) : SV_Target {
		float2 dist = (i.uv - 0.5) * 1.25;
		dist.x = 1 - dot(dist, dist) * Vignette_Power;
		return (tex2D(ReShade::BackBuffer, i.uv) * dist.x).rgb;
	}
	technique Vignette_Tech <bool enabled = RESHADE_START_ENABLED; int toggle = Vignette_ToggleKey; > {
		pass {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = Main;
		}
	}
}

#endif