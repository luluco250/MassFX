#include "Common.fx"

#if USE_VD

#pragma message "MassFX: View Depth Initialized\n"

namespace MassFX {
	
	float3 Main(v2f i) : SV_Target {
		return tex2Dfetch(ReShade::LinearizedDepth, i.uv).rrr;
	}
	
	technique VD_Tech <bool enabled=false; int toggle=VD_ToggleKey;> {
		pass {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Main;
		}
	}
}

#endif