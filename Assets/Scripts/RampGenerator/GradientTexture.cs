using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace RampGenerator
{
    [System.Serializable]
    public class GradientContainer : ScriptableObject
    {
        public Gradient gradient;
    }

    [System.Serializable]
    public class GradientTexture
    {
        [SerializeField]
        public Texture2D texture;
        [SerializeField]
        public List<Gradient> gradient;

        public string savePath = "Asset/";

        TextureImporter m_import;

        const int c_singleLineHeight = 2;
        const string c_jsonSplit = "#";

        public GradientTexture()
        {
            gradient = new List<Gradient>();
        }

        public GradientTexture(Texture2D ramp)
        {
            texture = ramp;
            LoadGradientAndPath();
        }

        public void GradientListToTexture()
        {
            if (texture == null || texture.height != 2 * gradient.Count)
            {
                texture = new Texture2D(256, 2 * gradient.Count, TextureFormat.ARGB32, false);
                //提前设置filtMode，不然在绘制preview的时候会插值
                texture.filterMode = FilterMode.Point;
            }

            Color[] colors = new Color[texture.width * texture.height];
            for (int i = 0; i < texture.height; i += c_singleLineHeight)
            {
                for (int j = 0; j < texture.width; j++)
                {
                    Color c = gradient[gradient.Count - 1 - i / c_singleLineHeight].Evaluate((float)j / (texture.width - 1));
                    //第一行
                    colors[i * texture.width + j] = c;
                    //第二行
                    colors[(i + 1) * texture.width + j] = c;
                }
            }
            texture.SetPixels(colors);
            //修改的内存信息
            texture.Apply();
        }

        public bool LoadGradientAndPath()
        {
            //如果改变了渐变行数，就需要new一个Texture2D，这时候temp就是空
            //因此，只有temp和原先的savePath都为空才return
            string temp = AssetDatabase.GetAssetPath(texture);
            savePath = string.IsNullOrEmpty(temp) ? savePath : temp;
            if (string.IsNullOrEmpty(savePath))
            {
                Debug.LogWarning("渐变图不存在");
                return false;
            }
            else
            {
                m_import = AssetImporter.GetAtPath(savePath) as TextureImporter;
                if (m_import == null || string.IsNullOrEmpty(m_import.userData))
                {
                    Debug.LogWarning("importer不存在");
                    return false;
                }
                JsonToGradientList(m_import.userData);
                return true;
            }
        }

        public void RevertChange()
        {
            //userData是硬盘中的，使用userData进行还原
            LoadGradientAndPath();
            GradientListToTexture();
        }

        public bool SaveTexture()
        {
            if (texture == null)
            {
                Debug.LogWarning("渐变图不存在");
                return false;
            }
            File.WriteAllBytes(savePath, texture.EncodeToPNG());
            //只调用上面的函数的话，在编辑器是看不到文件的，因为没有.meta文件
            AssetDatabase.Refresh();

            ImportSetting();
            return true;
        }

        void ImportSetting()
        {
            m_import = AssetImporter.GetAtPath(savePath) as TextureImporter;
            if (m_import != null)
            {
                m_import.filterMode = FilterMode.Point;
                m_import.isReadable = true;
                m_import.mipmapEnabled = false;
                m_import.maxTextureSize = 256;
                m_import.wrapMode = TextureWrapMode.Repeat;
                m_import.textureCompression = TextureImporterCompression.Uncompressed;
                m_import.userData = GradientListToJson();
                m_import.npotScale = TextureImporterNPOTScale.None;
                m_import.SaveAndReimport();
            }
            else
            {
                Debug.LogWarning("importer不存在");
            }
        }

        //对每个元素转json然后合并
        string GradientListToJson()
        {
            string[] json = new string[gradient.Count];
            for (int i = 0; i < json.Length; i++)
            {
                json[i] = GradientToJson(gradient[i]);
            }
            return string.Join(c_jsonSplit, json);
        }

        void JsonToGradientList(string json)
        {
            List<Gradient> gradients = new List<Gradient>();
            string[] j = json.Split(c_jsonSplit);
            for (int i = 0; i < j.Length; i++)
            {
                gradients.Add(JsonToGradient(j[i]));
            }
            gradient = gradients;
        }

        string GradientToJson(Gradient g)
        {
            GradientContainer container = ScriptableObject.CreateInstance<GradientContainer>();
            container.gradient = g;
            return EditorJsonUtility.ToJson(container);
        }

        Gradient JsonToGradient(string json)
        {
            GradientContainer container = ScriptableObject.CreateInstance<GradientContainer>();
            EditorJsonUtility.FromJsonOverwrite(json, container);
            return container.gradient;
        }

        public void DebugData()
        {
            Debug.Log("texture:" + texture + "height:" + texture.height);
            Debug.Log("savePath:" + savePath);
            Debug.Log("count:" + gradient.Count);
        }
    }
}