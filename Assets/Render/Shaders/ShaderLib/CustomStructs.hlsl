struct NormalTexData
{
    float3 normalWS;
    float diffuseBias;
};
            
struct MTexData
{
    int materialID;
    float metallic;
    float smoothness;
    float specular;
};

struct AttenuationData
{
    float shadowFade;
    float shadow;     
    float shallowFade;
    float shallow;    
    float sss;        
    float front;      
    float forward;
};