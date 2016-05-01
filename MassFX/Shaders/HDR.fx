#include "Common.fx"

#if USE_HDR

#pragma message "MassFX: HDR Initialized\n"

namespace MassFX {
	
	texture LinearizedColorTex { Width=BUFFER_WIDTH; Height=BUFFER_HEIGHT; Format=RGBA8; };
	sampler2D LinearizedColor { Texture=LinearizedColorTex; };
	
	float3 ToLinear(v2f i) : COLOR {
		#if HDR_UseSRGB 
		return tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		#else
		float3 col1 = tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		float3 col2 = pow(saturate(col1), 2.2);
		return col1*col2;
		#endif
	}
	
	float3 GetHDR(v2f i) : COLOR {
		#if HDR_UseAutoExposure
		float3 col = pow(abs(tex2D(ReShade::BackBuffer, i.uv).rgb * tex2D(ReShade::BackBuffer, i.uv).rgb), 1 - tex2Dfetch(sExposure, int2(0,0)).r);
		/*float3 col = lerp(
			tex2Dfetch(ReShade::BackBuffer, i.uv).rgb, 
			tex2Dfetch(ReShade::BackBuffer, i.uv).rgb * tex2Dfetch(ReShade::BackBuffer, i.uv).rgb, 
			1 - tex2Dfetch(sExposure, int2(0,0)).x
		);*/
		#else
		float3 col = pow(abs(tex2D(ReShade::BackBuffer, i.uv).rgb * tex2D(ReShade::BackBuffer, i.uv).rgb), 1.5);
		#endif
		//return FilmicCurve(col);
		return lerp(col, tex2Dfetch(ReShade::BackBuffer, i.uv).rgb, 1 - HDR_ImagePower);
	}
	#if HDR_UseAutoExposure
	float3 GetExposure(v2f i) : COLOR {
		return tex2D(ReShade::BackBuffer, i.uv).rgb * HDR_AutoExposureSensitivity;
	}
	
	float SetExposure(v2f i) : COLOR {
		#if HDR_NormalizeAutoExposure
		return HDR_AutoExposurePower - normalize(average(tex2Dlod(sExp, float4(i.uv, 0, sqrt(HDR_ExposureResolution)))));
		#else
		return HDR_AutoExposurePower - saturate(average(tex2Dlod(sExp, float4(i.uv, 0, sqrt(HDR_ExposureResolution)))));
		#endif
	}
	#endif
	technique HDR_Tech <bool enabled=RESHADE_START_ENABLED; int toggle = HDR_ToggleKey; > {
		#if HDR_ConvertToLinear
		pass toLinear {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=ToLinear;
			//RenderTarget=LinearizedColorTex;
			#if HDR_UseSRGB
			SRGBWriteEnable=TRUE;
			#endif
		}
		#endif
		#if HDR_UseAutoExposure
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
		#endif
		pass getHDR {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=GetHDR;
		}
	}
}

#endif