#include "Common.fx"

#if USE_VIGNETTE

#pragma message "MassFX: Vignette Initialized\n"

namespace MassFX {
	float3 Main(v2f i) : COLOR {
		float2 dist = (i.uv - 0.5) * 1.25;
		dist.x = 1 - dot(dist, dist) * VIGNETTE_Power;
		#if VIGNETTE_UseHDRAutoExposure
		dist.x = lerp(dist.x, lerp(1, dist.x, 1 - tex2Dfetch(sExposure, int2(0,0)).r), HDR_VignettePower);
		#endif
		float3 vignette = 1 * dist.x;
		vignette *= VIGNETTE_Tint;
		return tex2D(ReShade::BackBuffer, i.uv).rgb * vignette;
	}
	technique Vignette_Tech <bool enabled = RESHADE_START_ENABLED; int toggle = VIGNETTE_ToggleKey; > {
		pass {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = Main;
		}
	}
}

#endif