#include "Common.fx"

#if (USE_HDR == 1 && HDR_UseTonemap == 1)

#pragma message "MassFX: Tonemap Initialized\n"

#if HDR_TonemapUseAutoExposure
	#define exposure saturate(tex2Dfetch(sExposure,int2(0,0)).x)
#else
	#define exposure HDR_TonemapExposure
#endif

#if HDR_TonemapMethod == 0
	#define Method Linear
#elif HDR_TonemapMethod == 1
	#define Method Reinhard
#else
	#define Method FilmicCurve
#endif

#define HardcodedExposure 1

namespace MassFX {
	
	float3 Linear(v2f i) : COLOR {
		float3 col = tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		col *= HardcodedExposure;
		#if HDR_TonemapGammaCorrection
		return pow(saturate(col), 1/GAMMA);
		#else
		return saturate(col);
		#endif
	}
	
	float3 Reinhard(v2f i) : COLOR {
		float3 col = tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		col *= HardcodedExposure;
		col = col/(1+col);
		#if HDR_TonemapGammaCorrection
		return pow(saturate(col), 1/GAMMA);
		#else
		return saturate(col);
		#endif
	}
	
	float3 FilmicCurve(v2f i) : COLOR {
		float3 col = tex2D(ReShade::BackBuffer, i.uv).rgb;
		float3 x = max(0, col - 0.004);
		#if HDR_TonemapGammaCorrection
		return pow((x * (HDR_TonemapFactor * x + exposure)) / (x * (HDR_TonemapFactor * x + HDR_TonemapWhitePoint) + 0.06), GAMMA);
		#else
		return (x * (HDR_TonemapFactor * x + exposure)) / (x * (HDR_TonemapFactor * x + HDR_TonemapWhitePoint) + 0.06);
		#endif
	}
	#if HDR_TonemapWhiteFix
	float3 FixWhites(v2f i) : COLOR {
		return tex2Dfetch(ReShade::BackBuffer, i.uv).rgb / HDR_TonemapWhiteFixWhitePoint;
	}
	#endif
	technique Tonemap_Tech <bool enabled=RESHADE_START_ENABLED; int toggle=HDR_ToggleKey;> {
		pass tonemap {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Method;
		}
		#if HDR_TonemapWhiteFix
		pass fixWhites {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=FixWhites;
		}
		#endif
	}
}

#endif