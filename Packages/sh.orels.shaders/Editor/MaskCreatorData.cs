using System;

namespace ORL.Shaders.Tools
{
    [Serializable]
    public class MaskCreatorData
    {
        public enum MaskType
        {
            Grid
        }

        [Serializable]
        public struct GridMaskData
        {
            public int width;
            public int height;

            public float[][] values;
        }

        public MaskType maskType;
        public GridMaskData gridData;
    }
}