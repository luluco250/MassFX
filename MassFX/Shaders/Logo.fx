#include "Common.fx"

#if USE_LOGO

namespace MassFX {
	
	texture tLogo <source="MassFX/Textures/logo.png";> { Width=LOGO_ResX; Height=LOGO_ResY; };
	sampler2D sLogo { Texture=tLogo; MagFilter=LINEAR; };
	
	texture tAlpha { Format=R32F; };
	sampler2D sAlpha {Texture=tAlpha;};
	
	uniform float timeleft < source = "timeleft"; >;
	
	float AlphaCalc (v2f i) : SV_Target {
		if (timeleft < LOGO_Time*(1-LOGO_Fade)) return saturate(timeleft/(LOGO_Time*(1-LOGO_Fade)));
		else return 1;
	}
	
	float3 Main(v2f i) : SV_Target {
		float2 coord = i.uv;
		float2 offset = float2(LOGO_OffsetX, LOGO_OffsetY);
		float2 aspectFix = float2(BUFFER_WIDTH/LOGO_ResX, BUFFER_HEIGHT/LOGO_ResY);
		
		float2 finalOffset = float2(LOGO_ResX, LOGO_ResY)/2; //finalOffset of the texture
		
#if LOGO_BoundBorder == 1
		finalOffset -= finalOffset;
		finalOffset -= offset;
#elif LOGO_BoundBorder == 2
		finalOffset.x -= finalOffset.x;
		finalOffset.x -= offset.x;
		finalOffset.y += offset.y;
		finalOffset.y += finalOffset.y;
		finalOffset.y -= BUFFER_HEIGHT;
#elif LOGO_BoundBorder == 3
		finalOffset += finalOffset;
		finalOffset += offset;
		finalOffset -= float2(BUFFER_WIDTH, BUFFER_HEIGHT);
#elif LOGO_BoundBorder == 4
		finalOffset.x += finalOffset.x;
		finalOffset.y -= finalOffset.y;
		finalOffset.x += offset.x;
		finalOffset.y -= offset.y;
		finalOffset.x -= BUFFER_WIDTH;
#else
		finalOffset -= float2(BUFFER_WIDTH, BUFFER_HEIGHT)/2;
#endif
		
		coord *= aspectFix; //fix aspect ratio for the coord
		finalOffset *= aspectFix; //fix aspect ratio for finalOffset
		coord += finalOffset*ReShade::PixelSize;
		
#if (LOGO_BoundBorder == 1 || LOGO_BoundBorder == 4)
		coord.y += (1 - tex2Dfetch(sAlpha, int2(0,0)).x)*(1-LOGO_Fade);
#elif (LOGO_BoundBorder == 2 || LOGO_BoundBorder == 3)
		coord.y -= (1 - tex2Dfetch(sAlpha, int2(0,0)).x)*(1-LOGO_Fade);
#endif
		
		float4 logo = tex2D(sLogo, coord);
		
		return lerp(tex2Dfetch(ReShade::BackBuffer, i.uv), 
			logo, 
			logo.w*tex2Dfetch(sAlpha, int2(0,0)).x
		).rgb; //lerp alpha, similar to a new layer with transparency in gimp/photoshop
	}
	
	technique Logo_Tech <bool enabled=
	#if LOGO_Time > 0
	1; timeout = LOGO_Time; >
	#else
	RESHADE_START_ENABLED; >
	#endif
	{
		pass alphaCalc {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=AlphaCalc;
			RenderTarget=tAlpha;
		}
		
		pass main {
			VertexShader=ReShade::VS_PostProcess;
			PixelShader=Main;
		}
	}
}

#endif