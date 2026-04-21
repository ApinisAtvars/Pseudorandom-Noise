#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
	StructuredBuffer<uint> _Hashes;
#endif

float4 _Config;

void ConfigureProcedural () {
	#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
		// Convert 1D line into 2D grid.
		// We do this by dividing the identifier by the resolution as an int division
		// GPUs don't have int division, so we just floor the result to drop the frac part
		// As a result, we get the coordinate in the 2nd dimension
		// Add a slight positive bias as otherwise floor might return values that are not whole
		float v = floor(_Config.y * unity_InstanceID + 0.00001);
		// Using the 2nd dimension coordinate, we can get the 1st dimension coordinate
		// _Config.x is the resolution
		float u = unity_InstanceID - _Config.x * v;
		
		
		unity_ObjectToWorld = 0.0;
		unity_ObjectToWorld._m03_m13_m23_m33 = float4(
			_Config.y * (u + 0.5) - 0.5,
			_Config.z * ((1.0 / 255.0) * (_Hashes[unity_InstanceID] >> 24) - 0.5),
			_Config.y * (v + 0.5) - 0.5,
			1.0
		);
		unity_ObjectToWorld._m00_m11_m22 = _Config.y;
	#endif
}


// Get the hash, and use it to produce an RGB color.
float3 GetHashColor () {
	#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
		uint hash = _Hashes[unity_InstanceID];
		// return (1.0 / 255.0) * (hash & 255); // Make pattern repeat every 255 blocks
		// return (1.0 / 255.0) * ((hash >> 8) & 255) // You can view a different part of the hash by shifting it around
		
		return (1.0 / 255.0) * float3( // Adding color
			hash & 255, 		// lowest byte for red
			(hash >> 8) & 255, 	// second lowest for green
			(hash >> 16) & 255 	// third lowest for blue
		);
	#else
		return 1.0;
	#endif
}

void ShaderGraphFunction_float (float3 In, out float3 Out, out float3 Color) {
	Out = In;
	Color = GetHashColor();
}

void ShaderGraphFunction_half (half3 In, out half3 Out, out half3 Color) {
	Out = In;
	Color = GetHashColor();
}
