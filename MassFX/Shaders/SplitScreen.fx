#include "Common.fx"

#if USE_SPLITSCREEN

namespace MassFX {
	
	float3 Main(v2f i) : COLOR {
		if (i.uv.x > BUFFER_WIDTH/2) return tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		else return tex2Dfetch(ReShade::OriginalColor, i.uv).rgb;
	}
	
	technique SplitScreen_Tech <bool enabled=RESHADE_START_ENABLED; int toggle=SPLITSCREEN_ToggleKey;> {
		pass {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Main;
			FinalTarget
		}
	}
}

#endif