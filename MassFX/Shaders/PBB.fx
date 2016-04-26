#include "Common.fx"

#if USE_PBB

#pragma message "MassFX: Physically-Based Bloom Initialized\n"

#ifndef sclX
	#define sclX (BUFFER_WIDTH*PBB_ResolutionScale)
#endif
#ifndef sclY
	#define sclY (BUFFER_HEIGHT*PBB_ResolutionScale)
#endif

#if (PBB_Passes % 2 == 0)
	#define target sTarget2
#else
	#define target sTarget1
#endif

namespace MassFX {
	
	#ifdef region //Textures and samplers
	texture tDirt <source="MassFX/Textures/lensDirt.png";> {Width=PBB_DirtResX; Height=PBB_DirtResY; Format=RGBA8; };
	sampler2D sDirt { Texture=tDirt; };
	
	texture target1 { Width=BUFFER_WIDTH; Height=BUFFER_HEIGHT; Format=RGBA16F; };
	sampler2D sTarget1 { Texture=target1; };
	
	texture target2 { Width=BUFFER_WIDTH; Height=BUFFER_HEIGHT; Format=RGBA16F; };
	sampler2D sTarget2 { Texture=target2; };
	
	texture tex1 { Width=sclX/2; Height=sclY/2; Format=RGBA16F; };
	sampler2D sTex1 { Texture=tex1; };
#if PBB_Passes > 1
	texture tex2 { Width=sclX/4; Height=sclY/4; Format=RGBA16F; };
	sampler2D sTex2 { Texture=tex2; };
#if PBB_Passes > 2
	texture tex3 { Width=sclX/8; Height=sclY/8; Format=RGBA16F; };
	sampler2D sTex3 { Texture=tex3; };
#if PBB_Passes > 3
	texture tex4 { Width=sclX/16; Height=sclY/16; Format=RGBA16F; };
	sampler2D sTex4 { Texture=tex4; };
#if PBB_Passes > 4
	texture tex5 { Width=sclX/32; Height=sclY/32; Format=RGBA16F; };
	sampler2D sTex5 { Texture=tex5; };
#if PBB_Passes > 5
	texture tex6 { Width=sclX/64; Height=sclY/64; Format=RGBA16F; };
	sampler2D sTex6 { Texture=tex6; };
#if PBB_Passes > 6
	texture tex7 { Width=sclX/128; Height=sclY/128; Format=RGBA16F; };
	sampler2D sTex7 { Texture=tex7; };
#if PBB_Passes > 7
	texture tex8 { Width=sclX/256; Height=sclY/256; Format=RGBA16F; };
	sampler2D sTex8 { Texture=tex8; };	
#endif
#endif
#endif
#endif
#endif
#endif
#endif
	#endif
	
	#ifdef region //Box Blur
	float3 Blur(int scale, sampler2D sp, float2 srcCoord) {
		float3 col = 0;
		int c = 0;
		srcCoord /= scale;
		[loop]
		for(int x = 0; x < PBB_Samples+1; ++x) {
			[unroll]
			for(int y = 0; y < PBB_Samples+1; ++y) {
				float2 coord = float2(x - PBB_Samples/2, y - PBB_Samples/2);
				coord.x /= BUFFER_WIDTH;
				coord.y /= BUFFER_HEIGHT;
				float2 fCoord = (srcCoord + coord) * scale;
				
				col += tex2D(sp, fCoord).rgb;
				
				c += 1;
			}
		}
		return col/c;
	}
	#endif
	
	#ifdef region //Downsamplers
	float3 DownSample1(v2f i) : SV_Target {
		return Blur(2, sHDR, i.uv);
	}
#if PBB_Passes > 1
	float3 DownSample2(v2f i) : SV_Target {
		return Blur(4, sTex1, i.uv);
	}
#if PBB_Passes > 2
	float3 DownSample3(v2f i) : SV_Target {
		return Blur(8, sTex2, i.uv);
	}
#if PBB_Passes > 3
	float3 DownSample4(v2f i) : SV_Target {
		return Blur(16, sTex3, i.uv);
	}
#if PBB_Passes > 4	
	float3 DownSample5(v2f i) : SV_Target {
		return Blur(32, sTex4, i.uv);
	}
#if PBB_Passes > 5	
	float3 DownSample6(v2f i) : SV_Target {
		return Blur(64, sTex5, i.uv);
	}
#if PBB_Passes > 6	
	float3 DownSample7(v2f i) : SV_Target {
		return Blur(128, sTex6, i.uv);
	}
#if PBB_Passes > 7	
	float3 DownSample8(v2f i) : SV_Target {
		return Blur(256, sTex7, i.uv);
	}
#endif
#endif
#endif
#endif
#endif
#endif
#endif
	#endif
	
