#include "Common.fx"

#if USE_LUT

#pragma message "MassFX: LUT Initialized\n"

namespace MassFX {
	
	texture tLUT <source="MassFX/Textures/LUT.png";> { Width=LUT_ResX; Height=LUT_ResY; Format=RGBA8; };
	sampler2D sLUT { Texture=tLUT; };
	
	float3 Main(v2f i) : SV_Target {
		float2 lutSize = 1 / float2(LUT_ResX, LUT_ResY);
		float3 color = saturate(tex2D(ReShade::BackBuffer, i.uv).rgb);
		color.b *= 15;
		float4 coord = 0;
		coord.w = floor(color.b);
		coord.xy = color.rg * 15 * lutSize + 0.5 * lutSize;
		coord.x += coord.w * lutSize.y;
		return lerp(
			tex2Dfetch(ReShade::BackBuffer, i.uv).rgb,
			lerp(
				tex2D(sLUT, coord.xy).rgb, 
				tex2D(sLUT, coord.xy + float2(lutSize.y, 0)).rgb, 
				color.b - coord.w
			), 
			LUT_Power
		);
	}
	
	technique LUT_Tech <bool enabled=RESHADE_START_ENABLED; int toggle=LUT_ToggleKey; > {
		pass main {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Main;
		}
	}
}

#endif