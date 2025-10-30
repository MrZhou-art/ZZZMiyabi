using UnityEngine;
using System.Collections.Generic;
using UnityEngine.Serialization;

public class FaceBoneTracker : MonoBehaviour
{
    private Transform m_HeadForwardBeginBone;
    private Transform m_HeadLeftBeginBone;
    private Transform m_HeadForwardEndBone;
    private Transform m_HeadLeftEndBone;
    private readonly string m_HeadForwardShaderName = "_HeadForward";
    private readonly string m_HeadLeftShaderName = "_HeadLeft";
    
    public string m_HeadForwardBeginBoneName = "Head_Forward";
    public string m_HeadLeftBeginBoneName = "Head_Left";
    public string m_HeadForwardEndBoneName = "Head_Forward/Head_Forward_end";
    public string m_HeadLeftEndBoneName = "Head_Left/Head_Left_end";

    void Start()
    {
        // 通过路径查找骨骼，路径为从当前骨骼到目标骨骼的层级路径
        m_HeadForwardBeginBone = transform.Find(m_HeadForwardBeginBoneName);
        m_HeadLeftBeginBone = transform.Find(m_HeadLeftBeginBoneName);
        m_HeadForwardEndBone = transform.Find(m_HeadForwardEndBoneName);
        m_HeadLeftEndBone = transform.Find(m_HeadLeftEndBoneName);

        // 检查是否找到骨骼
        if (m_HeadForwardBeginBone == null || m_HeadForwardEndBone == null)
            Debug.LogWarning("未找到Head_Forward骨骼！");
        if (m_HeadLeftBeginBone == null || m_HeadLeftEndBone == null)
            Debug.LogWarning("未找到Head_Left骨骼！");
    }

    void Update()
    {
        if (m_HeadForwardBeginBone != null &&
            m_HeadLeftBeginBone != null &&
            m_HeadForwardEndBone != null &&
            m_HeadLeftEndBone != null)
        {
            // 获取世界坐标位置
            Vector3 headForward = Vector3.Normalize(m_HeadForwardEndBone.position - m_HeadForwardBeginBone.position);
            Vector3 headLeft = Vector3.Normalize(m_HeadLeftEndBone.position - m_HeadLeftBeginBone.position);
            
            // for debug
            // Debug.Log($"Head_Forward 位置：{headForward}");
            // Debug.Log($"Head_Left 位置：{headLeft}");
            
            Shader.SetGlobalVector(m_HeadForwardShaderName,  headForward);
            Shader.SetGlobalVector(m_HeadLeftShaderName,  headLeft);
        }
    }
}