#if UNITY_EDITOR
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;


namespace RampGenerator
{
    public class GradientTextureEditorWindow : EditorWindow
    {
        [SerializeField]
        GradientTexture m_gradientTexture;
        SerializedObject m_serializedObject;
        SerializedProperty m_objProp;
        SerializedProperty m_texProp;
        SerializedProperty m_gradientProp;
        ReorderableList m_gradientList;

        bool editWithInput;

        bool shouldSave = false;


        [MenuItem("CustomTools/GradientTextureEditor &R")]
        public static void ShowWindow()
        {
            //调用这个方法即可出现window
            var window = EditorWindow.GetWindow<GradientTextureEditorWindow>();
            window.editWithInput = false;
        }

        public static void ShowWindow(Texture2D rampTex)
        {
            var window = EditorWindow.GetWindow<GradientTextureEditorWindow>();
            window.m_gradientTexture = new GradientTexture(rampTex);
            window.editWithInput = true;
        }

        private void OnEnable()
        {
            titleContent = new GUIContent("GradientTextureEditor");
            if (m_gradientTexture == null)
            {
                m_gradientTexture = new GradientTexture();
            }
            m_serializedObject = new SerializedObject(this);
            m_objProp = m_serializedObject.FindProperty("m_gradientTexture");
            m_texProp = m_objProp.FindPropertyRelative("texture");
            m_gradientProp = m_objProp.FindPropertyRelative("gradient");

            InitReorderableList();

            minSize = new Vector2(300, 400);
        }

        void InitReorderableList()
        {
            //该构造函数就支持拖拽元素，增减元素
            m_gradientList = new ReorderableList(m_serializedObject, m_gradientProp);

            //绘制标题
            m_gradientList.drawHeaderCallback = (Rect rect) =>
            {
                EditorGUI.LabelField(rect, "Gradient List");
            };

            //绘制单个元素
            m_gradientList.drawElementCallback = (Rect rect, int index, bool isActive, bool isFocused) =>
            {
                //可以调整rect来增大间隙
                var prop = m_gradientList.serializedProperty.GetArrayElementAtIndex(index);
                EditorGUI.PropertyField(rect, prop, new GUIContent("第 " + (index + 1) + " 行"));
            };

            //新增元素
            m_gradientList.onAddCallback = (ReorderableList list) =>
            {
                //list.serializedProperty就是自己的gradientList
                list.serializedProperty.arraySize++;
                //列表中被选中的元素，，可以不设置
                list.index = list.serializedProperty.arraySize - 1;
                //让新增元素默认和上一个元素相等
                list.serializedProperty.GetArrayElementAtIndex(list.count - 1).gradientValue = list.count > 1 ? list.serializedProperty.GetArrayElementAtIndex(list.count - 2).gradientValue : new Gradient();
            };
        }

        private void OnGUI()
        {
            m_serializedObject.Update();
            //gradient
            EditorGUI.BeginChangeCheck();
            m_gradientList.DoLayoutList();
            if (EditorGUI.EndChangeCheck())
            {
                m_serializedObject.ApplyModifiedProperties();

                m_gradientTexture.GradientListToTexture();

                m_serializedObject.Update();
                shouldSave = true;
            }

            //texture input
            if (!editWithInput)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUILayout.PropertyField(m_texProp, new GUIContent("渐变图"));
                if (EditorGUI.EndChangeCheck())
                {
                    m_serializedObject.ApplyModifiedProperties();

                    m_gradientTexture.LoadGradientAndPath();

                    m_serializedObject.Update();
                }
            }

            float windowWidth = EditorGUIUtility.currentViewWidth;


            //file path
            Rect browseRect = EditorGUILayout.GetControlRect();
            float edge = browseRect.x;
            browseRect.width = 80;
            browseRect.x = windowWidth - browseRect.width - edge;
            browseRect.y += edge;

            Rect textRect = browseRect;
            textRect.width = windowWidth - browseRect.width - 4 * edge;
            textRect.x = edge;

            EditorGUI.BeginChangeCheck();
            string path = m_gradientTexture.savePath;
            path = EditorGUI.TextField(textRect, "File path:", path);
            if (GUI.Button(browseRect, "Browse"))
            {
                path = EditorUtility.SaveFilePanelInProject("Save Texture", "newRamp", "png", "");
            }
            if (EditorGUI.EndChangeCheck())
            {
                m_gradientTexture.savePath = path;
            }

            //save and revert button
            float buttonWidth = 100;
            Rect saveRect = textRect;
            float gap = (windowWidth - 2 * buttonWidth) / 3;
            saveRect.x = gap;
            saveRect.y += textRect.height + edge;
            saveRect.width = buttonWidth;

            Rect revertRect = saveRect;
            revertRect.x += buttonWidth + gap;

            if (GUI.Button(saveRect, "Save"))
            {
                m_gradientTexture.SaveTexture();
                shouldSave = false;
            }
            if (GUI.Button(revertRect, "Revert"))
            {
                m_gradientTexture.RevertChange();
                shouldSave = false;
            }

            //tex preview
            Rect texRect = saveRect;
            texRect.y += saveRect.height + edge;
            texRect.width = Mathf.Min(500, windowWidth - 2 * edge, position.height - texRect.y - edge);
            texRect.height = texRect.width;
            texRect.x = 0.5f * (windowWidth - texRect.width);
            if (m_gradientTexture.texture != null)
            {
                EditorGUI.DrawPreviewTexture(texRect, m_gradientTexture.texture);
            }

            m_serializedObject.ApplyModifiedProperties();

        }
        //关闭窗口时调用
        private void OnDestroy()
        {
            if (shouldSave)
            {
                //弹出提示框
                if(EditorUtility.DisplayDialog("Warning","Save Changes?", "Yes", "No"))
                {
                    m_gradientTexture.SaveTexture();
                }
                else
                {
                    m_gradientTexture.RevertChange();
                }
            }
        }
    }
}
#endif