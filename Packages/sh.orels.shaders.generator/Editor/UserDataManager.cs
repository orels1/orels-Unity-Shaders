using System.Collections.Generic;

namespace ORL.ShaderGenerator.Tools
{
    public static class UserDataManager
    {
        public static T Get<T>(string key, object userData) where T : class
        {
            if (userData == null) return null;
            if (userData.GetType() != typeof(Dictionary<string, object>)) return null;
            
            var dict = (Dictionary<string, object>) userData;
            
            if (!dict.TryGetValue(key, out var value)) return null;
            
            if (value is not T) return null;
            return (T) dict[key];
        }

        public static object Set<T>(string key, object userData, T value) where T : class
        {
            Dictionary<string, object> data;
            if (userData == null)
            {
                data = new Dictionary<string, object>();
            }
            else
            {
                if (userData.GetType() != typeof(Dictionary<string, object>)) return userData;
                data = (Dictionary<string, object>) userData;
            }

            if (!data.TryGetValue(key, out var currentValue))
            {
                data[key] = value;
                return data;
            }

            if (currentValue is not T) return userData;
            data[key] = value;
            return data;
        }

        public static object Clear(string key, object userData)
        {
            if (userData == null) return null;
            if (userData.GetType() != typeof(Dictionary<string, object>)) return userData;
            
            var dict = (Dictionary<string, object>) userData;
            if (!dict.Remove(key)) return userData;
            return dict;
        }
    }
}