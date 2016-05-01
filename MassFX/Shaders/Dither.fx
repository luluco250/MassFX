#include "Common.fx"

#if USE_DITHER

namespace MassFX {

	/*static const int pattern[] = {
		0, 32,  8, 40,  2, 34, 10, 42,
		48, 16, 56, 24, 50, 18, 58, 26,
		12, 44,  4, 36, 14, 46,  6, 38,
		60, 28, 52, 20, 62, 30, 54, 22,
		3, 35, 11, 43,  1, 33,  9, 41,
		51, 19, 59, 27, 49, 17, 57, 25,
		15, 47,  7, 39, 13, 45,  5, 37,
		63, 31, 55, 23, 61, 29, 53, 21 
	};
	*/
	
	float3 Dither(v2f i) : COLOR {
		float3 col = tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		return col;
	}
	
	technique Dither_Tech <bool enabled=RESHADE_START_ENABLED; int toggle=DITHER_ToggleKey;> {
		pass dither {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Dither;
		}
	}
}

#endif