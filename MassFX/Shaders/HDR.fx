#include "Common.fx"

#define HDRfactor 0.2

namespace MassFX {
	
	texture tExp { Width=BUFFER_WIDTH; Height=BUFFER_HEIGHT; Format=RGBA8; };
	sampler2D sExp { Texture=tExp; };
	
	float3 GetHDR(v2f i) : SV_Target {
		float3 col = pow(abs(tex2Dfetch(ReShade::BackBuffer, i.uv).rgb * tex2Dfetch(ReShade::BackBuffer, i.uv).rgb), 1 - HDR_Exposure);
		float3 desat = (col.r + col.g + col.b)/3;
		return lerp(desat, col, saturate(HDR_Saturation));
	}
	
	float3 GetExposure(v2f i) : SV_Target {
		return tex2Dfetch(sHDR, i.uv).rgb;
	}
	
	float3 SetExposure(v2f i) : SV_Target {
		float toReturn = 0;
		float f = 0;
		[loop]
		for (int x=0; x<HDR_ExposureResolution; ++x) {
			[unroll]
			for (int y=0; y<HDR_ExposureResolution; ++y) {
				float color = (tex2D(sExp, float2(x, y)).r + tex2D(sExp, float2(x, y)).g + tex2D(sExp, float2(x, y)).b)/3;
				toReturn = saturate(toReturn+color);
				++f;
			}
		}
		return 1 - toReturn/f;
	}
	
	technique HDR_Tech <bool enabled=RESHADE_START_ENABLED; int toggle = RESHADE_TOGGLE_KEY; > {
				
		pass getHDR {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=GetHDR;
			RenderTarget=tHDR;
		}
		
		pass getExposure {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=GetExposure;
			RenderTarget=tExp;
		}
		
		pass setExposure {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=SetExposure;
			RenderTarget=tExposure;
		}
		#if HDR_DebugExposure
		pass debugExposure {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=DebugExposure;
		}
		#endif
	}
}