	#ifdef region //Upsamplers
	#if PBB_Passes > 7
	float3 UpSample1(v2f i) : SV_Target {
		return Blur(256, sTex8, i.uv);
	}
	#endif
	#if PBB_Passes > 6
	float3 UpSample2(v2f i) : SV_Target {
		#if PBB_Passes < 8
		return Blur(128, sTex7, i.uv);
		#else
		return Blur(128, sTex7, i.uv) + tex2D(sTarget1, i.uv).rgb;
		#endif
	}
	#endif
	#if PBB_Passes > 5
	float3 UpSample3(v2f i) : SV_Target {
		#if PBB_Passes < 7
		return Blur(64, sTex6, i.uv);
		#else
		return Blur(64, sTex6, i.uv) + tex2D(sTarget2, i.uv).rgb;
		#endif
	}
	#endif
	#if PBB_Passes > 4
	float3 UpSample4(v2f i) : SV_Target {
		#if PBB_Passes < 6
		return Blur(32, sTex5, i.uv);
		#else
		return Blur(32, sTex5, i.uv) + tex2D(sTarget1, i.uv).rgb;
		#endif
	}
	#endif
	#if PBB_Passes > 3
	float3 UpSample5(v2f i) : SV_Target {
		#if PBB_Passes < 5
		return Blur(16, sTex4, i.uv);
		#else
		return Blur(16, sTex4, i.uv) + tex2D(sTarget2, i.uv).rgb;
		#endif
	}
	#endif
	#if PBB_Passes > 2
	float3 UpSample6(v2f i) : SV_Target {
		#if PBB_Passes < 4
		return Blur(8, sTex3, i.uv);
		#else
		return Blur(8, sTex3, i.uv) + tex2D(sTarget1, i.uv).rgb;
		#endif
	}
	#endif
	#if PBB_Passes > 1
	float3 UpSample7(v2f i) : SV_Target {
		#if PBB_Passes < 3
		return Blur(4, sTex2, i.uv);
		#else
		return Blur(4, sTex2, i.uv) + tex2D(sTarget2, i.uv).rgb;
		#endif
	}
	#endif
	float3 UpSample8(v2f i) : SV_Target {
		#if PBB_Passes < 2
		return Blur(2, sTex1, i.uv);
		#else
		return Blur(2, sTex1, i.uv) + tex2D(sTarget1, i.uv).rgb;
		#endif
	}
	#endif
	
	#ifdef region //Main function
	float3 Main(v2f i) : SV_Target {
		float3 col = tex2Dfetch(ReShade::BackBuffer, i.uv).rgb;
		float3 bloom = tex2D(target, i.uv).rgb;
		float3 dirt = tex2D(sDirt, i.uv).rgb;
		dirt *= PBB_DirtPower;
		//bloom = bloom, lerp(1 - 2 * (1 - bloom) * (1 - dirt), 2 * bloom * dirt, step(bloom, 0.5));
		//bloom += dirt*bloom;
		bloom = lerp(
			bloom,
			bloom*dirt,
			PBB_DirtDefinition
		);
		#if PBB_UseExposure
		bloom *= tex2Dfetch(sExposure, int2(0,0)).r;
		#endif
		#if PBB_DebugMode == 1
		return bloom;
		#elif PBB_DebugMode == 2
		return tex2Dfetch(sHDR, i.uv).rgb;
		#elif PBB_DebugMode == 3
		return tex2Dfetch(sExposure, int2(0,0)).r;
		#else
		return lerp(col, col+bloom, PBB_Power);
		#endif
	}
	#endif
	
	technique PBB_Tech <bool enabled = RESHADE_START_ENABLED; int toggle = PBB_ToggleKey; > {
		#ifdef region //Downsamplers
		pass d1 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample1;
			RenderTarget = tex1;
		}
		#if PBB_Passes > 1
		pass d2 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample2;
			RenderTarget = tex2;
		}
		#if PBB_Passes > 2
		pass d3 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample3;
			RenderTarget = tex3;
		}
		#if PBB_Passes > 3
		pass d4 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample4;
			RenderTarget = tex4;
		}
		#if PBB_Passes > 4
		pass d5 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample5;
			RenderTarget = tex5;
		}
		#if PBB_Passes > 5
		pass d6 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample6;
			RenderTarget = tex6;
		}
		#if PBB_Passes > 6
		pass d7 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample7;
			RenderTarget = tex7;
		}
		#if PBB_Passes > 7
		pass d8 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = DownSample8;
			RenderTarget = tex8;
		}
		#endif
		#endif
		#endif
		#endif
		#endif
		#endif
		#endif
		#endif
		#ifdef region //Upsamplers
		#if PBB_Passes > 7
		pass u1 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample1;
			RenderTarget = target1;
		}
		#endif
		#if PBB_Passes > 6
		pass u2 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample2;
			RenderTarget = target2;
		}
		#endif
		#if PBB_Passes > 5
		pass u3 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample3;
			RenderTarget = target1;
		}
		#endif
		#if PBB_Passes > 4
		pass u4 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample4;
			RenderTarget = target2;
		}
		#endif
		#if PBB_Passes > 3
		pass u5 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample5;
			RenderTarget = target1;
		}
		#endif
		#if PBB_Passes > 2
		pass u6 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample6;
			RenderTarget = target2;
		}
		#endif
		#if PBB_Passes > 1
		pass u7 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample7;
			RenderTarget = target1;
		}
		#endif	
		pass u8 {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = UpSample8;
			RenderTarget = target2;
		}
		#endif
		pass main {
			VertexShader = ReShade::VS_PostProcess;
			PixelShader = Main;
		}
	}
}

#endif