using System;

namespace ORL.ShaderGenerator
{
    [Serializable]
    public class MissingBlockException : Exception
    {
        public string BlockName { get; set; }

        public override string ToString()
        {
            return $"Block {BlockName} is required. {Message}";
        }

        public MissingBlockException()
        {
        }

        public MissingBlockException(string message) : base(message)
        {
        }
        
        public MissingBlockException(string blockName, string message = "") : base(message)
        {
            BlockName = blockName;
        }

        public MissingBlockException(string message, Exception inner) : base(message, inner)
        {
        }
    }
    
    [Serializable]
    public class MissingParameterException : Exception
    {
        public string ParameterName { get; set; }
        public string BlockName { get; set; }

        public override string ToString()
        {
            return $"Block Parameter {ParameterName} is required in block {BlockName}. {Message}";
        }

        public MissingParameterException()
        {
        }

        public MissingParameterException(string message) : base(message)
        {
        }
        
        public MissingParameterException(string parameterName, string message = "") : base(message)
        {
            ParameterName = parameterName;
        }
        
        public MissingParameterException(string parameterName, string blockName, string message = "") : base(message)
        {
            BlockName = blockName;
            ParameterName = parameterName;
        }

        public MissingParameterException(string message, Exception inner) : base(message, inner)
        {
        }
    }

    [Serializable]
    public class SourceAssetNotFoundException : Exception
    {
        public string AssetPath { get; set; }
        public string[] AttemptedPaths { get; set; }
        public string BlockName { get; set; }

        public override string ToString()
        {
            var message = $"Source asset {AssetPath} not found\n";
            if (!string.IsNullOrWhiteSpace(BlockName))
            {
                message = $"Source asset {AssetPath} in block {BlockName} not found.\n";
            }
            if (AttemptedPaths?.Length > 0)
            {
                message += $"Attempted to resolve in:\n" +
                           $"{string.Join("\n", AttemptedPaths)}";
            }

            if (!string.IsNullOrWhiteSpace(Message))
            {
                message += $"\n{Message}";
            }

            return message;
        }

        public SourceAssetNotFoundException()
        {
        }

        public SourceAssetNotFoundException(string message) : base(message)
        {
        }
        
        public SourceAssetNotFoundException(string assetPath, string message = "") : base(message)
        {
            AssetPath = assetPath;
        }
        
        public SourceAssetNotFoundException(string assetPath, string blockName, string message = "") : base(message)
        {
            AssetPath = assetPath;
            BlockName = blockName;
        }
        
        public SourceAssetNotFoundException(string assetPath, string blockName, string[] attemptedPaths, string message = "") : base(message)
        {
            AssetPath = assetPath;
            BlockName = blockName;
            AttemptedPaths = attemptedPaths;
        }
        
        public SourceAssetNotFoundException(string assetPath, string[] attemptedPaths, string message = "") : base(message)
        {
            AssetPath = assetPath;
            AttemptedPaths = attemptedPaths;
        }

        public SourceAssetNotFoundException(string message, Exception inner) : base(message, inner)
        {
        }
    }
}