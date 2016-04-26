#include "Common.fx"

#if USE_MBMB

#pragma message "MassFX: Mouse-Based Motion Blur Initialized\n"

namespace MassFX {
	
	#ifdef region //Textures and samplers
	texture _mPos { Format=RG16F; }; //texture used as a vector for storing the last mouse position
	sampler2D _sPos { Texture=_mPos; };
	
	texture _vel { Format=RG16F; }; //texture used as a vector for storing the calculated velocity
	sampler2D _sVel { Texture=_vel; };
	#endif
	
	#ifdef region //Store mouse position
	float2 StoreMousePos() : SV_Target {
		return ReShade::MouseCoords;
	}
	#endif
	
	#ifdef region //Calculate velocity
	float2 CalculateVelocity() : SV_Target {
		float2 lastPos = (tex2Dfetch(_sPos, int2(0,0))).xy;
		float2 mousePos = ReShade::MouseCoords;
		return (float2(lastPos - mousePos) / ReShade::FrameTime)*MBMB_Velocity; //this is the actual velocity code, it also takes account of how much velocity is defined in MBMB_Velocity which allows countering too high blur and blurring in menus (where mouse movement is naturally slower)
	}
	#endif
	
	#ifdef region //Motion blur
	float4 Blur(int2 scale, float4 tex, float2 coord) {
		float4 color = tex;
		int c = 1; //color correction, so that blur doesn't affect image brightness, using MBMB_Samples directly to determine this value doesn't seem to be precise enough
		[loop]
		for(int i = 1; i < MBMB_Samples+1; ++i) { 
			float2 srcCoord = coord + i * ReShade::PixelSize * scale;
			color += tex2Dfetch(ReShade::BackBuffer, srcCoord);
			c+=1;
			srcCoord = coord - i * ReShade::PixelSize * scale;
			color += tex2Dfetch(ReShade::BackBuffer, srcCoord);
			c+=1;
		}
		
		return color/c;
	}
	#endif
	
	#ifdef region //Main function
	float3 Main(v2f i) : SV_Target {
		float2 velocity = (tex2Dfetch(_sVel, int2(0,0))).xy;
		#if MBMB_UseDepth
		float4 col = lerp(Blur(velocity, tex2Dfetch(ReShade::BackBuffer, i.uv), i.uv.xy), tex2Dfetch(ReShade::BackBuffer, i.uv), tex2Dfetch(ReShade::LinearizedDepth, i.uv).r*MBMB_DepthWeight);
		#else
		float4 col = Blur(velocity, tex2Dfetch(ReShade::BackBuffer, i.uv), i.uv.xy);
		#endif
		return col.rgb;
	}
	#endif
	
	technique MBMB_Tech <bool enabled = RESHADE_START_ENABLED; int toggle = MBMB_ToggleKey; > {
		
		pass calcVelocity{
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = CalculateVelocity;
			RenderTarget = _vel;
		}
		
		pass main {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = Main;
		}
		
		pass storeMousePos {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = StoreMousePos;
			RenderTarget = _mPos;
		}
	}
}

#endif